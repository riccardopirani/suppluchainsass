import { escapeHtml } from './html_escape.ts';

/** Matches auth shell: deep slate + blue glow accents */
const COLORS = {
  pageBg: '#030712',
  pageBg2: '#0B1220',
  cardBg: 'rgba(255,255,255,0.04)',
  cardBorder: 'rgba(255,255,255,0.12)',
  text: '#F9FAFB',
  muted: '#CBD5E1',
  dim: 'rgba(255,255,255,0.45)',
  accent: '#93C5FD',
  cta: '#2563EB',
  ctaGlow: 'rgba(37, 99, 235, 0.35)',
};

export type FabricEmailVariant = 'brand' | 'success' | 'warning' | 'danger';

function heroGradient(variant: FabricEmailVariant): string {
  switch (variant) {
    case 'success':
      return 'linear-gradient(135deg, #059669 0%, #10b981 50%, #34d399 100%)';
    case 'warning':
      return 'linear-gradient(135deg, #d97706 0%, #f59e0b 45%, #fbbf24 100%)';
    case 'danger':
      return 'linear-gradient(135deg, #dc2626 0%, #ef4444 55%, #f87171 100%)';
    default:
      return 'linear-gradient(135deg, #1d4ed8 0%, #2563eb 40%, #3b82f6 70%, #0ea5e9 100%)';
  }
}

export type FabricEmailLayoutOptions = {
  lang?: string;
  eyebrow?: string;
  title: string;
  subtitle?: string;
  /** Trusted inner HTML (paragraphs, lists). Use escapeHtml() for user strings. */
  bodyHtml: string;
  primaryCta?: { label: string; url: string };
  secondaryLink?: { label: string; url: string };
  variant?: FabricEmailVariant;
  /** Optional highlighted box below body (HTML) */
  calloutHtml?: string;
  footerNote?: string;
};

/**
 * Table-based, dark-theme marketing layout aligned with FabricOS auth UI.
 */
