const CSRF_COOKIE_NAME = 'csrf_token';
const CSRF_HEADER_NAME = 'x-csrf-token';

export function getCsrfToken(): string | null {
  if (typeof document === 'undefined') return null;
  const match = document.cookie.match(new RegExp(`(?:^|;\\s*)${CSRF_COOKIE_NAME}=([^;]*)`));
  return match ? match[1] : null;
}

export function csrfHeaders(): Record<string, string> {
  const token = getCsrfToken();
  return token ? { [CSRF_HEADER_NAME]: token } : {};
}

function generateToken(): string {
  const bytes = new Uint8Array(32);
  crypto.getRandomValues(bytes);
  return Array.from(bytes).map(b => b.toString(16).padStart(2, '0')).join('');
}

export function setCsrfCookie(response: { headers: Headers; cookies?: { set: (name: string, value: string, options: Record<string, string | boolean | number | undefined>) => void } }): void {
  const token = generateToken();
  if (response.cookies) {
    response.cookies.set(CSRF_COOKIE_NAME, token, {
      httpOnly: false,
      sameSite: 'strict',
      secure: process.env.NODE_ENV === 'production',
      path: '/',
      maxAge: 60 * 60,
    });
  }
}

export async function validateCsrf(request: Request): Promise<{ valid: boolean; error?: string }> {
  const headerToken = request.headers.get(CSRF_HEADER_NAME);
  if (!headerToken) {
    return { valid: false, error: 'Missing CSRF token.' };
  }

  const cookieHeader = request.headers.get('cookie');
  const cookieToken = cookieHeader
    ?.split(';')
    .map(c => c.trim())
    .find(c => c.startsWith(`${CSRF_COOKIE_NAME}=`))
    ?.split('=')[1];

  if (!cookieToken || cookieToken !== headerToken) {
    return { valid: false, error: 'Invalid CSRF token.' };
  }

  return { valid: true };
}
