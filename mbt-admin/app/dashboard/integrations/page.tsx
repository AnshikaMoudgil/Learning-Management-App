'use strict';
'use client';

import { useState, useEffect } from 'react';
import { supabase } from '@/app/lib/supabaseClient';
import toast from 'react-hot-toast';
import { Video, Link as LinkIcon, Unlink, Loader2 } from 'lucide-react';

export default function IntegrationsPage() {
  const [isLoading, setIsLoading] = useState(true);
  const [zoomConnected, setZoomConnected] = useState<boolean | null>(null);
  const [zoomEmail, setZoomEmail] = useState<string | null>(null);
  const [zoomUserId, setZoomUserId] = useState<string | null>(null);
  const [zoomConnectedAt, setZoomConnectedAt] = useState<string | null>(null);
  const [isActionLoading, setIsActionLoading] = useState(false);

  const fetchZoomStatus = async () => {
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;
      if (!token) return;

      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'}/zoom/oauth-status`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      setZoomConnected(data.connected);
      if (data.connected) {
        setZoomEmail(data.email);
        setZoomUserId(data.provider_user_id);
        setZoomConnectedAt(data.connected_at);
      } else {
        setZoomEmail(null);
        setZoomUserId(null);
        setZoomConnectedAt(null);
      }
    } catch {
      setZoomConnected(false);
      setZoomEmail(null);
      setZoomUserId(null);
      setZoomConnectedAt(null);
    } finally {
      setIsLoading(false);
    }
  };

  useEffect(() => {
    fetchZoomStatus();
  }, []);

  const handleConnectZoom = async () => {
    setIsActionLoading(true);
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;

      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'}/zoom/connect`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      if (data.url) {
        window.location.href = data.url;
      } else {
        toast.error('Failed to get Zoom authorization URL');
        setIsActionLoading(false);
      }
    } catch {
      toast.error('Failed to connect to Zoom');
      setIsActionLoading(false);
    }
  };

  const handleDisconnectZoom = async () => {
    setIsActionLoading(true);
    const loadingToast = toast.loading('Disconnecting Zoom...');
    try {
      const { data: { session } } = await supabase.auth.getSession();
      const token = session?.access_token;

      const res = await fetch(`${process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000'}/zoom/disconnect`, {
        headers: { Authorization: `Bearer ${token}` },
      });
      const data = await res.json();
      
      toast.dismiss(loadingToast);
      if (data.success) {
        toast.success('Zoom account disconnected successfully.');
        setZoomConnected(false);
        setZoomEmail(null);
        setZoomUserId(null);
        setZoomConnectedAt(null);
      } else {
        toast.error(data.message || 'Failed to disconnect Zoom');
      }
    } catch {
      toast.dismiss(loadingToast);
      toast.error('Failed to disconnect Zoom');
    } finally {
      setIsActionLoading(false);
    }
  };

  if (isLoading) {
    return (
      <div className="flex h-64 items-center justify-center">
        <Loader2 className="h-8 w-8 animate-spin text-blue-500" />
      </div>
    );
  }

  return (
    <div className="space-y-8 animate-in fade-in duration-300">
      <div>
        <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">Integrations</h1>
        <p className="text-gray-500 text-sm mt-1">Configure third-party services and connections.</p>
      </div>

      <div className="grid gap-6 md:grid-cols-2 max-w-4xl">
        <div className="rounded-2xl border border-gray-200 bg-white p-6 space-y-6 shadow-sm">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="flex h-12 w-12 items-center justify-center rounded-xl bg-blue-500/10 text-blue-400">
                <Video className="h-6 w-6" />
              </div>
              <div>
                <h2 className="text-lg font-bold text-gray-900">Zoom</h2>
                <p className="text-xs text-gray-400">Live online class meetings</p>
              </div>
            </div>
            <div>
              {zoomConnected ? (
                <span className="inline-flex items-center gap-1 rounded-full bg-blue-600/10 px-2.5 py-1 text-xs font-semibold text-blue-400 border border-blue-500/25">
                  Connected
                </span>
              ) : (
                <span className="inline-flex items-center gap-1 rounded-full bg-gray-100 px-2.5 py-1 text-xs font-semibold text-gray-500 border border-gray-300">
                  Not Connected
                </span>
              )}
            </div>
          </div>

          <div className="space-y-4 pt-4 border-t border-gray-200">
            {zoomConnected && (
              <div className="space-y-2">
                <span className="text-xs font-semibold uppercase tracking-wider text-gray-500">Connected Account</span>
                <div className="rounded-lg bg-gray-50 border border-gray-200 p-3 space-y-1.5">
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-gray-400 w-16">Email:</span>
                    <span className="text-sm font-medium text-gray-900">{zoomEmail}</span>
                  </div>
                  <div className="flex items-center gap-2">
                    <span className="text-xs text-gray-400 w-16">Zoom ID:</span>
                    <span className="text-sm font-mono text-gray-700">{zoomUserId}</span>
                  </div>
                  {zoomConnectedAt && (
                    <div className="flex items-center gap-2">
                      <span className="text-xs text-gray-400 w-16">Connected:</span>
                      <span className="text-sm text-gray-700">{new Date(zoomConnectedAt).toLocaleDateString()}</span>
                    </div>
                  )}
                </div>
              </div>
            )}

            <div className="flex flex-wrap gap-3 pt-2">
              {!zoomConnected ? (
                <button
                  onClick={handleConnectZoom}
                  disabled={isActionLoading}
                  className="flex items-center gap-2 rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 px-5 py-2.5 text-sm font-semibold text-white hover:from-blue-500 hover:to-blue-400 transition cursor-pointer disabled:opacity-50"
                >
                  <LinkIcon className="h-4 w-4" />
                  Connect
                </button>
              ) : (
                <>
                  <button
                    onClick={handleConnectZoom}
                    disabled={isActionLoading}
                    className="flex items-center gap-2 rounded-xl bg-gray-100 border border-gray-300 px-5 py-2.5 text-sm font-semibold text-gray-900 hover:bg-gray-200 transition cursor-pointer disabled:opacity-50"
                  >
                    <LinkIcon className="h-4 w-4" />
                    Reconnect
                  </button>
                  <button
                    onClick={handleDisconnectZoom}
                    disabled={isActionLoading}
                    className="flex items-center gap-2 rounded-xl bg-rose-500/10 hover:bg-rose-500/20 border border-rose-500/20 px-5 py-2.5 text-sm font-semibold text-rose-400 transition cursor-pointer disabled:opacity-50"
                  >
                    <Unlink className="h-4 w-4" />
                    Disconnect
                  </button>
                </>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}