import type { SupabaseClient } from 'https://esm.sh/@supabase/supabase-js@2';

const COMPANY_TABLES = ['cg_companies', 'companies'] as const;

export async function resolveCompanyTable(client: SupabaseClient): Promise<(typeof COMPANY_TABLES)[number]> {
  for (const table of COMPANY_TABLES) {
    const { error } = await client.from(table).select('id').limit(1);
    if (!error) return table;
  }
  throw new Error('No company table found');
}
