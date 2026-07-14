import { createClient } from '@supabase/supabase-js';

const url = import.meta.env.VITE_SUPABASE_URL;
const anonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

// Null until Supabase env vars are configured — callers must handle this
// so the static HTML keeps working before/without a backend.
export const supabase = url && anonKey ? createClient(url, anonKey) : null;
