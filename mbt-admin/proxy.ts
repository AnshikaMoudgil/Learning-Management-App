import { createServerClient } from '@supabase/ssr';
import { NextResponse, type NextRequest } from 'next/server';

export async function proxy(request: NextRequest) {
  let response = NextResponse.next({ request });

  const supabaseUrl = process.env.NEXT_PUBLIC_SUPABASE_URL || '';
  const supabaseAnonKey = process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || '';

  // Create a server-side Supabase client that reads/writes cookies
  const supabase = createServerClient(supabaseUrl, supabaseAnonKey, {
    cookies: {
      getAll() {
        return request.cookies.getAll();
      },
      setAll(cookiesToSet) {
        cookiesToSet.forEach(({ name, value }) => request.cookies.set(name, value));
        response = NextResponse.next({ request });
        cookiesToSet.forEach(({ name, value, options }) =>
          response.cookies.set(name, value, options)
        );
      },
    },
  });

  // Refresh the session if it has expired (keeps cookies fresh)
  const {
    data: { user },
  } = await supabase.auth.getUser();

  const url = request.nextUrl.clone();
  const isOnDashboard = url.pathname.startsWith('/dashboard');
  const isOnLogin = url.pathname === '/login';

  // Not logged in and trying to access dashboard → redirect to login
  if (isOnDashboard && !user) {
    url.pathname = '/login';
    return NextResponse.redirect(url);
  }

  // Logged in but trying to access login page → redirect to dashboard
  if (isOnLogin && user) {
    url.pathname = '/dashboard';
    return NextResponse.redirect(url);
  }

  return response;
}

export const config = {
  matcher: ['/dashboard/:path*', '/login'],
};
