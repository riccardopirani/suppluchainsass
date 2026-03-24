-- FabricOS seed data (run after migrations)

INSERT INTO public.companies (id, name, size_band)
VALUES
  ('11111111-1111-1111-1111-111111111111', 'FabricOS Demo Manufacturing', '51-200')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.suppliers (id, company_id, name, contact_email, reliability_score, compliance_status, avg_delay_days, risk_level)
VALUES
  ('22222222-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', 'Delta Components', 'ops@deltacomp.example', 91, 'compliant', 1.2, 'low'),
  ('22222222-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', 'North Forge Metals', 'sales@northforge.example', 84, 'under_review', 2.8, 'medium'),
  ('22222222-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', 'Apex Industrial', 'team@apexindustrial.example', 77, 'under_review', 4.3, 'medium'),
  ('22222222-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', 'GreenRaw Materials', 'support@greenraw.example', 73, 'compliant', 5.1, 'high'),
  ('22222222-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', 'Linea Automation', 'hello@lineaauto.example', 88, 'compliant', 2.0, 'low')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.machines (
  id,
  company_id,
  supplier_id,
  name,
  type,
  country,
  city,
  address,
  latitude,
  longitude,
  status,
  last_maintenance_at,
  failure_risk
)
VALUES
  ('33333333-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000005', 'CNC Mill A1', 'CNC', 'Italy', 'Milan', 'Via della Produzione 18', 45.4642, 9.1900, 'running', now() - interval '18 days', 0.21),
  ('33333333-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000005', 'Packaging Line B2', 'Packaging', 'Germany', 'Munich', 'Industriestrasse 77', 48.1351, 11.5820, 'warning', now() - interval '31 days', 0.67),
  ('33333333-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000001', 'Laser Cutter C4', 'Laser', 'United States', 'Detroit', 'Woodward Ave 2200', 42.3314, -83.0458, 'running', now() - interval '12 days', 0.18),
  ('33333333-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000002', 'Hydraulic Press D1', 'Press', 'Japan', 'Osaka', 'Kita-ku Plant District 4', 34.6937, 135.5023, 'stopped', now() - interval '45 days', 0.92),
  ('33333333-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000003', 'Assembly Robot E3', 'Robot', 'Brazil', 'Sao Paulo', 'Av. Industrial 450', -23.5558, -46.6396, 'running', now() - interval '7 days', 0.28)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.maintenance_logs (id, company_id, machine_id, technician, notes, cost, performed_at)
VALUES
  ('44444444-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '33333333-0000-0000-0000-000000000001', 'L. Bianchi', 'Spindle calibration and lubrication', 420, now() - interval '18 days'),
  ('44444444-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', '33333333-0000-0000-0000-000000000002', 'M. Rossi', 'Bearing replacement', 880, now() - interval '31 days'),
  ('44444444-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', '33333333-0000-0000-0000-000000000004', 'A. Verdi', 'Hydraulic seal failure inspection', 1260, now() - interval '45 days')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.orders (id, company_id, supplier_id, order_number, status, expected_delivery_date, delivered_at, delay_days, amount)
VALUES
  ('55555555-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000001', 'ORD-1001', 'completed', now() - interval '24 days', now() - interval '22 days', 0, 9200),
  ('55555555-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000002', 'ORD-1002', 'completed', now() - interval '19 days', now() - interval '17 days', 0, 7800),
  ('55555555-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000003', 'ORD-1003', 'in_progress', now() - interval '3 days', null, 3, 15600),
  ('55555555-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000004', 'ORD-1004', 'pending', now() + interval '6 days', null, 0, 6800),
  ('55555555-0000-0000-0000-000000000005', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000005', 'ORD-1005', 'in_progress', now() + interval '11 days', null, 0, 12100),
  ('55555555-0000-0000-0000-000000000006', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000001', 'ORD-1006', 'completed', now() - interval '33 days', now() - interval '30 days', 0, 5100),
  ('55555555-0000-0000-0000-000000000007', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000002', 'ORD-1007', 'pending', now() + interval '14 days', null, 0, 9900),
  ('55555555-0000-0000-0000-000000000008', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000003', 'ORD-1008', 'in_progress', now() - interval '1 days', null, 1, 8300),
  ('55555555-0000-0000-0000-000000000009', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000004', 'ORD-1009', 'pending', now() + interval '9 days', null, 0, 7300),
  ('55555555-0000-0000-0000-000000000010', '11111111-1111-1111-1111-111111111111', '22222222-0000-0000-0000-000000000005', 'ORD-1010', 'completed', now() - interval '42 days', now() - interval '41 days', 0, 4400)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.alerts (id, company_id, machine_id, order_id, supplier_id, type, severity, title, message, ai_generated)
VALUES
  ('66666666-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', '33333333-0000-0000-0000-000000000004', null, null, 'predictive_maintenance', 'critical', 'Failure risk detected', 'Hydraulic Press D1 has a very high failure risk score.', true),
  ('66666666-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', null, '55555555-0000-0000-0000-000000000003', '22222222-0000-0000-0000-000000000003', 'order_delay_risk', 'warning', 'Order risk delay', 'Order ORD-1003 is delayed and may impact production.', true),
  ('66666666-0000-0000-0000-000000000003', '11111111-1111-1111-1111-111111111111', '33333333-0000-0000-0000-000000000002', null, null, 'predictive_maintenance', 'warning', 'Anomalous vibration trend', 'Packaging Line B2 reports elevated vibration levels.', true),
  ('66666666-0000-0000-0000-000000000004', '11111111-1111-1111-1111-111111111111', null, null, '22222222-0000-0000-0000-000000000004', 'supplier_issue', 'warning', 'Supplier issue', 'GreenRaw Materials shows worsening delay behavior.', true)
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.esg_reports (id, company_id, report_month, emissions_tco2, supplier_compliance_score, summary, metadata)
VALUES
  ('77777777-0000-0000-0000-000000000001', '11111111-1111-1111-1111-111111111111', (date_trunc('month', now()) - interval '1 month')::date, 48.220, 81.50, 'Baseline ESG snapshot with stable supplier compliance.', '{"energy_efficiency_index": 78.4, "waste_recovery_rate": 63.1}'),
  ('77777777-0000-0000-0000-000000000002', '11111111-1111-1111-1111-111111111111', date_trunc('month', now())::date, 46.870, 83.20, 'Improved emissions profile and positive supplier compliance trend.', '{"energy_efficiency_index": 80.2, "waste_recovery_rate": 66.7}')
ON CONFLICT (id) DO NOTHING;
