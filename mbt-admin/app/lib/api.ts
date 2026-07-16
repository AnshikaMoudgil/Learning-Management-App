import { supabase } from './supabaseClient';

const API_BASE = process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000';

async function getAuthHeaders(): Promise<Record<string, string>> {
  const { data: { session } } = await supabase.auth.getSession();
  const token = session?.access_token;

  return {
    'Content-Type': 'application/json',
    ...(token ? { Authorization: `Bearer ${token}` } : {}),
  };
}

export async function apiPost(path: string, body: unknown) {
  const headers = await getAuthHeaders();
  const response = await fetch(`${API_BASE}${path}`, {
    method: 'POST',
    headers,
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(text || `API error: ${response.status}`);
  }

  return response.json();
}

export async function apiPatch(path: string, body: unknown) {
  const headers = await getAuthHeaders();
  const response = await fetch(`${API_BASE}${path}`, {
    method: 'PATCH',
    headers,
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(text || `API error: ${response.status}`);
  }

  return response.json();
}

export async function apiDelete(path: string) {
  const headers = await getAuthHeaders();
  const response = await fetch(`${API_BASE}${path}`, {
    method: 'DELETE',
    headers,
  });

  if (!response.ok) {
    const text = await response.text();
    throw new Error(text || `API error: ${response.status}`);
  }

  return response.json();
}
