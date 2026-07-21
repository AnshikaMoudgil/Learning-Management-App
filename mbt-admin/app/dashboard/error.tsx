'use client';

export default function DashboardError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <div className="flex flex-col items-center justify-center min-h-[400px] space-y-4 p-8">
      <div className="flex h-16 w-16 items-center justify-center rounded-full bg-rose-500/10">
        <span className="text-3xl">!</span>
      </div>
      <h2 className="text-xl font-bold text-gray-900">Something went wrong</h2>
      <p className="text-sm text-gray-500 text-center max-w-md">
        {error.message || 'An unexpected error occurred in the dashboard.'}
      </p>
      <button
        onClick={reset}
        className="rounded-xl bg-gradient-to-r from-blue-600 to-blue-500 px-5 py-3 text-sm font-semibold text-white transition hover:from-blue-500 hover:to-blue-400 cursor-pointer"
      >
        Try again
      </button>
    </div>
  );
}
