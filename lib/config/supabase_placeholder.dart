/// Set to `true` when [bootstrapSupabase] initialized a non-production client
/// (debug web without `SUPABASE_URL` / `SUPABASE_ANON_KEY`). Auth stream is stubbed;
/// API calls will fail until real credentials are provided.
bool fabricosSupabaseIsPlaceholder = false;
