'use client';

import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';

interface ProfileDisplay {
  full_name: string;
  email: string;
  avatar_url: string | null;
  allowed_sections?: string[];
  allowed_actions?: string[];
}

interface AuthContextValue {
  role: string | null;
  userId: string | null;
  profile: ProfileDisplay | null;
  accessToken: string | null;
  isAuthorized: boolean;
  isLoading: boolean;
}

const AuthContext = createContext<AuthContextValue>({
  role: null,
  userId: null,
  profile: null,
  accessToken: null,
  isAuthorized: false,
  isLoading: true,
});

export function AuthProvider({ children }: { children: ReactNode }) {
  const router = useRouter();
  const [value, setValue] = useState<AuthContextValue>({
    role: null,
    userId: null,
    profile: null,
    accessToken: null,
    isAuthorized: false,
    isLoading: true,
  });

    useEffect(() => {
    async function checkAuth() {
      try {
        const { data: { session }, error: sessionError } = await supabase.auth.getSession();
        if (sessionError || !session) { router.push('/login'); return; }

        const { data: profileData, error: profileError } = await supabase
          .from('profiles')
          .select('full_name, email, role, avatar_url, status, allowed_sections, allowed_actions')
          .eq('id', session.user.id)
          .maybeSingle();

        if (profileError || !profileData) {
          await supabase.auth.signOut();
          toast.error('Session invalid or profile not found.');
          router.push('/login');
          return;
        }

        if (profileData.status !== 'ACTIVE') {
          await supabase.auth.signOut();
          toast.error('Your account is inactive or suspended.');
          router.push('/login');
          return;
        }

        const allowedRoles = ['admin', 'superadmin', 'instructor'];
        if (!allowedRoles.includes(profileData.role)) {
          await supabase.auth.signOut();
          toast.error('Access Denied: Learners are not permitted.');
          router.push('/login');
          return;
        }

        setValue({
          role: profileData.role,
          userId: session.user.id,
          profile: {
            full_name: profileData.full_name || 'Admin User',
            email: profileData.email || session.user.email || '',
            avatar_url: profileData.avatar_url,
            allowed_sections: profileData.allowed_sections || [],
            allowed_actions: profileData.allowed_actions || [],
          },
          accessToken: session.access_token,
          isAuthorized: true,
          isLoading: false,
        });
      } catch {
        router.push('/login');
      }
    }
    checkAuth();

    const {
      data: { subscription },
    } = supabase.auth.onAuthStateChange((event, session) => {
      if (event === 'TOKEN_REFRESHED' || event === 'SIGNED_IN') {
        setValue((prev) => {
          if (!prev.isAuthorized) return prev;
          return {
            ...prev,
            accessToken: session?.access_token ?? prev.accessToken,
          };
        });
      }
      if (event === 'SIGNED_OUT') {
        setValue((prev) => ({
          ...prev,
          accessToken: null,
          isAuthorized: false,
        }));
      }
    });

    return () => {
      subscription?.unsubscribe();
    };
  }, [router]);

  if (value.isLoading) {
    return (
      <div className="flex h-screen bg-gray-50">
        <div className="hidden md:flex w-64 flex-col border-r border-gray-200 bg-white p-3 animate-pulse">
          <div className="flex items-center gap-3 px-1">
            <div className="h-10 w-10 rounded-xl bg-gray-200" />
            <div className="flex-1 space-y-1.5">
              <div className="h-3 w-24 rounded bg-gray-200" />
              <div className="h-2 w-16 rounded bg-gray-100" />
            </div>
          </div>
          <div className="mt-6 space-y-1 flex-1">
            {Array.from({ length: 6 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3 px-4 py-3">
                <div className="h-4.5 w-4.5 rounded bg-gray-200" />
                <div className="h-3 w-28 rounded bg-gray-200" />
              </div>
            ))}
          </div>
          <div className="pt-4 mt-4 border-t border-gray-200 space-y-3">
            <div className="flex items-center gap-3 px-1">
              <div className="h-9 w-9 rounded-full bg-gray-200" />
              <div className="flex-1 space-y-1">
                <div className="h-3 w-20 rounded bg-gray-200" />
                <div className="h-2 w-14 rounded bg-gray-100" />
              </div>
            </div>
            <div className="h-10 rounded-lg bg-gray-100" />
          </div>
        </div>
        <div className="flex-1 flex flex-col">
          <div className="md:hidden h-16 border-b border-gray-200 bg-white flex items-center px-6 animate-pulse">
            <div className="flex items-center gap-2">
              <div className="h-8 w-8 rounded-lg bg-gray-200" />
              <div className="h-3 w-20 rounded bg-gray-200" />
            </div>
          </div>
          <div className="flex-1 p-6 md:p-8 animate-pulse">
            <div className="max-w-7xl mx-auto space-y-6">
              <div>
                <div className="h-8 w-48 rounded-lg bg-gray-200" />
                <div className="h-4 w-64 mt-2 rounded bg-gray-100" />
              </div>
              <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
                {Array.from({ length: 4 }).map((_, i) => (
                  <div key={i} className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
                    <div className="flex items-start justify-between">
                      <div className="flex-1">
                        <div className="h-3 w-24 rounded bg-gray-200" />
                        <div className="h-8 w-16 mt-3 rounded bg-gray-200" />
                      </div>
                      <div className="h-11 w-11 rounded-xl bg-gray-100 shrink-0 ml-3" />
                    </div>
                    <div className="h-3 w-32 mt-5 rounded bg-gray-100" />
                  </div>
                ))}
              </div>
            </div>
          </div>
        </div>
      </div>
    );
  }

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  return useContext(AuthContext);
}
