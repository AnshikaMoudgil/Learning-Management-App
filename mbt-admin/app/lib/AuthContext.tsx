'use client';

import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import { Loader2 } from 'lucide-react';

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
  }, [router]);

  if (value.isLoading) {
    return (
      <div style={{ background: 'var(--background)' }} className="flex h-screen w-screen items-center justify-center">
        <div className="flex flex-col items-center gap-4">
          <Loader2 className="h-10 w-10 animate-spin" style={{ color: 'var(--primary)' }} />
          <p className="text-sm font-medium" style={{ color: 'var(--text-muted)' }}>
            Loading your admin console...
          </p>
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
