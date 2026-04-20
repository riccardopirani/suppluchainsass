export type EmailRecipient = string | string[];

const appBaseUrl = (Deno.env.get('APP_BASE_URL') ?? 'http://localhost:3000').replace(/\/$/, '');

export function getAppBaseUrl() {
  return appBaseUrl;
}

export function getAdminContactEmail() {
  return Deno.env.get('ADMIN_CONTACT_EMAIL') ?? 'amministrazione@marconisoftware.com';
}

export function escapeHtml(value: string) {
  return value
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

export async function sendEmail(params: {
  to: EmailRecipient;
  subject: string;
  html: string;
  text: string;
}) {
  const resendKey = Deno.env.get('RESEND_API_KEY') ?? '';
  const fromEmail = Deno.env.get('RESEND_FROM_EMAIL') ?? '';
  if (!resendKey || !fromEmail) {
    console.warn('Email skipped: missing RESEND_API_KEY or RESEND_FROM_EMAIL');
    return false;
  }

  const response = await fetch('https://api.resend.com/emails', {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${resendKey}`,
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      from: fromEmail,
      to: Array.isArray(params.to) ? params.to : [params.to],
      subject: params.subject,
      html: params.html,
      text: params.text,
    }),
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
    ? `<ul style="margin: 16px 0; padding-left: 20px;">${
        params.details.map((d) => `<li style="margin-bottom: 8px;">${escapeHtml(d)}</li>`).join('')
      }</ul>`
    : '';
  const detailText = params.details.length ? `\n- ${params.details.join('\n- ')}` : '';

  return sendEmail({
    to: recipients,
    subject: params.subject,
    html: `
      <div style="font-family: Arial, sans-serif; line-height: 1.5; color: #0f172a;">
        <h2 style="margin: 0 0 12px;">${escapeHtml(params.bodyTitle)}</h2>
        <p style="margin: 0 0 12px;">${escapeHtml(params.bodyText)}</p>
        ${detailHtml}
        <a href="${actionLink}" style="display:inline-block;background:#dc2626;color:#ffffff;text-decoration:none;padding:12px 18px;border-radius:8px;">
          ${params.linkLabel ?? 'Apri FabricOS'}
        </a>
      </div>
    `,
    text:
      `${params.bodyTitle}\n\n${params.bodyText}${detailText}\n\nApri ${actionLink} per intervenire.`,
  });
}
