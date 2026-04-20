import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { escapeHtml, fabricEmailLayout, getAdminContactEmail, sendEmail } from '../_shared/email.ts';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const body = await req.json();
    const { name, email, company, message } = body as {
      name?: string;
      email?: string;
      company?: string;
      message?: string;
    };

    if (!email || typeof email !== 'string' || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      return new Response(JSON.stringify({ error: 'Valid email required' }), {
        status: 400,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    );

    const { error } = await supabase.from('contact_requests').insert({
      name: name ?? null,
      email,
      company: company ?? null,
      message: message ?? null,
    });

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      });
    }

    try {
      const adminEmail = getAdminContactEmail();
      const inner = `
        <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin:0 0 20px;">
          <tr><td style="padding:8px 0;color:#94A3B8;font-size:13px;">Nome</td></tr>
          <tr><td style="padding:0 0 14px;color:#F9FAFB;font-weight:600;">${escapeHtml(name ?? '-')}</td></tr>
          <tr><td style="padding:8px 0;color:#94A3B8;font-size:13px;">Email</td></tr>
          <tr><td style="padding:0 0 14px;"><a href="mailto:${email.replace(/"/g, '')}" style="color:#93C5FD;font-weight:600;">${escapeHtml(email)}</a></td></tr>
          <tr><td style="padding:8px 0;color:#94A3B8;font-size:13px;">Azienda</td></tr>
          <tr><td style="padding:0 0 14px;color:#F9FAFB;">${escapeHtml(company ?? '-')}</td></tr>
        </table>
        <p style="margin:0 0 10px;color:#94A3B8;font-size:13px;">Messaggio</p>
        <div style="white-space:pre-wrap;background:rgba(0,0,0,0.28);border:1px solid rgba(255,255,255,0.12);padding:16px 18px;border-radius:12px;color:#CBD5E1;font-size:15px;line-height:1.55;">
          ${escapeHtml(message ?? '')}
        </div>
      `;
      await sendEmail({
        to: adminEmail,
        subject: 'Nuovo contatto ricevuto da FabricOS',
        html: fabricEmailLayout({
          variant: 'brand',
          eyebrow: 'Lead',
          title: 'Nuovo contatto dal sito',
          subtitle: 'Qualcuno ha compilato il form pubblico',
          bodyHtml: inner,
        }),
        text: [
          'Nuovo contatto ricevuto da FabricOS',
          `Nome: ${name ?? '-'}`,
          `Email: ${email}`,
          `Azienda: ${company ?? '-'}`,
          `Messaggio: ${message ?? ''}`,
        ].join('\n'),
      });
    } catch (emailError) {
      console.error('Contact email failed', emailError);
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  } catch (e) {
    return new Response(JSON.stringify({ error: String(e) }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    });
  }
});
