import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

/** Registers a mobile store purchase so the app unlocks (metadata only; verify receipts in production). */
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

    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '',
    );

    const token = authHeader.replace('Bearer ', '');
    const {
      data: { user },
      error: userErr,
    } = await supabaseAdmin.auth.getUser(token);
    if (userErr || !user) {
      return new Response(JSON.stringify({ error: 'Unauthorized' }), {
        status: 401,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const body = await req.json();
    const {
      companyId,
      plan,
      platform,
      productId,
      purchaseId,
      verificationData,
    } = body as {
      companyId?: string;
      plan?: string;
      platform?: string;
      productId?: string;
      purchaseId?: string;
      verificationData?: string;
    };

    if (!companyId || !plan || !platform || !productId || !purchaseId) {
      return new Response(
        JSON.stringify({ error: 'companyId, plan, platform, productId, purchaseId required' }),
        { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
      );
    }

    const plat = platform === 'android' ? 'android' : 'ios';
    const { data: profile, error: profErr } = await supabaseAdmin
      .from('users')
      .select('company_id, role')
      .eq('id', user.id)
      .maybeSingle();

    if (profErr || !profile || profile.company_id !== companyId) {
      return new Response(JSON.stringify({ error: 'Company mismatch' }), {
        status: 403,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const allowed = ['starter', 'growth', 'pro'];
    if (!allowed.includes(plan)) {
      return new Response(JSON.stringify({ error: 'Invalid plan' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const stripeSubscriptionId = `iap_${plat}_${purchaseId}`.slice(0, 200);
    const stripeCustomerId = `iap_customer_${companyId}`.slice(0, 200);
    const now = new Date();
    const periodEnd = new Date(now.getTime() + 32 * 24 * 60 * 60 * 1000);

    const metadata = {
      plan,
      source: `iap_${plat}`,
      product_id: productId,
      purchase_id: purchaseId,
      registered_at: now.toISOString(),
      verification_pending: true,
      verification_data_len: verificationData?.length ?? 0,
    };

    const { error: upErr } = await supabaseAdmin.from('subscriptions').upsert(
      {
        company_id: companyId,
        stripe_customer_id: stripeCustomerId,
        stripe_subscription_id: stripeSubscriptionId,
        stripe_price_id: productId,
        status: 'active',
        current_period_start: now.toISOString(),
        current_period_end: periodEnd.toISOString(),
        cancel_at_period_end: false,
        updated_at: now.toISOString(),
        metadata,
      },
      { onConflict: 'stripe_subscription_id' },
    );

    if (upErr) {
      return new Response(JSON.stringify({ error: String(upErr.message) }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    return new Response(JSON.stringify({ ok: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
