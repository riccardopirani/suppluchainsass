import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { escapeHtml, fabricEmailLayout, getAppBaseUrl, sendEmail } from '../_shared/email.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

const json = (body: unknown, status = 200) =>
  new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  const authHeader = req.headers.get('Authorization');
  if (!authHeader) return json({ error: 'Unauthorized' }, 401);

  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_ANON_KEY') ?? '',
    { global: { headers: { Authorization: authHeader } } },
  );

  const token = authHeader.replace(/^Bearer\s+/i, '');
  const { data: { user }, error: userError } = await supabase.auth.getUser(token);
  if (userError || !user?.email) {
    return json({ error: 'Unauthorized' }, 401);
  }

  let body: Record<string, unknown> = {};
  try {
    body = (await req.json()) as Record<string, unknown>;
  } catch {
    /* optional body */
  }

  const fullName =
    (typeof body.fullName === 'string' ? body.fullName : '').trim() ||
    user.user_metadata?.full_name?.toString()?.trim() ||
    '';
  const seats = typeof body.seats === 'number' && body.seats >= 1 ? Math.floor(body.seats) : 10;
  const startTrial = body.startTrial !== false;
  const plan = typeof body.plan === 'string' && body.plan.length > 0 ? body.plan : 'growth';

  const base = getAppBaseUrl();
  const onboardingUrl =
    `${base}/onboarding?seats=${seats}&trial=${startTrial ? '1' : '0'}&plan=${encodeURIComponent(plan)}`;
  const loginUrl = `${base}/login`;

  const greetingLine = fullName
    ? `<p style="margin:0 0 18px;color:#F9FAFB;font-size:17px;">Ciao <strong>${escapeHtml(fullName)}</strong>,</p>`
    : `<p style="margin:0 0 18px;color:#F9FAFB;font-size:17px;">Ciao,</p>`;
  const trialLine = startTrial
    ? 'Hai attivato il periodo di prova: completa l’onboarding per creare il workspace e iniziare.'
    : 'Completa l’onboarding per creare il workspace e configurare FabricOS.';

  try {
    const sent = await sendEmail({
      to: user.email,
      subject: 'Benvenuto in FabricOS — registrazione completata',
      html: fabricEmailLayout({
        variant: 'brand',
        eyebrow: 'Benvenuto',
        title: 'Registrazione completata',
        subtitle: 'Il tuo account FabricOS è attivo',
        bodyHtml: `
          ${greetingLine}
          <p style="margin:0 0 18px;color:#CBD5E1;">
            Grazie per esserti registrato. <strong style="color:#F9FAFB;">${trialLine}</strong>
          </p>
          <p style="margin:0;color:#94A3B8;font-size:15px;">
            Piano: <strong style="color:#93C5FD;">${escapeHtml(plan)}</strong>
            &nbsp;·&nbsp; Postazioni: <strong style="color:#93C5FD;">${seats}</strong>
          </p>
        `,
        primaryCta: { label: 'Continua con l’onboarding', url: onboardingUrl },
        secondaryLink: { label: 'Hai già un account? Accedi', url: loginUrl },
      }),
      text: [
        'Registrazione FabricOS completata.',
        fullName ? `Ciao ${fullName},` : 'Ciao,',
        trialLine,
        `Piano: ${plan}, postazioni: ${seats}.`,
        `Onboarding: ${onboardingUrl}`,
        `Login: ${loginUrl}`,
      ].join('\n\n'),
    });

    if (!sent) {
      return json({ error: 'Mail non inviata: provider non configurato' }, 503);
    }

    return json({ ok: true });
  } catch (e) {
    console.error('send-registration-welcome:', e);
    return json({ error: e instanceof Error ? e.message : String(e) }, 500);
  }
});
