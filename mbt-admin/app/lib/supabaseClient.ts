import { createBrowserClient } from '@supabase/ssr';
import { createClient } from '@supabase/supabase-js';

let supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
let supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || 'placeholder-key';

// Guard for build time when env vars may be empty
if (!supabaseUrl || !supabaseUrl.startsWith('http')) {
  supabaseUrl = 'https://placeholder.supabase.co';
}

// Browser client — uses @supabase/ssr to store session in cookies (not localStorage)
// This makes the session readable by the proxy.ts server-side route guard
export const supabase = createBrowserClient(supabaseUrl, supabaseAnonKey);

// Server-side admin client using service role key (bypasses RLS)
// Only used in API routes / server components — never exposed to the browser
export function getSupabaseAdmin() {
  const serviceRoleKey = process.env.SUPABASE_SERVICE_ROLE_KEY || 'placeholder-service-key';
  return createClient(supabaseUrl, serviceRoleKey, {
    auth: {
      autoRefreshToken: false,
      persistSession: false,
    },
  });
}
