# FabricOS Growth Blueprint 2026

Scope: product expansion strategy + architecture blueprint for multi-tenant B2B manufacturing SaaS (10-2000 employees, EU first).

## Part 1 - New In-App Features

### 1) Plant Floor Mode
- **Problem solved**: "I need to log production and machine events in seconds, even during shift pressure."
- **Segment unlocked**: Labor-intensive plants, contract manufacturing, low-digitalized SMEs.
- **Minimum plan**: Growth.
- **Impact / Effort**: High / Medium.
- **Dependencies**: `shift_signatures`, `production_quick_logs` tables; QR scan SDK; Edge Functions `submit-quick-log`, `verify-shift-signature`.
- **UI mockup (main)**:
  1. Today shift card (line, target, progress)
  2. Big action buttons (Start/Stop machine, Log scrap, Log downtime)
  3. QR scanner docked action
  4. Last 5 events timeline
  5. End-shift digital signature panel

### 2) Production Planning & Scheduling
- **Problem solved**: "I cannot optimize machine loading and delivery dates across all work orders."
- **Segment unlocked**: Discrete manufacturing, metalworking, electronics.
- **Minimum plan**: Pro.
- **Impact / Effort**: High / High.
- **Dependencies**: `work_orders`, `work_order_operations`, `resources`, `bom_headers`, `routing_steps`; Edge Functions `schedule-work-orders`, `recompute-oee`.
- **UI mockup (main)**:
  1. Gantt board (line/machine lanes)
  2. Drag/drop order cards with conflicts
  3. WIP bottleneck panel
  4. OEE by line widget
  5. Publish schedule CTA

### 3) Quality Management (QMS lite)
- **Problem solved**: "Non-conformities are scattered and CAPA follow-up is unreliable."
- **Segment unlocked**: Pharma, food & beverage, automotive suppliers.
- **Minimum plan**: Pro.
- **Impact / Effort**: High / Medium.
- **Dependencies**: `nonconformities`, `inspections`, `inspection_templates`, `corrective_actions`; file storage for CoA/certificates; Edge Function `open-capa`.
- **UI mockup (main)**:
  1. NC queue by severity
  2. Inspection form runner
  3. CAPA kanban
  4. Defect Pareto chart
  5. Certificate attachment drawer

### 4) Compliance & Traceability
- **Problem solved**: "I cannot prove lot genealogy quickly during audits/recalls."
- **Segment unlocked**: Food, pharma, cosmetics, medical devices.
- **Minimum plan**: Enterprise.
- **Impact / Effort**: High / High.
- **Dependencies**: `lot_tracking`, `supply_chain_events`, `recall_events`, `recall_lots`; GS1/QR standards; Edge Function `run-recall-simulation`.
- **UI mockup (main)**:
  1. Lot search bar + status chip
  2. End-to-end genealogy graph
  3. Expiry risk list
  4. Recall simulator wizard
  5. Audit export center (ISO/HACCP/FDA)

### 5) Energy & Sustainability
- **Problem solved**: "I do not know energy/carbon impact by line or product."
- **Segment unlocked**: EU regulated manufacturers, enterprise supply chains.
- **Minimum plan**: Pro (Scope 1/2), Enterprise (Scope 3 + ESG package).
- **Impact / Effort**: Medium-High / High.
- **Dependencies**: IoT ingestion; `energy_readings`, `emission_factors`, `esg_targets`; Edge Functions `aggregate-energy-kpis`, `generate-esg-report`.
- **UI mockup (main)**:
  1. Consumption heatmap by plant/line
  2. Carbon per lot/product KPI cards
  3. Scope 1/2/3 tracker
  4. Alert thresholds
  5. ESG report export

### 6) Multi-Plant Management
- **Problem solved**: "I cannot benchmark and coordinate multiple plants in one control plane."
- **Segment unlocked**: Industrial groups and holdings.
- **Minimum plan**: Enterprise.
- **Impact / Effort**: High / Medium.
- **Dependencies**: `plants`, `user_plant_roles`, inter-plant transfer entities; Edge Function `aggregate-group-kpis`.
- **UI mockup (main)**:
  1. Plant switcher + global filters
  2. Group KPI cockpit
  3. Inter-plant transfer board
  4. Plant benchmark table
  5. Consolidated P&O export

