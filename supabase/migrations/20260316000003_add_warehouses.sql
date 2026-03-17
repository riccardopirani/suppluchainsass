-- Add multi-warehouse support
-- This migration adds warehouses and warehouse-specific inventory tracking

-- Create warehouses table
CREATE TABLE IF NOT EXISTS warehouses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  workspace_id UUID NOT NULL REFERENCES workspaces(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  location TEXT,
  capacity INT,
  is_default BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(workspace_id, name)
);

-- Create product_inventory table (stock per warehouse)
CREATE TABLE IF NOT EXISTS product_inventory (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  warehouse_id UUID NOT NULL REFERENCES warehouses(id) ON DELETE CASCADE,
  quantity INT DEFAULT 0,
  reorder_point INT,
  safety_stock INT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  UNIQUE(product_id, warehouse_id)
);

-- Add warehouse_id to purchase_orders
ALTER TABLE IF EXISTS purchase_orders 
ADD COLUMN IF NOT EXISTS warehouse_id UUID REFERENCES warehouses(id) ON DELETE SET NULL;

-- Create indexes
CREATE INDEX IF NOT EXISTS idx_warehouses_workspace ON warehouses(workspace_id);
CREATE INDEX IF NOT EXISTS idx_product_inventory_product ON product_inventory(product_id);
CREATE INDEX IF NOT EXISTS idx_product_inventory_warehouse ON product_inventory(warehouse_id);
CREATE INDEX IF NOT EXISTS idx_purchase_orders_warehouse ON purchase_orders(warehouse_id);

-- Enable RLS on new tables
ALTER TABLE warehouses ENABLE ROW LEVEL SECURITY;
ALTER TABLE product_inventory ENABLE ROW LEVEL SECURITY;

-- RLS Policies for warehouses
DROP POLICY IF EXISTS "Users can view warehouses in their workspace" ON warehouses;
CREATE POLICY "Users can view warehouses in their workspace" ON warehouses
  FOR SELECT USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert warehouses in their workspace" ON warehouses;
CREATE POLICY "Users can insert warehouses in their workspace" ON warehouses
  FOR INSERT WITH CHECK (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can update warehouses in their workspace" ON warehouses;
CREATE POLICY "Users can update warehouses in their workspace" ON warehouses
  FOR UPDATE USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can delete warehouses in their workspace" ON warehouses;
CREATE POLICY "Users can delete warehouses in their workspace" ON warehouses
  FOR DELETE USING (
    workspace_id IN (
      SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
    )
  );

-- RLS Policies for product_inventory
DROP POLICY IF EXISTS "Users can view product_inventory in their workspace" ON product_inventory;
CREATE POLICY "Users can view product_inventory in their workspace" ON product_inventory
  FOR SELECT USING (
    warehouse_id IN (
      SELECT id FROM warehouses WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "Users can insert product_inventory in their workspace" ON product_inventory;
CREATE POLICY "Users can insert product_inventory in their workspace" ON product_inventory
  FOR INSERT WITH CHECK (
    warehouse_id IN (
      SELECT id FROM warehouses WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "Users can update product_inventory in their workspace" ON product_inventory;
CREATE POLICY "Users can update product_inventory in their workspace" ON product_inventory
  FOR UPDATE USING (
    warehouse_id IN (
      SELECT id FROM warehouses WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
      )
    )
  );

DROP POLICY IF EXISTS "Users can delete product_inventory in their workspace" ON product_inventory;
CREATE POLICY "Users can delete product_inventory in their workspace" ON product_inventory
  FOR DELETE USING (
    warehouse_id IN (
      SELECT id FROM warehouses WHERE workspace_id IN (
        SELECT workspace_id FROM workspace_members WHERE user_id = auth.uid()
      )
    )
  );
