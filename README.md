# FabricOS

AI-powered operations platform for small-to-mid manufacturing companies (10-500 employees).

FabricOS MVP includes:
- Predictive maintenance
- Orders & supply chain tracking
- Supplier monitoring
- ESG/compliance reporting with PDF export

## Tech Stack
- Frontend: Flutter (web-first, responsive)
- Backend: Supabase (Postgres, Auth, Realtime, Storage, Edge Functions)
- State management: Riverpod
- Charts: fl_chart
- PDF export: pdf + printing

## MVP Modules
1. Dashboard
- Active orders KPI
- Machine status KPI
- Supplier delays KPI
- Realtime AI alerts panel

2. Predictive Maintenance
- Machines registry
- Maintenance logs
- Simulated IoT telemetry
- AI placeholder failure-risk scoring

3. Orders & Supply Chain
- Orders CRUD (pending, in_progress, completed)
- Delivery date tracking and delay detection
- AI risk scan for delayed orders

4. Suppliers
- Supplier database
- Performance score (reliability and delays)
- Risk indicator

5. ESG / Compliance
- Monthly ESG snapshots (mock data)
- Emissions and supplier compliance metrics
- PDF report export

## Auth, Multi-Tenant, Roles
- Supabase Auth (email/password)
- `companies` workspace model
- `users` profile table linked to `auth.users`
- Roles: `admin`, `manager`, `operator`

## Supabase Schema (Public)
Core tables:
- `companies`
- `users`
- `machines`
- `machine_telemetry`
- `maintenance_logs`
- `orders`
- `suppliers`
- `alerts`
- `esg_reports`

All tenant tables are protected by RLS using `current_company_id()`.
Realtime publication is enabled for:
- `alerts`
- `machines`

## Seed Data
`supabase/seed.sql` inserts:
- 1 company
- 5 machines
- 10 orders
- 5 suppliers
- sample alerts, maintenance logs and ESG reports

## Edge Functions (Examples)
- `bootstrap-company`: create company workspace and starter data
- `predict-maintenance-risk`: mock AI risk prediction from telemetry
- `analyze-order-risks`: detect delayed orders and create AI alerts
- `generate-esg-report`: build monthly ESG/compliance report row

## Quick Start
### 1) Install dependencies
```bash
flutter pub get
```

### 2) Configure environment
Copy `.env.example` to `.env` and set at least:
- `SUPABASE_URL`
- `SUPABASE_ANON_KEY`
- `SUPABASE_SERVICE_ROLE_KEY`
- `SUPABASE_ACCESS_TOKEN`
- `SUPABASE_DB_PASSWORD`

### 3) Run Flutter web
```bash
flutter run -d chrome
```

Or with env helper:
```bash
./scripts/flutter_with_env.sh run -d chrome
```

### 4) Push DB + deploy edge functions
```bash
set -a
source .env
set +a
./scripts/deploy_supabase_all.sh
```

### 5) Seed demo data
Run `supabase/seed.sql` in Supabase SQL Editor (or via CLI SQL execution).

## Project Structure
```text
lib/
  app/
  config/
  core/theme/
  routing/
  features/
    auth/
    onboarding/
    app_shell/
    dashboard/
    machines/
    orders/
    suppliers/
    reports/
    website/
supabase/
  migrations/
  functions/
  seed.sql
```

## Notes
- This MVP uses deterministic AI placeholders (OpenAI-style integration points are prepared in edge functions).
- Dark mode is supported via system theme.
- Architecture is modular and ready to extend with real IoT ingestion, external ERP connectors, and advanced ML models.
