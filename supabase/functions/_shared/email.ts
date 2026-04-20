import { fabricEmailLayout } from './fabric_email_layout.ts';
import { escapeHtml } from './html_escape.ts';

export type EmailRecipient = string | string[];

export { escapeHtml } from './html_escape.ts';
export { fabricEmailLayout } from './fabric_email_layout.ts';

/** Display name = FabricOS; address fixed per product requirement */
export const DEFAULT_FROM_EMAIL = 'FabricOS <sales@marconisoftware.com>';

/** Default transactional mail API (override with TRANSACTIONAL_MAIL_ENDPOINT) */
export const DEFAULT_TRANSACTIONAL_MAIL_ENDPOINT =
  'http://cloud.centoimpianti.com:8282/send';

const appBaseUrl = (Deno.env.get('APP_BASE_URL') ?? 'http://localhost:3000').replace(/\/$/, '');

export function getAppBaseUrl() {
  return appBaseUrl;
}

export function getDefaultFromEmail() {
  const fromEnv = (Deno.env.get('RESEND_FROM_EMAIL') ?? '').trim();
  return fromEnv.length > 0 ? fromEnv : DEFAULT_FROM_EMAIL;
}

export function getAdminContactEmail() {
  return Deno.env.get('ADMIN_CONTACT_EMAIL') ?? 'amministrazione@marconisoftware.com';
}

function getTransactionalMailEndpoint(): string {
  const fromEnv = (Deno.env.get('TRANSACTIONAL_MAIL_ENDPOINT') ?? '').trim();
  return fromEnv.length > 0 ? fromEnv : DEFAULT_TRANSACTIONAL_MAIL_ENDPOINT;
}

/** All app mail uses the transactional endpoint unless disabled (then Resend). */
function shouldUseTransactionalMail(): boolean {
  return Deno.env.get('TRANSACTIONAL_MAIL_ENABLED') !== 'false';
}

async function sendViaTransactionalMail(params: {
  to: string[];
  subject: string;
  innerHtml: string;
  text?: string;
  locale?: string;
  from?: string;
}): Promise<{ ok: boolean; error?: string; messageId?: string }> {
  const endpoint = getTransactionalMailEndpoint();
  const secret = Deno.env.get('TRANSACTIONAL_MAIL_SECRET') ?? '';

  try {
    const response = await fetch(endpoint, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        ...(secret ? { 'x-internal-email-secret': secret } : {}),
      },
      body: JSON.stringify({
        from: params.from || getDefaultFromEmail(),
        to: params.to,
        subject: params.subject,
        text: params.text ?? params.innerHtml.replace(/<[^>]*>/g, ''),
        innerHtml: params.innerHtml,
        html: params.innerHtml,
        locale: params.locale ?? 'it',
      }),
    });

    if (!response.ok) {
      const errBody = await response.text();
      console.error(`Transactional mail error (${response.status}):`, errBody);
      return { ok: false, error: `HTTP ${response.status}: ${errBody}` };
    }

    const result = await response.json() as Record<string, unknown>;
    const messageId = (result.messageId ?? result.id ?? 'sent') as string;
    return { ok: true, messageId };
  } catch (error) {
    console.error('Transactional mail fetch error:', error);
    return { ok: false, error: String(error) };
  }
}

export type SendEmailParams = {
  to: EmailRecipient;
  subject: string;
  html: string;
  text: string;
  /** Overrides default FabricOS / RESEND_FROM_EMAIL from address */
  from?: string;
  locale?: string;
  /** Extra headers on the outgoing message (Resend only; ignored for transactional mail) */
  resendHeaders?: Record<string, string>;
};

/**
 * Central mail dispatch: transactional endpoint (default centoimpianti) unless
 * TRANSACTIONAL_MAIL_ENABLED=false, then Resend if RESEND_API_KEY is set.
 * Returns false only when transactional is off and Resend is not configured.
 * Throws on provider HTTP / network failure.
 */
export async function sendEmail(params: SendEmailParams): Promise<boolean> {
  const toList = Array.isArray(params.to) ? params.to : [params.to];
  const from = params.from ?? getDefaultFromEmail();

  if (shouldUseTransactionalMail()) {
    console.log('📧 Sending via transactional mail to:', toList.join(', '), 'Subject:', params.subject);
    const result = await sendViaTransactionalMail({
      to: toList,
      subject: params.subject,
      innerHtml: params.html,
      text: params.text,
      from,
      locale: params.locale,
    });
    if (!result.ok) {
      throw new Error(result.error ?? 'Transactional mail failed');
    }
    return true;
  }

  const resendKey = Deno.env.get('RESEND_API_KEY') ?? '';
  if (!resendKey) {
    console.warn(
      'Email skipped: transactional disabled (TRANSACTIONAL_MAIL_ENABLED=false) and no RESEND_API_KEY',
    );
    return false;
  }

  const body: Record<string, unknown> = {
    from,
    to: toList,
    subject: params.subject,
    html: params.html,
    text: params.text,
  };
  if (params.resendHeaders && Object.keys(params.resendHeaders).length > 0) {
    body.headers = params.resendHeaders;
  }

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${resendKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    throw new Error(`Email failed (${response.status}): ${await response.text()}`);
  }

  return true;
}

export async function getCompanyNotificationRecipients(
  supabase: any,
  companyId: string,
) {
  const { data } = await supabase
    .from('users')
    .select('email')
    .eq('company_id', companyId)
    .in('role', ['admin', 'manager']);

  const rows = Array.isArray(data) ? data : data ? [data] : [];
  const emails = rows
    .map((row) => (row as { email?: string }).email?.toString().trim())
    .filter((email): email is string => Boolean(email));

  return [...new Set(emails)];
}

export async function sendCriticalAlertEmail(params: {
  supabase: any;
  companyId: string;
  subject: string;
  bodyTitle: string;
  bodyText: string;
  details: string[];
  linkLabel?: string;
  linkPath?: string;
}) {
  const recipients = await getCompanyNotificationRecipients(
    params.supabase,
    params.companyId,
  );
  if (recipients.length === 0) {
    console.warn(`Critical alert email skipped: no recipients for company ${params.companyId}`);
    return false;
  }

  const baseUrl = getAppBaseUrl();
  const linkPath = params.linkPath ?? '/app/alerts';
  const actionLink = `${baseUrl}${linkPath}`;
  const detailHtml = params.details.length
    ? `<ul style="margin: 0; padding-left: 20px; color: #CBD5E1;">${
      params.details.map((d) =>
        `<li style="margin-bottom: 10px;">${escapeHtml(d)}</li>`).join('')
    }</ul>`
    : '';
  const detailText = params.details.length ? `\n- ${params.details.join('\n- ')}` : '';

  const bodyHtml = `
    <p style="margin: 0 0 20px; color: #CBD5E1;">${escapeHtml(params.bodyText)}</p>
    ${detailHtml}
  `;

  return sendEmail({
    to: recipients,
    subject: params.subject,
    html: fabricEmailLayout({
      variant: 'danger',
      eyebrow: 'Alert operativo',
      title: params.bodyTitle,
      subtitle: 'È richiesta un’azione sul workspace',
      bodyHtml,
      primaryCta: {
        label: params.linkLabel ?? 'Apri FabricOS',
        url: actionLink,
      },
    }),
    text:
      `${params.bodyTitle}\n\n${params.bodyText}${detailText}\n\nApri ${actionLink} per intervenire.`,
  });
}
