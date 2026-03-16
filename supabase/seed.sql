-- Seed: demo workspace and sample data (run after migrations)
-- Uses service role or run manually in SQL editor

INSERT INTO workspaces (id, name, slug) VALUES
  ('a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'Demo Company', 'demo-company')
ON CONFLICT (id) DO NOTHING;

-- Products for demo workspace
INSERT INTO products (workspace_id, sku, name, current_stock, reorder_point, safety_stock, lead_time_days, unit_cost, selling_price)
SELECT 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SKU-1001', 'Product A', 45, 30, 10, 14, 12.50, 24.00
WHERE NOT EXISTS (SELECT 1 FROM products WHERE workspace_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11' AND sku = 'SKU-1001');
INSERT INTO products (workspace_id, sku, name, current_stock, reorder_point, safety_stock, lead_time_days, unit_cost, selling_price)
SELECT 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SKU-1002', 'Product B', 12, 25, 8, 7, 8.00, 18.00
WHERE NOT EXISTS (SELECT 1 FROM products WHERE workspace_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11' AND sku = 'SKU-1002');
INSERT INTO products (workspace_id, sku, name, current_stock, reorder_point, safety_stock, lead_time_days, unit_cost, selling_price)
SELECT 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11', 'SKU-1003', 'Product C', 120, 40, 15, 10, 5.00, 12.00
WHERE NOT EXISTS (SELECT 1 FROM products WHERE workspace_id = 'a0eebc99-9c0b-4ef8-bb6d-6bb9bd380a11' AND sku = 'SKU-1003');
