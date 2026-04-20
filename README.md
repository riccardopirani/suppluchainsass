# FabricOS

AI-assisted operations platform for small-to-mid manufacturing teams (roughly 10–500 employees). Single Flutter codebase for **responsive web** and **native iOS/Android**, backed by Supabase.

---

## Tech stack

| Layer | Choice |
|--------|--------|
| Client | Flutter, Riverpod, go_router |
| Backend | Supabase (Postgres, Auth, Realtime, Storage, Edge Functions) |
| Web billing | Stripe Checkout & Customer Portal |
| Mobile billing | In-app purchases (StoreKit / Google Play) + `register-mobile-purchase` Edge Function |
| Charts | fl_chart |
| PDF | pdf + printing |
| Local config | `.env` + `scripts/flutter_with_env.sh` (wraps Flutter with `--dart-define`) |

---

## Public marketing site

Unauthenticated routes using the marketing shell (`WebsiteLayout`):

- **Home**, **Features**, **Pricing**, **Contact**
- **FAQ**, **Privacy**, **Terms**, **Cookies**
- **ROI calculator** (`/roi-calculator`)
- **Factory score / audit** (`/factory-score`; `/factory-audit` redirects here)
- **Book a demo** (`/book-demo`)
- **Case studies** (`/case-studies`)

---

## Authentication & workspace

- **Login**, **Register**, **Forgot password** (Supabase email/password)
- **Multi-step onboarding**: company profile, plants, machines, pain points, ROI preview; workspace bootstrap via **`bootstrap-company`**
- **Multi-tenant model**: `companies` workspace, `users` profiles linked to `auth.users`
- **Roles & permissions** via the **Team** module
- **`/app`** routes require login; onboarding must be completed before modules unlock

---

## Authenticated app (`/app`)

Shell with sidebar (wide) / drawer (narrow), dark “control room” styling, **i18n** (EN, IT, ES, FR, DE, RU, ZH plus marketing overlays in `pub_*.json`).

### Plans & access

- **Subscription gate** when there is no active trial/subscription (CTA to **Billing**)
- **Tiered plans** (Starter, Growth, Pro, Enterprise) with entitlement differences
- **Billing**: **Stripe** on web; **native store billing** on iOS/Android, synced to Postgres via **`register-mobile-purchase`**

### Dashboard

- Operational KPIs (orders, machines, suppliers, alerts)
- Executive-style charts, insights, and quick actions

### Supply chain & operations

- **Supply dashboard** — end-to-end supply snapshot
- **Inventory** — stock levels, safety and reorder thresholds
- **Shipments** — shipment tracking
- **Machines** — registry, status, maintenance logs, simulated telemetry
- **Orders** — pipeline and delay tracking
- **Suppliers** — directory plus **supplier detail** (performance / risk)
- **What-if lab / simulation** — scenario playground

### AI & automation

- **AI Control Tower** — operational risk hub; links e.g. to executive reporting
- **Forecasting** — demand / metric forecasts
- **Fabric Copilot** — in-shell assistant sheet
- Internal engines (e.g. **auto-actions**) for threshold-driven suggestions (reorder, maintenance flags, etc.)

### Reporting & leadership

- **Reports / ESG** — compliance-style reporting with **PDF export**
- **Executive / CEO report** — leadership summary

### Organization

- **Team & permissions** — members and workspace access
- **Settings** — user/app preferences

### Additional modules in the repo

The codebase also includes screens for **products**, **warehouses**, **purchase orders**, **alerts**, **analytics**, and **reorder suggestions**. Wire them into `go_router` or embed from other views as the product evolves.

---

## Supabase schema (high level)

Representative tables (RLS by tenant via `current_company_id()` where applicable):

- `companies`, `users`, `machines`, `machine_telemetry`, `maintenance_logs`
- `orders`, `suppliers`, `alerts`, `esg_reports`
- Warehouse / inventory / shipments (per migrations)
- **`subscriptions`** including metadata (e.g. Stripe vs **IAP** source)

