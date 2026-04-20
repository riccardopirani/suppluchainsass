import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import Stripe from 'https://esm.sh/stripe@14.21.0?target=deno';
import { resolveCompanyTable } from '../_shared/company_table.ts';
import { fabricEmailLayout, sendEmail } from '../_shared/email.ts';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') ?? '', {
  apiVersion: '2023-10-16',
});
const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET') ?? '';

async function sendRenewalEmail(params: {
  supabase: any;
  companyId: string;
  subscriptionId: string;
  trialEnd?: number;
}) {
  const { data: recipient } = await params.supabase
    .from('users')
    .select('email, full_name')
    .eq('company_id', params.companyId)
    .eq('role', 'admin')
    .maybeSingle();

  if (!recipient?.email) {
    console.warn(`Renewal email skipped: no admin email found for company ${params.companyId}`);
    return;
  }

  const appUrl = Deno.env.get('APP_BASE_URL') ?? 'http://localhost:3000';
  const renewalUrl = `${appUrl.replace(/\/$/, '')}/app/billing`;
  const trialEndText = params.trialEnd
    ? new Intl.DateTimeFormat('it-IT', { dateStyle: 'long' }).format(
        new Date(params.trialEnd * 1000),
      )
    : '';

  const subject = 'Il tuo abbonamento FabricOS va rinnovato';
  const html = fabricEmailLayout({
    variant: 'warning',
    eyebrow: 'Billing',
    title: 'La prova è terminata',
    subtitle: 'Rinnova per mantenere FabricOS attivo',
    bodyHtml: `
      <p style="margin:0 0 18px;color:#CBD5E1;">
        Il tuo abbonamento FabricOS
        ${
      trialEndText
        ? ` è scaduto il <strong style="color:#FDE68A;">${trialEndText}</strong>.`
        : ' ha raggiunto la fine della prova gratuita.'
    }
        Per mantenere l’accesso, apri il pannello <strong style="color:#F9FAFB;">Billing</strong> e completa il rinnovo con Stripe.
      </p>
      <p style="margin:0;color:#94A3B8;font-size:15px;">
        Con carta già salvata, Stripe guida al rinnovo; altrimenti potrai aggiornare il metodo di pagamento.
      </p>
    `,
    primaryCta: { label: 'Rinnova con Stripe', url: renewalUrl },
    footerNote: `Subscription: ${params.subscriptionId.slice(0, 24)}…`,
  });

  const sent = await sendEmail({
    to: recipient.email,
    subject,
    html,
    text:
      `La prova gratuita di FabricOS è terminata. Apri ${renewalUrl} per rinnovare con Stripe.`,
    resendHeaders: {
      'X-Subscription-Id': params.subscriptionId,
    },
  });

  if (!sent) {
    console.warn('Renewal email skipped: no mail provider configured');
  }
}

