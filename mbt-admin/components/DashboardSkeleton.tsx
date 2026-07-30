export default function DashboardSkeleton() {
  return (
    <div className="space-y-6 animate-pulse">
      <div className="flex items-center justify-between">
        <div>
          <div className="h-8 w-48 rounded-lg bg-gray-200" />
          <div className="h-4 w-64 mt-2 rounded bg-gray-100" />
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-4">
        {Array.from({ length: 4 }).map((_, i) => (
          <div key={i} className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
            <div className="flex items-start justify-between">
              <div className="min-w-0 flex-1">
                <div className="h-3 w-24 rounded bg-gray-200" />
                <div className="h-8 w-16 mt-3 rounded bg-gray-200" />
              </div>
              <div className="h-11 w-11 rounded-xl bg-gray-100 shrink-0 ml-3" />
            </div>
            <div className="h-3 w-32 mt-5 rounded bg-gray-100" />
          </div>
        ))}
      </div>

      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {Array.from({ length: 3 }).map((_, i) => (
          <div key={i} className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
            <div className="flex items-start justify-between">
              <div className="min-w-0 flex-1">
                <div className="h-3 w-20 rounded bg-gray-200" />
                <div className="h-8 w-12 mt-3 rounded bg-gray-200" />
              </div>
              <div className="h-11 w-11 rounded-xl bg-gray-100 shrink-0 ml-3" />
            </div>
            <div className="h-3 w-28 mt-5 rounded bg-gray-100" />
          </div>
        ))}
      </div>

      <div className="grid gap-6 lg:grid-cols-3">
        <div className="lg:col-span-2 rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
          <div className="h-4 w-40 rounded bg-gray-200 mb-4" />
          <div className="h-64 rounded bg-gray-100" />
        </div>
        <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
          <div className="h-4 w-32 rounded bg-gray-200 mb-4" />
          <div className="space-y-4">
            {Array.from({ length: 3 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3">
                <div className="h-9 w-9 rounded-lg bg-gray-100 shrink-0" />
                <div className="flex-1">
                  <div className="h-3 w-40 rounded bg-gray-200" />
                  <div className="h-3 w-24 mt-1.5 rounded bg-gray-100" />
                </div>
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="grid gap-6 lg:grid-cols-2">
        <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
          <div className="h-4 w-28 rounded bg-gray-200 mb-4" />
          <div className="space-y-3">
            {Array.from({ length: 8 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3">
                <div className="h-7 w-7 rounded-md bg-gray-100 shrink-0" />
                <div className="flex-1">
                  <div className="h-3 w-48 rounded bg-gray-200" />
                  <div className="h-3 w-20 mt-1 rounded bg-gray-100" />
                </div>
              </div>
            ))}
          </div>
        </div>
        <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
          <div className="h-4 w-28 rounded bg-gray-200 mb-4" />
          <div className="space-y-1">
            {Array.from({ length: 5 }).map((_, i) => (
              <div key={i} className="flex items-center gap-3 px-3 py-2">
                <div className="h-8 w-8 rounded-full bg-gray-100 shrink-0" />
                <div className="flex-1">
                  <div className="h-3 w-44 rounded bg-gray-200" />
                </div>
                <div className="h-3 w-16 rounded bg-gray-100" />
              </div>
            ))}
          </div>
        </div>
      </div>

      <div className="rounded-xl border border-gray-200 bg-white p-5 shadow-sm">
        <div className="h-4 w-28 rounded bg-gray-200 mb-4" />
        <div className="grid gap-3 sm:grid-cols-3">
          {Array.from({ length: 6 }).map((_, i) => (
            <div key={i} className="flex items-center gap-4 rounded-lg border border-gray-200 px-4 py-3">
              <div className="h-10 w-10 rounded-lg bg-gray-100 shrink-0" />
              <div className="flex-1">
                <div className="h-3 w-32 rounded bg-gray-200" />
                <div className="h-3 w-24 mt-1 rounded bg-gray-100" />
              </div>
            </div>
          ))}
        </div>
      </div>
    </div>
  );
}
