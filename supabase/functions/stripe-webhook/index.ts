import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import Stripe from 'https://esm.sh/stripe@14.21.0?target=deno';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') ?? '', {
  apiVersion: '2023-10-16',
});
const webhookSecret = Deno.env.get('STRIPE_WEBHOOK_SECRET') ?? '';

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

  try {
    switch (event.type) {
      case 'checkout.session.completed': {
        const session = event.data.object as Stripe.Checkout.Session;
        const workspaceId = session.metadata?.workspace_id ?? session.client_reference_id;
        if (workspaceId && session.customer) {
          await supabase.from('customers').upsert({
            workspace_id: workspaceId,
            stripe_customer_id: typeof session.customer === 'string' ? session.customer : session.customer.id,
            updated_at: new Date().toISOString(),
          }, { onConflict: 'workspace_id' });
        }
        if (session.subscription) {
          const sub = await stripe.subscriptions.retrieve(
            typeof session.subscription === 'string' ? session.subscription : session.subscription.id
          );
          await supabase.from('subscriptions').upsert({
            workspace_id: workspaceId,
            stripe_customer_id: sub.customer as string,
            stripe_subscription_id: sub.id,
            stripe_price_id: sub.items.data[0]?.price.id,
            status: sub.status as string,
            current_period_start: new Date(sub.current_period_start * 1000).toISOString(),
            current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
            cancel_at_period_end: sub.cancel_at_period_end,
            updated_at: new Date().toISOString(),
          }, { onConflict: 'stripe_subscription_id' });
        }
        break;
      }
      case 'customer.subscription.created':
      case 'customer.subscription.updated': {
        const sub = event.data.object as Stripe.Subscription;
        const workspaceId = sub.metadata?.workspace_id;
        if (workspaceId) {
          await supabase.from('subscriptions').upsert({
            workspace_id: workspaceId,
            stripe_customer_id: sub.customer as string,
            stripe_subscription_id: sub.id,
            stripe_price_id: sub.items.data[0]?.price.id,
            status: sub.status,
            current_period_start: new Date(sub.current_period_start * 1000).toISOString(),
            current_period_end: new Date(sub.current_period_end * 1000).toISOString(),
            cancel_at_period_end: sub.cancel_at_period_end,
            updated_at: new Date().toISOString(),
          }, { onConflict: 'stripe_subscription_id' });
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