### 7) Customer Portal (B2B)
- **Problem solved**: "My key customers ask production visibility but we manage updates manually."
- **Segment unlocked**: Manufacturers selling to enterprise buyers/OEMs.
- **Minimum plan**: Pro.
- **Impact / Effort**: Medium-High / Medium.
- **Dependencies**: B2B guest auth model; `customer_portal_accounts`, `customer_portal_threads`; Edge Functions `publish-customer-order-view`.
- **UI mockup (main)**:
  1. Customer order timeline
  2. Document vault (DDT, invoice, CoA)
  3. ETA & milestone tracker
  4. Secure chat widget
  5. Notification center

### 8) Workforce & Shift Management
- **Problem solved**: "Shift planning and operator-task assignment are manual and error-prone."
- **Segment unlocked**: Shift-based plants, labor-intensive industries.
- **Minimum plan**: Growth.
- **Impact / Effort**: Medium-High / Medium.
- **Dependencies**: `shifts`, `attendance_events`, `skills_matrix`, `shift_tasks`; payroll export adapters; Edge Function `export-payroll-batch`.
- **UI mockup (main)**:
  1. Shift roster calendar
  2. Skill coverage checker
  3. Task assignment per shift
  4. Attendance anomalies list
  5. Payroll export button

### 9) Vendor Portal
- **Problem solved**: "Supplier confirmations and docs are unmanaged across email threads."
- **Segment unlocked**: Procurement-mature companies with complex supplier base.
- **Minimum plan**: Growth.
- **Impact / Effort**: High / Medium.
- **Dependencies**: `vendor_portal_users`, `vendor_order_confirmations`, `vendor_documents`, supplier scoring model; Edge Function `compute-vendor-score`.
- **UI mockup (main)**:
  1. Open POs requiring action
  2. Confirm quantity/date panel
  3. Upload docs (DDT, invoices, CoA)
  4. Delivery tracking status
  5. Supplier scorecard

### 10) Mobile Offline Sync
- **Problem solved**: "I lose data entry when factory connectivity is unstable."
- **Segment unlocked**: Remote plants, OT-segregated environments.
- **Minimum plan**: Growth.
- **Impact / Effort**: High / High.
- **Dependencies**: local store (SQLite/Drift), sync queue, conflict strategy; Edge Function `sync-batch-apply`.
- **UI mockup (main)**:
  1. Sync status badge
  2. Pending changes queue
  3. Conflict resolver dialog
  4. Last successful sync timestamp
  5. Force sync action

### 11) Custom Workflow Builder
- **Problem solved**: "Approval rules are not codified and compliance is inconsistent."
- **Segment unlocked**: Process-heavy mid-market and enterprise.
- **Minimum plan**: Enterprise.
- **Impact / Effort**: High / High.
- **Dependencies**: `workflow_definitions`, `workflow_instances`, `workflow_actions`; rule engine; Edge Function `evaluate-workflow-trigger`.
- **UI mockup (main)**:
  1. Trigger builder (event + conditions)
  2. Approval steps canvas
  3. SLA and escalation setup
  4. Notification routing
  5. Versioned publish panel

### 12) Advanced Analytics & BI
- **Problem solved**: "Leadership cannot self-serve actionable cross-functional insights."
- **Segment unlocked**: COO/CFO-led organizations and enterprise buyers.
- **Minimum plan**: Pro.
- **Impact / Effort**: High / Medium-High.
- **Dependencies**: semantic metrics layer, `saved_reports`, `report_schedules`; Edge Functions `refresh-kpi-cubes`, `deliver-scheduled-report`.
- **UI mockup (main)**:
  1. Drag-and-drop report builder
  2. KPI custom formula editor
  3. Drill-down tree (group > plant > line > SKU)
  4. Compare period control
  5. Scheduled export center

## Part 2 - Public Marketing Pages

### A) Vertical landing pages (Food, Pharma, Metalworking, Automotive Tier 2, Textile, EMS)
- **Primary conversion goal**: Book qualified vertical demo.
- **Key content**: sector headline; pain points; relevant feature blocks; vertical case study; supported compliance logos.
- **Primary / secondary CTA**: "Book sector demo" / "Download sector playbook".
- **SEO long-tail targets**:
  - manufacturing operations software for [sector]
  - production traceability software [sector]
  - supply chain platform for [sector] SMEs Europe
  - OEE and quality management software [sector]
  - digital factory software [country] [sector]
