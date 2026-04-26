import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import Stripe from 'https://esm.sh/stripe@14.21.0?target=deno';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const authHeader = req.headers.get('Authorization');
    if (!authHeader) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
      { global: { headers: { Authorization: authHeader } } }
    );

    const { data: { user } } = await supabase.auth.getUser(
      authHeader.replace('Bearer ', '')
    );
    if (!user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const body = await req.json();
    const {
      companyId,
      quantity,
      unitAmountCents,
      currency,
      successUrl,
      cancelUrl,
      trialDays,
      plan,
      billingInterval,
    } = body as {
      companyId: string;
      quantity: number;
      unitAmountCents: number;
      currency?: string;
      successUrl?: string;
      cancelUrl?: string;
      trialDays?: number;
      plan?: string;
      billingInterval?: 'month' | 'year';
    };

    if (!companyId || !quantity || !unitAmountCents) {
      return new Response(
        JSON.stringify({ error: 'companyId, quantity, and unitAmountCents are required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const interval = billingInterval === 'year' ? 'year' : 'month';
    const planKey = (plan ?? '').toString().trim() || 'essenziale';

    const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY') ?? '', { apiVersion: '2023-10-16' });
    const appUrl = Deno.env.get('APP_BASE_URL') ?? 'http://localhost:3000';

    const session = await stripe.checkout.sessions.create({
      mode: 'subscription',
      payment_method_types: ['card'],
      line_items: [
        {
          price_data: {
            currency: currency ?? 'eur',
            product_data: { name: 'FabricOS Platform' },
            unit_amount: unitAmountCents,
            recurring: { interval },
          },
          quantity,
        },
      ],
      success_url: successUrl ?? `${appUrl}/app/billing?success=true`,
      cancel_url: cancelUrl ?? `${appUrl}/app/billing?canceled=true`,
      client_reference_id: companyId,
      metadata: {
        company_id: companyId,
        user_id: user.id,
        seats: String(quantity),
        plan: planKey,
      },
      subscription_data: {
        metadata: { company_id: companyId, seats: String(quantity), plan: planKey },
        ...(trialDays != null && trialDays > 0 ? { trial_period_days: trialDays } : {}),
      },
    });

    return new Response(JSON.stringify({ url: session.url }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
