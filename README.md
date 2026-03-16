# StockGuard AI

**Il pilota automatico del magazzino.**

Evita rotture di stock e capitale fermo in magazzino. Ti diciamo cosa riordinare, quando riordinarlo e quanto comprarne.

- **Flutter** app (Web, iOS, Android)
- **Supabase** (Postgres, Auth, Storage, Edge Functions)
- **Stripe** for billing and subscriptions
- **Multilingual**: EN, IT, ES, FR, DE

---

## Quick start

### Prerequisites

- Flutter 3.19+
- Dart 3.3+
- Supabase CLI (optional, for local Supabase)
- Node/Deno for Edge Functions

### 1. Clone and install

```bash
cd sass_supply_chain
flutter pub get
```

### 2. Environment

Copy `.env.example` to `.env` and set:

- `SUPABASE_URL` – your Supabase project URL
- `SUPABASE_ANON_KEY` – anon/publishable key
- `SUPABASE_SERVICE_ROLE_KEY` – service role (or `sb_secret_...`) for Edge Functions
- `SUPABASE_ACCESS_TOKEN` – Supabase CLI personal access token
- `SUPABASE_DB_PASSWORD` – remote Postgres password
- `STRIPE_PUBLISHABLE_KEY` – Stripe publishable key (Flutter)
- Price IDs for Starter/Growth/Pro (monthly/yearly) if using billing

For local runs without Supabase, the app uses placeholder values and will still load (auth and data will fail until configured).

### 3. Run the app

**Web**

```bash
flutter run -d chrome
```

Or load Supabase values from `.env` automatically:

```bash
./scripts/flutter_with_env.sh run -d chrome
```

**iOS**

```bash
flutter run -d ios
```

**Android**

```bash
flutter run -d android
```

Pass env vars when needed:

```bash
flutter run -d chrome --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=xxx
```

---

## Supabase setup

1. Create a project at [supabase.com](https://supabase.com).
2. Deploy all (migrations + function secrets + all edge functions):

```bash
set -a
source .env
set +a
./scripts/deploy_supabase_all.sh
```

3. Or run manually:

```bash
supabase link --project-ref YOUR_REF
supabase db push
```

Or run the SQL in `supabase/migrations/` manually in the SQL Editor (in order: `20260101000001_initial_schema.sql`, then `20260101000002_rls.sql`).

4. (Optional) Seed:

Run `supabase/seed.sql` in the Supabase SQL Editor.

5. Enable Email auth in Authentication → Providers.
6. In Storage, create a bucket for imports if you use file uploads.

---

## Edge Functions

Deploy:

```bash
supabase functions deploy create-stripe-checkout-session --no-verify-jwt
supabase functions deploy create-stripe-portal-session
supabase functions deploy stripe-webhook --no-verify-jwt
supabase functions deploy submit-contact-form --no-verify-jwt
supabase functions deploy process-import
supabase functions deploy generate-reorder-recommendations
supabase functions deploy generate-forecast
supabase functions deploy seed-demo-workspace
supabase functions deploy accept-invitation
supabase functions deploy send-alerts
```

Set secrets:

```bash
supabase secrets set STRIPE_SECRET_KEY=sk_xxx
supabase secrets set STRIPE_WEBHOOK_SECRET=whsec_xxx
supabase secrets set APP_BASE_URL=https://your-app.com
```

**Stripe webhook**: In Stripe Dashboard → Developers → Webhooks, add endpoint  
`https://YOUR_REF.supabase.co/functions/v1/stripe-webhook`  
and subscribe to: `checkout.session.completed`, `customer.subscription.created`, `customer.subscription.updated`, `customer.subscription.deleted`. Use the signing secret as `STRIPE_WEBHOOK_SECRET`.

---

## Stripe setup

1. Create Products and Prices in Stripe for Starter, Growth, Pro (monthly and yearly).
2. Put the Price IDs in your env / dart-defines:
   - `STRIPE_STARTER_MONTHLY_PRICE_ID`, `STRIPE_STARTER_YEARLY_PRICE_ID`
   - `STRIPE_GROWTH_*`, `STRIPE_PRO_*`
3. Configure the Customer Portal in Stripe for self-service subscription management.
4. Webhook: see Edge Functions section above.

---

## Project structure

```
lib/
  app/                 # App widget
  config/               # Env / config
  core/theme/           # Theme, colors, dimensions
  localization/         # i18n (EN, IT, ES, FR, DE)
  routing/              # GoRouter
  features/
    auth/               # Login, register, forgot password
    website/            # Marketing: home, pricing, contact, legal
    app_shell/          # Sidebar, bottom nav
    dashboard/          # Main dashboard
    onboarding/         # Post-signup onboarding
    products/           # Products list & detail
    reorder/            # Reorder suggestions
    forecasting/        # Demand forecast
    suppliers/          # Suppliers
    alerts/             # Alerts center
    purchase_orders/    # POs
    analytics/          # Analytics
    billing/            # Billing & subscription
    settings/           # Settings, profile, language
supabase/
  migrations/           # Postgres schema + RLS
  functions/            # Edge Functions (Deno)
  seed.sql              # Demo seed
```

---

## Deployment

### Flutter Web

Build:

```bash
flutter build web --dart-define=SUPABASE_URL=xxx --dart-define=SUPABASE_ANON_KEY=xxx
```

Deploy the `build/web` folder to Vercel, Netlify, Firebase Hosting, or any static host. Set base href if needed:

```bash
flutter build web --base-href /app/ --dart-define=...
```

### iOS / Android

Use standard Flutter build and submit to App Store / Play Store. Configure env through your CI or `--dart-define` in the build step.

---

## License

Proprietary. All rights reserved.
# suppluchainsass
