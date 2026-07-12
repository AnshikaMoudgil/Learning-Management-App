'use strict';
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import { KeyRound, Mail, Loader2 } from 'lucide-react';

export default function LoginPage() {
  const router = useRouter();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isLoading, setIsLoading] = useState(false);

  const handleLogin = async (e: React.FormEvent) => {
    e.preventDefault();

    // Custom client-side validation using toasts (no HTML required attribute)
    if (!email.trim()) {
      toast.error('Email address is required.');
      return;
    }
    if (!password) {
      toast.error('Password is required.');
      return;
    }

    setIsLoading(true);
    const loadingToast = toast.loading('Signing you in...');

    try {
      // 1. Auth Sign In
      const { data, error } = await supabase.auth.signInWithPassword({
        email,
        password,
      });

      if (error) {
        toast.dismiss(loadingToast);
        toast.error(error.message || 'Invalid credentials.');
        setIsLoading(false);
        return;
      }

      if (!data.user) {
        toast.dismiss(loadingToast);
        toast.error('Something went wrong. Please try again.');
        setIsLoading(false);
        return;
      }

      // 2. Fetch User Profile & Role
      const { data: profile, error: profileError } = await supabase
        .from('profiles')
        .select('role, status')
        .eq('id', data.user.id)
        .maybeSingle();

      if (profileError || !profile) {
        await supabase.auth.signOut();
        toast.dismiss(loadingToast);
        toast.error('Unable to fetch user profile.');
        setIsLoading(false);
        return;
      }

      // Check Status
      if (profile.status !== 'ACTIVE') {
        await supabase.auth.signOut();
        toast.dismiss(loadingToast);
        toast.error(`Your account status is ${profile.status}. Access denied.`);
        setIsLoading(false);
        return;
      }

      // Check Role
      const allowedRoles = ['admin', 'superadmin', 'instructor'];
      if (!allowedRoles.includes(profile.role)) {
        await supabase.auth.signOut();
        toast.dismiss(loadingToast);
        toast.error('Access Denied: Learners are not permitted on the admin dashboard.');
        setIsLoading(false);
        return;
      }

      // Successful Login
      toast.dismiss(loadingToast);
      toast.success('Logged in successfully!');
      
      // Force page reload/navigation to dashboard to trigger cookies/middleware update
      router.push('/dashboard');
      router.refresh();
    } catch (err: any) {
      toast.dismiss(loadingToast);
      toast.error(err.message || 'An unexpected error occurred.');
      setIsLoading(false);
    }
  };

  return (
    <div className="flex min-h-screen items-center justify-center bg-zinc-950 p-4 font-sans text-zinc-100">
      {/* Background gradients */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute -top-[40%] -left-[20%] h-[80%] w-[80%] rounded-full bg-teal-900/10 blur-[120px]" />
        <div className="absolute -bottom-[40%] -right-[20%] h-[80%] w-[80%] rounded-full bg-indigo-900/10 blur-[120px]" />
      </div>

      <div className="relative w-full max-w-md overflow-hidden rounded-2xl border border-zinc-800 bg-zinc-900/50 p-8 backdrop-blur-xl shadow-2xl">
        {/* Header */}
        <div className="flex flex-col items-center space-y-2 text-center mb-8">
          <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-gradient-to-tr from-teal-500 to-emerald-400 text-zinc-950 font-bold text-xl shadow-lg shadow-teal-500/20">
            M
          </div>
          <h2 className="text-2xl font-bold tracking-tight text-white mt-4">
            MBT Admin Portal
          </h2>
          <p className="text-sm text-zinc-400">
            Sign in to manage your system dashboard
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleLogin} className="space-y-6">
          <div className="space-y-2">
            <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400 block">
              Email Address
            </label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-zinc-500" />
              <input
                type="email"
                placeholder="admin@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full rounded-lg border border-zinc-800 bg-zinc-900/30 py-3 pl-10 pr-4 text-sm text-zinc-100 placeholder-zinc-500 outline-none transition-all duration-200 focus:border-teal-500 focus:bg-zinc-900/50"
              />
            </div>
          </div>

          <div className="space-y-2">
            <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400 block">
              Password
            </label>
            <div className="relative">
              <KeyRound className="absolute left-3 top-1/2 h-5 w-5 -translate-y-1/2 text-zinc-500" />
              <input
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full rounded-lg border border-zinc-800 bg-zinc-900/30 py-3 pl-10 pr-4 text-sm text-zinc-100 placeholder-zinc-500 outline-none transition-all duration-200 focus:border-teal-500 focus:bg-zinc-900/50"
              />
            </div>
          </div>

          <button
            type="submit"
            disabled={isLoading}
            className="flex w-full items-center justify-center gap-2 rounded-lg bg-gradient-to-r from-teal-500 to-emerald-500 py-3 text-sm font-semibold text-zinc-950 transition-all duration-200 hover:from-teal-400 hover:to-emerald-400 disabled:opacity-50 cursor-pointer shadow-lg shadow-teal-500/10 active:scale-[0.98]"
          >
            {isLoading ? (
              <>
                <Loader2 className="h-4 w-4 animate-spin" />
                Signing In...
              </>
            ) : (
              'Sign In'
            )}
          </button>
        </form>
      </div>
    </div>
  );
}