Realtime enabled for selected tables (e.g. alerts, machines).

---

## Edge Functions

All functions live under `supabase/functions/`. Deploy with the Supabase CLI; **`deploy.sh`** pushes every function with **`--no-verify-jwt`** at the gateway—each handler must enforce auth, Stripe signatures, or other checks as needed.

| Function | Typical role |
|----------|----------------|
| `accept-invitation` | Accept team invite |
| `analyze-order-risks` | Order delays & alerts |
| `analyze-supplier-risk` | Supplier risk scoring |
| `auto-replenishment` | Replenishment logic |
| `bootstrap-company` | Create workspace & starter data |
| `create-stripe-checkout-session` | Stripe Checkout |
| `create-stripe-portal-session` | Stripe Customer Portal |
| `detect-disruptions` | Disruption detection |
| `generate-esg-report` | ESG reporting |
| `generate-forecast` | Forecasting |
| `generate-reorder-recommendations` | Reorder suggestions |
| `invite-user` | User invitations |
| `optimize-costs` | Cost optimization |
| `optimize-inventory` | Inventory optimization |
| `predict-demand` | Demand signals |
| `predict-maintenance-risk` | Maintenance risk |
| `process-import` | Data imports |
| `register-mobile-purchase` | Register IAP & upsert subscription |
| `run-simulation` | Scenario simulation |
| `seed-demo-workspace` | Demo / seed |
| `send-alerts` | Alert delivery |
| `stripe-webhook` | Stripe events |
| `submit-contact-form` | Marketing contact form |
| `sync-warehouse-inventory` | Warehouse inventory sync |

---

## Seed data

- **`supabase/seed.sql`** — sample company, machines, orders, suppliers, alerts, ESG rows, etc.  
  Run in the Supabase SQL Editor (or CLI) after migrations.

---

## Quick start

### 1) Install dependencies

```bash
flutter pub get
```

### 2) Configure environment

Copy **`.env.example`** → **`.env`** and set at least:

- Supabase URL and anon/publishable key (`SUPABASE_URL` / `NEXT_PUBLIC_SUPABASE_URL`, `SUPABASE_ANON_KEY` or aliases in `.env.example`)
- For deploy scripts: `SUPABASE_SERVICE_ROLE_KEY`, `SUPABASE_ACCESS_TOKEN`, `SUPABASE_DB_PASSWORD`, `SUPABASE_PROJECT_REF`
- For renewal reminder emails: `RESEND_API_KEY` and `RESEND_FROM_EMAIL`

### 3) Run Flutter (recommended)

```bash
./scripts/flutter_with_env.sh run -d chrome
```

Use another device id for iOS/Android simulators or devices.

### 4) Migrate database & deploy Edge Functions

```bash
set -a && source .env && set +a
./scripts/deploy_supabase_all.sh
```

Functions-only deploy:

```bash
export SUPABASE_PROJECT_REF=your-ref
./deploy.sh
```

### 5) Seed demo data

Execute **`supabase/seed.sql`** in the Supabase SQL Editor (or via CLI).

---

## Project layout ( indicative )

```text
lib/
  app/
  config/              # env resolution, plan catalog, IAP product ids
  routing/
  features/
    website/           # marketing
    auth/
    onboarding/
    app_shell/         # navigation, Copilot entry
    dashboard/
    control_tower/
    executive/
    forecasting/
    supply_chain/
    machines/
    orders/
    suppliers/
    reports/
    billing/
    team/
    settings/
    copilot/
    …                  # products, warehouses, POs, alerts, analytics, reorder, …
supabase/
  migrations/
  functions/
  seed.sql
scripts/
  deploy_supabase_all.sh   # link, db push, secrets, deploy all functions
  flutter_with_env.sh
deploy.sh                  # deploy all edge functions
```

---

## Notes

- Several “AI” flows use deterministic or simulated logic today; hooks exist for real models and external APIs.
- **Dark mode** and responsive layouts are supported.
- Architecture is modular—ready for real IoT ingestion, ERP connectors, and heavier ML where needed.
