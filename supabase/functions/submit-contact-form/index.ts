import { serve } from 'https://deno.land/std@0.168.0/http/server.ts';
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2';
import { escapeHtml, getAdminContactEmail, sendEmail } from '../_shared/email.ts';

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
      const bodyHtml = `
        <div style="font-family: Arial, sans-serif; line-height: 1.5; color: #0f172a;">
          <h2 style="margin: 0 0 12px;">Nuovo contatto dal sito FabricOS</h2>
          <p style="margin: 0 0 8px;"><strong>Nome:</strong> ${escapeHtml(name ?? '-')}</p>
          <p style="margin: 0 0 8px;"><strong>Email:</strong> ${escapeHtml(email)}</p>
          <p style="margin: 0 0 8px;"><strong>Azienda:</strong> ${escapeHtml(company ?? '-')}</p>
          <p style="margin: 16px 0 8px;"><strong>Messaggio:</strong></p>
          <div style="white-space: pre-wrap; background: #f8fafc; border: 1px solid #e2e8f0; padding: 14px; border-radius: 8px;">
            ${escapeHtml(message ?? '')}
          </div>
        </div>
      `;
      await sendEmail({
        to: adminEmail,
        subject: 'Nuovo contatto ricevuto da FabricOS',
        html: bodyHtml,
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
