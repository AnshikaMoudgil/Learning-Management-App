import { redirect } from 'next/navigation';

export default function RootPage() {
  // Let the middleware decide. If they are authenticated, they'll hit /dashboard.
  // If not, middleware will redirect them to /login.
  redirect('/dashboard');
}