export function fabricEmailLayout(opts: FabricEmailLayoutOptions): string {
  const lang = opts.lang ?? 'it';
  const variant = opts.variant ?? 'brand';
  const hero = heroGradient(variant);
  const eyebrow = opts.eyebrow
    ? `
            <tr>
              <td style="padding: 0 0 20px;">
                <span style="display: inline-block; padding: 6px 14px; border-radius: 999px; background: rgba(37,99,235,0.2); border: 1px solid rgba(147,197,253,0.35); font-size: 11px; font-weight: 700; letter-spacing: 0.06em; text-transform: uppercase; color: ${COLORS.accent}; font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;">
                  ${escapeHtml(opts.eyebrow)}
                </span>
              </td>
            </tr>`
    : '';
  const subtitle = opts.subtitle
    ? `
                    <p style="margin: 14px 0 0; font-size: 17px; line-height: 1.55; color: rgba(255,255,255,0.88); font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;">
                      ${escapeHtml(opts.subtitle)}
                    </p>`
    : '';

  const callout = opts.calloutHtml
    ? `
                <tr>
                  <td style="padding: 0 40px 32px;">
                    <div style="background: rgba(37, 99, 235, 0.12); border: 1px solid rgba(147, 197, 253, 0.25); border-radius: 14px; padding: 18px 22px; font-size: 14px; line-height: 1.6; color: ${COLORS.muted}; font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;">
                      ${opts.calloutHtml}
                    </div>
                  </td>
                </tr>`
    : '';

  const primaryCta = opts.primaryCta
    ? `
                    <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="margin-top: 8px;">
                      <tr>
                        <td align="center">
                          <a href="${opts.primaryCta.url}" style="display: inline-block; background: ${COLORS.cta}; color: #ffffff; font-size: 16px; font-weight: 700; text-decoration: none; padding: 16px 40px; border-radius: 12px; box-shadow: 0 8px 28px ${COLORS.ctaGlow}; font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;">
                            ${escapeHtml(opts.primaryCta.label)}
                          </a>
                        </td>
                      </tr>
                    </table>`
    : '';

  const secondary = opts.secondaryLink
    ? `
                <tr>
                  <td style="padding: 28px 40px 36px; text-align: center;">
                    <a href="${opts.secondaryLink.url}" style="font-size: 14px; color: ${COLORS.accent}; text-decoration: underline; font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;">
                      ${escapeHtml(opts.secondaryLink.label)}
                    </a>
                  </td>
                </tr>`
    : `
                <tr>
                  <td style="padding: 0 40px 36px;"></td>
                </tr>`;

  const footerExtra = opts.footerNote
    ? `<p style="margin: 8px 0 0; font-size: 12px; color: ${COLORS.dim}; max-width: 420px; margin-left: auto; margin-right: auto; line-height: 1.5;">${opts.footerNote}</p>`
    : '';

  return `<!DOCTYPE html>
<html lang="${escapeHtml(lang)}">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta http-equiv="X-UA-Compatible" content="IE=edge">
</head>
<body style="margin: 0; padding: 0; background: ${COLORS.pageBg}; font-family: system-ui, -apple-system, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
  <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background: linear-gradient(165deg, ${COLORS.pageBg} 0%, ${COLORS.pageBg2} 45%, ${COLORS.pageBg} 100%);">
    <tr>
      <td align="center" style="padding: 40px 16px 48px;">
        <table role="presentation" width="600" cellspacing="0" cellpadding="0" style="max-width: 600px; width: 100%;">
          <tr>
            <td style="padding-bottom: 28px;">
              <table role="presentation" cellspacing="0" cellpadding="0">
                <tr>
                  <td style="background: linear-gradient(135deg, rgba(37,99,235,0.35) 0%, rgba(14,165,233,0.2) 100%); border-radius: 14px; padding: 14px 22px; border: 1px solid rgba(147,197,253,0.25);">
                    <span style="font-size: 22px; font-weight: 800; letter-spacing: -0.03em; color: #ffffff;">Fabric</span><span style="font-size: 22px; font-weight: 300; color: rgba(255,255,255,0.85);">OS</span>
                  </td>
                </tr>
              </table>
            </td>
          </tr>
          ${eyebrow}
          <tr>
            <td>
              <table role="presentation" width="100%" cellspacing="0" cellpadding="0" style="background: ${COLORS.cardBg}; border-radius: 20px; border: 1px solid ${COLORS.cardBorder}; overflow: hidden; backdrop-filter: blur(8px);">
                <tr>
                  <td style="background: ${hero}; padding: 44px 36px 40px; text-align: center;">
                    <h1 style="margin: 0; font-size: 28px; font-weight: 800; letter-spacing: -0.04em; line-height: 1.15; color: #ffffff; font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;">
                      ${escapeHtml(opts.title)}
                    </h1>
                    ${subtitle}
                  </td>
                </tr>
                <tr>
                  <td style="padding: 36px 40px 28px; color: ${COLORS.muted}; font-size: 16px; line-height: 1.65; font-family: system-ui, -apple-system, 'Segoe UI', Roboto, sans-serif;">
                    ${opts.bodyHtml}
                    ${primaryCta}
                  </td>
                </tr>
                ${callout}
                ${secondary}
              </table>
            </td>
          </tr>
          <tr>
            <td style="padding: 32px 16px 24px; text-align: center;">
              <p style="margin: 0 0 20px; font-size: 12px; color: ${COLORS.dim};">© ${new Date().getFullYear()} FabricOS · Supply chain intelligence</p>
              <div style="margin: 0 auto; max-width: 520px; padding: 20px 16px 0; border-top: 1px solid rgba(255,255,255,0.1);">
                <p style="margin: 0 0 12px; font-size: 11px; font-weight: 700; letter-spacing: 0.04em; color: rgba(255,255,255,0.45);">
                  DATI DELLA SOCIETÀ - MARCONI SOFTWARE S.R.L.
                </p>
                <p style="margin: 0 0 8px; font-size: 11px; line-height: 1.6; color: ${COLORS.dim};">
                  <strong style="color: rgba(255,255,255,0.5);">Rag. Sociale:</strong> MARCONI SOFTWARE S.R.L.
                </p>
                <p style="margin: 0 0 8px; font-size: 11px; line-height: 1.6; color: ${COLORS.dim};">
                  <strong style="color: rgba(255,255,255,0.5);">Partita IVA:</strong> 02190840385
                  &nbsp;·&nbsp;
                  <strong style="color: rgba(255,255,255,0.5);">Codice Fiscale:</strong> 02190840385
                </p>
                <p style="margin: 0; font-size: 11px; line-height: 1.6; color: ${COLORS.dim};">
                  <strong style="color: rgba(255,255,255,0.5);">VAT Europeo:</strong> IT02190840385
                </p>
              </div>
              ${footerExtra}
            </td>
          </tr>
        </table>
      </td>
    </tr>
  </table>
</body>
</html>`;
}