- **Visitor target**: COO/plant manager by industry.

### B) Integrations page
- **Primary conversion goal**: Integration-qualified leads + partner handoff.
- **Key content**: connector catalog, ERP/WMS/MES/IoT/accounting tabs, "planned" roadmap lane, partner badges.
- **Primary / secondary CTA**: "Request integration" / "View API docs".
- **SEO long-tail targets**:
  - manufacturing saas integrations sap business one
  - supabase erp integration platform for factories
  - odoo manufacturing integration tool
  - azure iot manufacturing analytics integration
- **Visitor target**: IT manager, solution architect, SI partner.

### C) Trust & compliance page
- **Primary conversion goal**: De-risk enterprise procurement.
- **Key content**: security posture, SOC2 roadmap, GDPR/data residency, uptime SLA, pen test summary, subprocessors.
- **Primary / secondary CTA**: "Request security package" / "Talk to security team".
- **SEO long-tail targets**:
  - manufacturing saas gdpr compliant europe
  - secure factory operations platform
  - multi tenant manufacturing software data residency
  - iso 27001 roadmap saas manufacturing
- **Visitor target**: IT manager, DPO, procurement security reviewers.

### D) ROI Calculator V2
- **Primary conversion goal**: MQL capture with quantified business case.
- **Key content**: industry-adjusted assumptions, savings model, payback chart, branded PDF output.
- **Primary / secondary CTA**: "Generate ROI report" / "Validate assumptions with expert".
- **SEO long-tail targets**:
  - manufacturing software roi calculator
  - reduce machine downtime cost calculator
  - supply chain digitization roi for sme
  - factory digital transformation payback tool
- **Visitor target**: COO/CFO, transformation lead.

### E) Partner & reseller page
- **Primary conversion goal**: Recruit SI/reseller partners.
- **Key content**: tier benefits, revenue share, enablement, co-selling process, portal preview.
- **Primary / secondary CTA**: "Apply as partner" / "Download partner kit".
- **SEO long-tail targets**:
  - manufacturing software reseller program europe
  - erp consultant partnership manufacturing saas
  - system integrator industrial software partnership
- **Visitor target**: SI, ERP consultants, VARs.

### F) Academy / Knowledge hub
- **Primary conversion goal**: Organic traffic + email nurture.
- **Key content**: blog clusters, recorded webinars, glossary, downloadable templates.
- **Primary / secondary CTA**: "Subscribe updates" / "Download templates".
- **SEO long-tail targets**:
  - preventive maintenance plan template xls
  - iso audit checklist manufacturing
  - oee improvement guide for small factories
  - manufacturing supply chain kpi examples
- **Visitor target**: operations practitioners and evaluators at awareness stage.

### G) Pricing page V2
- **Primary conversion goal**: self-serve conversion and plan clarity.
- **Key content**: monthly/annual toggle, feature matrix, seat/machine estimator, pricing FAQ, enterprise chat.
- **Primary / secondary CTA**: "Start free trial" / "Talk to sales".
- **SEO long-tail targets**:
  - manufacturing saas pricing per user per machine
  - oee software pricing for sme
  - supply chain and maintenance platform pricing
  - b2b factory management software cost
- **Visitor target**: founder/COO/ops manager evaluating purchase.

### H) Factory Score / Audit tool
- **Primary conversion goal**: top-of-funnel lead capture.
- **Key content**: 5-dimension assessment, score bands, benchmark percentile, personalized roadmap.
- **Primary / secondary CTA**: "Get my score" / "Book improvement walkthrough".
- **SEO long-tail targets**:
  - factory digital maturity assessment tool
  - manufacturing operations benchmark score
  - supply chain readiness self assessment
  - factory sustainability maturity checker
- **Visitor target**: transformation managers and curious decision makers.

## Part 3 - Architecture & Scalability Blueprint

### Production planning schema
- **Tables**: `work_orders`, `work_order_operations`, `bom_headers`, `bom_items`, `routing_steps`, `resources`.
- **Edge Functions**: `schedule-work-orders`, `rebalance-capacity`, `recompute-oee`.
- **Multi-tenant scalability**:
  - RLS by `company_id` + partition-ready indexes by `(company_id, plant_id, scheduled_start)`
  - async schedule recomputation per company queue
  - use denormalized summary tables for Gantt filters and OEE dashboards.

