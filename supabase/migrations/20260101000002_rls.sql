-- RLS: enable on all tenant tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspaces ENABLE ROW LEVEL SECURITY;
ALTER TABLE workspace_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE invitations ENABLE ROW LEVEL SECURITY;
ALTER TABLE customers ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE usage_counters ENABLE ROW LEVEL SECURITY;
ALTER TABLE suppliers ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_stock_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE sales_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE forecasts ENABLE ROW LEVEL SECURITY;
ALTER TABLE reorder_recommendations ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE purchase_order_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE alerts ENABLE ROW LEVEL SECURITY;
ALTER TABLE imports ENABLE ROW LEVEL SECURITY;
ALTER TABLE import_rows ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE contact_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_events ENABLE ROW LEVEL SECURITY;

-- Helper: current user's workspace ids
CREATE OR REPLACE FUNCTION user_workspace_ids()
RETURNS SETOF UUID AS $$
  SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- Profiles: user can read/update own
CREATE POLICY profiles_select ON profiles FOR SELECT USING (id = auth.uid());
CREATE POLICY profiles_update ON profiles FOR UPDATE USING (id = auth.uid());
CREATE POLICY profiles_insert ON profiles FOR INSERT WITH CHECK (id = auth.uid());

-- Workspaces: members can read
CREATE POLICY workspaces_select ON workspaces FOR SELECT USING (id IN (SELECT user_workspace_ids()));
CREATE POLICY workspaces_insert ON workspaces FOR INSERT WITH CHECK (true);
CREATE POLICY workspaces_update ON workspaces FOR UPDATE USING (id IN (SELECT user_workspace_ids()));

-- Workspace members: members can read; admin/owner can insert/update/delete
CREATE POLICY workspace_members_select ON workspace_members FOR SELECT USING (workspace_id IN (SELECT user_workspace_ids()));
CREATE POLICY workspace_members_insert ON workspace_members FOR INSERT WITH CHECK (workspace_id IN (SELECT user_workspace_ids()));
CREATE POLICY workspace_members_update ON workspace_members FOR UPDATE USING (workspace_id IN (SELECT user_workspace_ids()));
CREATE POLICY workspace_members_delete ON workspace_members FOR DELETE USING (workspace_id IN (SELECT user_workspace_ids()));

-- Invitations
CREATE POLICY invitations_select ON invitations FOR SELECT USING (workspace_id IN (SELECT user_workspace_ids()));
CREATE POLICY invitations_insert ON invitations FOR INSERT WITH CHECK (workspace_id IN (SELECT user_workspace_ids()));

-- Customers: workspace-scoped
CREATE POLICY customers_select ON customers FOR SELECT USING (workspace_id IN (SELECT user_workspace_ids()));
CREATE POLICY customers_all ON customers FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Subscriptions: workspace-scoped
CREATE POLICY subscriptions_select ON subscriptions FOR SELECT USING (workspace_id IN (SELECT user_workspace_ids()));
CREATE POLICY subscriptions_all ON subscriptions FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Subscription events: no direct access from client (service role only in edge functions)
CREATE POLICY subscription_events_select ON subscription_events FOR SELECT USING (false);

-- Usage counters
CREATE POLICY usage_counters_select ON usage_counters FOR SELECT USING (workspace_id IN (SELECT user_workspace_ids()));
CREATE POLICY usage_counters_all ON usage_counters FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Suppliers
CREATE POLICY suppliers_all ON suppliers FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Products
CREATE POLICY products_all ON products FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Product stock snapshots
CREATE POLICY product_stock_snapshots_all ON product_stock_snapshots FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Sales history
CREATE POLICY sales_history_all ON sales_history FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Forecasts
CREATE POLICY forecasts_all ON forecasts FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Reorder recommendations
CREATE POLICY reorder_recommendations_all ON reorder_recommendations FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Purchase orders & items
CREATE POLICY purchase_orders_all ON purchase_orders FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));
CREATE POLICY purchase_order_items_all ON purchase_order_items FOR ALL USING (
  purchase_order_id IN (SELECT id FROM purchase_orders WHERE workspace_id IN (SELECT user_workspace_ids()))
);

-- Alerts
CREATE POLICY alerts_all ON alerts FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));

-- Imports & import_rows
CREATE POLICY imports_all ON imports FOR ALL USING (workspace_id IN (SELECT user_workspace_ids()));
CREATE POLICY import_rows_all ON import_rows FOR ALL USING (
  import_id IN (SELECT id FROM imports WHERE workspace_id IN (SELECT user_workspace_ids()))
);

-- Notifications: user's own
CREATE POLICY notifications_select ON notifications FOR SELECT USING (user_id = auth.uid());
CREATE POLICY notifications_update ON notifications FOR UPDATE USING (user_id = auth.uid());

-- Contact requests: public insert only
CREATE POLICY contact_requests_insert ON contact_requests FOR INSERT WITH CHECK (true);
CREATE POLICY contact_requests_select ON contact_requests FOR SELECT USING (false);

-- Auto-create profile on signup
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, full_name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'full_name', NEW.email));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE handle_new_user();