serve(async (req) => {
  const signature = req.headers.get('stripe-signature');
  if (!signature || !webhookSecret) {
    return new Response(JSON.stringify({ error: 'Webhook secret required' }), { status: 400 });
  }

  let event: Stripe.Event;
  try {
    const body = await req.text();
    event = stripe.webhooks.constructEvent(body, signature, webhookSecret);
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), { status: 400 });
  }

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  );
  const companyTable = await resolveCompanyTable(supabase);

  const { data: existingEvent } = await supabase
    .from('subscription_events')
    .select('id')
    .eq('stripe_event_id', event.id)
    .maybeSingle();
  if (existingEvent) {
    return new Response(JSON.stringify({ received: true, duplicate: true }), {
      headers: { 'Content-Type': 'application/json' },
    });
  }

  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session;
        let companyId =
          session.metadata?.company_id ?? session.client_reference_id ?? undefined;
        const purchasedSeats = parseInt(session.metadata?.seats ?? '0', 10);
        if (session.subscription) {
          const sub = await stripe.subscriptions.retrieve(
            typeof session.subscription === 'string' ? session.subscription : session.subscription.id
          );
          companyId = companyId ?? sub.metadata?.company_id;
          if (companyId && session.customer) {
            await supabase.from('customers').upsert({
              company_id: companyId,
              stripe_customer_id: typeof session.customer === 'string' ? session.customer : session.customer.id,
              updated_at: new Date().toISOString(),
            }, { onConflict: 'company_id' });
          }
          if (companyId) {
            await supabase.from('subscriptions').upsert({
              company_id: companyId,
              stripe_customer_id: sub.customer as string,
              stripe_subscription_id: sub.id,
              stripe_price_id: sub.items.data[0]?.price.id,
              status: sub.status as string,
              current_period_start: new Date(sub.current_period_start * 1000).toISOString(),
              current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
              cancel_at_period_end: sub.cancel_at_period_end,
              updated_at: new Date().toISOString(),
            }, { onConflict: 'stripe_subscription_id' });
            if (purchasedSeats > 0) {
              await supabase.from(companyTable)
                .update({ seat_limit: purchasedSeats })
                .eq('id', companyId);
            }
          }
        } else if (companyId && session.customer) {
          await supabase.from('customers').upsert({
            company_id: companyId,
            stripe_customer_id: typeof session.customer === 'string' ? session.customer : session.customer.id,
            updated_at: new Date().toISOString(),
          }, { onConflict: 'company_id' });
        }
        break;
      }
      case 'customer.subscription.created':
      case 'customer.subscription.updated': {
        const sub = event.data.object as Stripe.Subscription;
        const companyId = sub.metadata?.company_id;
        if (companyId) {
          await supabase.from('subscriptions').upsert({
            company_id: companyId,
            stripe_customer_id: sub.customer as string,
            stripe_subscription_id: sub.id,
            stripe_price_id: sub.items.data[0]?.price.id,
            status: sub.status,
            current_period_start: new Date(sub.current_period_start * 1000).toISOString(),
            current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
            cancel_at_period_end: sub.cancel_at_period_end,
            updated_at: new Date().toISOString(),
            }, { onConflict: 'stripe_subscription_id' });

          const previousAttributes = (
            event.data as {
              previous_attributes?: { status?: string };
            }
          ).previous_attributes;
          if (
            event.type === 'customer.subscription.updated' &&
            previousAttributes?.status === 'trialing' &&
            sub.status !== 'trialing'
          ) {
            await sendRenewalEmail({
              supabase,
              companyId,
              subscriptionId: sub.id,
              trialEnd: sub.trial_end ?? undefined,
            });
          }
        }
        break;
      }
      case 'invoice.paid': {
        const invoice = event.data.object as Stripe.Invoice;
        let companyId: string | undefined = invoice.subscription_details?.metadata?.company_id;
        const subRef = invoice.subscription;
        const subId = typeof subRef === 'string' ? subRef : subRef?.id;
        if (!companyId && subId) {
          const sub = await stripe.subscriptions.retrieve(subId);
          companyId = sub.metadata?.company_id;
        }
        if (!companyId && subId) {
          const { data: row } = await supabase
            .from('subscriptions')
            .select('company_id')
            .eq('stripe_subscription_id', subId)
            .maybeSingle();
          companyId = row?.company_id ?? undefined;
        }
        if (companyId && invoice.id) {
          await supabase.from('payment_history').upsert({
            company_id: companyId,
            stripe_invoice_id: invoice.id,
            amount_paid: (invoice.amount_paid ?? 0) / 100,
            currency: invoice.currency ?? 'eur',
            paid_at: invoice.status_transitions?.paid_at
              ? new Date(invoice.status_transitions.paid_at * 1000).toISOString()
              : new Date().toISOString(),
          }, { onConflict: 'stripe_invoice_id' });
        }
        break;
      }
      case 'customer.subscription.deleted': {
        const sub = event.data.object as Stripe.Subscription;
        await supabase
          .from('subscriptions')
          .update({ status: 'canceled', updated_at: new Date().toISOString() })
          .eq('stripe_subscription_id', sub.id);
        break;
      }
      default:
        break;
    }

    await supabase.from('subscription_events').insert({
      company_id: (event.data.object as { metadata?: { company_id?: string } })?.metadata?.company_id ?? null,
      stripe_event_id: event.id,
      event_type: event.type,
      payload: event as unknown as object,
    });
  } catch (e) {
    console.error(e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }

  return new Response(JSON.stringify({ received: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
});
