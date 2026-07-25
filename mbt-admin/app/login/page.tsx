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

    if (!email.trim()) { toast.error('Email address is required.'); return; }
    if (!password) { toast.error('Password is required.'); return; }

    setIsLoading(true);
    const loadingToast = toast.loading('Signing you in...');

    try {
      const { data, error } = await supabase.auth.signInWithPassword({ email, password });

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

      toast.dismiss(loadingToast);
      toast.success('Logged in successfully!');
      router.push('/dashboard');
      router.refresh();
    } catch (err: unknown) {
      toast.dismiss(loadingToast);
      toast.error(err instanceof Error ? err.message : 'An unexpected error occurred.');
      setIsLoading(false);
    }
  };

  return (
    <div
      className="flex min-h-screen items-center justify-center p-4 font-sans relative overflow-hidden"
      style={{ background: 'var(--background)', color: 'var(--foreground)' }}
    >
      {/* Ambient glow blobs */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div
          className="absolute -top-[40%] -left-[20%] h-[80%] w-[80%] rounded-full"
          style={{ background: 'rgba(37,99,235,0.07)', filter: 'blur(120px)' }}
        />
        <div
          className="absolute -bottom-[40%] -right-[20%] h-[80%] w-[80%] rounded-full"
          style={{ background: 'rgba(99,102,241,0.06)', filter: 'blur(120px)' }}
        />
      </div>

      <div
        className="relative w-full max-w-md overflow-hidden rounded-2xl p-8 backdrop-blur-xl shadow-2xl"
        style={{
          background: 'var(--bg-card)',
          border: '1px solid var(--border)',
        }}
      >
        {/* Header */}
        <div className="flex flex-col items-center space-y-2 text-center mb-8">
          <div
            className="flex h-12 w-12 items-center justify-center rounded-xl font-bold text-xl shadow-lg"
            style={{ background: '#2563eb', color: '#fff', boxShadow: '0 0 24px rgba(37,99,235,0.40)' }}
          >
            M
          </div>
          <h2 className="text-2xl font-bold tracking-tight mt-4" style={{ color: 'var(--foreground)' }}>
            MBT Admin Portal
          </h2>
          <p className="text-sm" style={{ color: 'var(--text-muted)' }}>
            Sign in to manage your system dashboard
          </p>
        </div>

        {/* Form */}
        <form onSubmit={handleLogin} className="space-y-5">

          {/* Email */}
          <div className="space-y-2">
            <label className="text-xs font-semibold uppercase tracking-wider block" style={{ color: 'var(--text-muted)' }}>
              Email Address
            </label>
            <div className="relative">
              <Mail className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2" style={{ color: 'var(--text-muted)' }} />
              <input
                type="email"
                placeholder="admin@example.com"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="admin-input"
                style={{ paddingLeft: '38px' }}
              />
            </div>
          </div>

          {/* Password */}
          <div className="space-y-2">
            <label className="text-xs font-semibold uppercase tracking-wider block" style={{ color: 'var(--text-muted)' }}>
              Password
            </label>
            <div className="relative">
              <KeyRound className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2" style={{ color: 'var(--text-muted)' }} />
              <input
                type="password"
                placeholder="••••••••"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="admin-input"
                style={{ paddingLeft: '38px' }}
              />
            </div>
          </div>

          {/* Submit */}
          <button
            type="submit"
            disabled={isLoading}
            className="btn-primary w-full justify-center py-3 rounded-xl text-base disabled:opacity-50 active:scale-[0.98]"
            style={{ marginTop: '8px' }}
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