### QMS schema
- **Tables**: `nonconformities`, `inspections`, `inspection_templates`, `corrective_actions`.
- **Edge Functions**: `open-capa`, `close-capa`, `quality-kpi-rollup`.
- **Multi-tenant scalability**:
  - template versioning at tenant level
  - store flexible inspection payloads in JSONB with strict app-level schema validation
  - incremental KPI materialization for defect trends.

### Traceability schema
- **Tables**: `lot_tracking`, `supply_chain_events`, `recall_events`, `recall_lots`.
- **Edge Functions**: `trace-lot-graph`, `run-recall-simulation`, `export-audit-pack`.
- **Multi-tenant scalability**:
  - append-only event table for chain-of-custody
  - lot graph snapshots cached by company/lot for fast UI drill-down
  - retention policies by regulation profile.

### Multi-plant architecture
- **Tables**: `plants`, `user_plant_roles` (+ all domain entities include `plant_id` where applicable).
- **Edge Functions**: `aggregate-group-kpis`, `validate-plant-access`, `transfer-inter-plant`.
- **Multi-tenant scalability**:
  - company-level super admins + plant-scoped roles
  - group-level aggregates computed async and cached
  - consistent `company_id` guard + optional `plant_id` filter across APIs.

### Public API + webhooks for ERP/MES
- **Tables**: `integration_apps`, `api_tokens`, `webhook_endpoints`, `webhook_deliveries`.
- **Edge Functions**: `issue-api-token`, `rotate-api-secret`, `dispatch-webhook`, `retry-webhook-delivery`.
- **Scalability**:
  - per-tenant rate limits and signed webhook delivery
  - idempotency keys for write endpoints
  - dead-letter queue semantics after max retries.

### Immutable audit/event sourcing
- **Tables**: `event_store`, `audit_log_immutable`.
- **Edge Functions**: `append-domain-event`, `replay-aggregate`, `verify-audit-chain`.
- **Scalability**:
  - append-only writes, no updates/deletes
  - correlation/causation IDs for cross-module traceability
  - periodic snapshots for fast projections.

## Revenue & Packaging Suggestions
- Growth: Plant Floor Mode, Vendor Portal, Workforce basics, Offline Sync basic.
- Pro: Production Planning core, QMS lite, Customer Portal, Advanced Analytics.
- Enterprise: Compliance/Traceability advanced, Multi-Plant, Workflow Builder, ESG Scope 3, API/webhook premium.

## 3-Phase Roadmap (TAM growth + 90-day churn protection)

### Phase 1 (0-3 months): onboarding stickiness + operational daily value
- Ship: Plant Floor Mode (MVP), Vendor Portal (MVP), Workforce/Shift basics, Offline Sync foundation, Pricing V2, ROI Calculator V2.
- Why: reduces early churn by embedding product in daily plant workflows in first 2-6 weeks.
- Success KPIs:
  - activation: first production log < Day 3
  - retention: weekly active operators > 60% by week 8
  - procurement cycle: demo-to-trial conversion +20%
  - net churn (logo): down in first 90 days.

### Phase 2 (3-9 months): vertical expansion + upsell to Pro
- Ship: Production Planning, QMS lite, Vertical landing pages, Integrations page, Academy, Customer Portal.
- Why: unlock regulated and process-heavy segments and drive Growth -> Pro upgrades.
- Success KPIs:
  - Pro attach rate +25%
  - deal size uplift via planning + quality modules
  - regulated segment pipeline share (food/pharma/automotive) > 35%.

### Phase 3 (9-18 months): enterprise readiness + global scale
- Ship: Compliance/Traceability full, Multi-Plant, Workflow Builder, Advanced Analytics, Trust page maturity, Partner program, Factory Score tool.
- Why: enables enterprise procurement and larger multi-site accounts (up to 2000 employees).
- Success KPIs:
  - Enterprise win rate +15%
  - multi-plant ARR share > 30%
  - partner-sourced pipeline > 20%
  - expansion revenue (seats + modules) > new logo ARR growth rate.

## Implementation Status in this commit
- Added migration: `supabase/migrations/20260420090000_fabricos_enterprise_foundations.sql`
  - includes core schema + indexes + RLS for planning, QMS, traceability, multi-plant, integrations, event sourcing.
- Added this strategic and technical blueprint document.
