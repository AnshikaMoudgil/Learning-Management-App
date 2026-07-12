'use client';

import { ChevronLeft, ChevronRight } from 'lucide-react';

interface PaginationProps {
  currentPage: number;
  totalPages: number;
  onPageChange: (page: number) => void;
}

export default function Pagination({ currentPage, totalPages, onPageChange }: PaginationProps) {
  if (totalPages <= 1) return null;

  const getPageNumbers = (): (number | 'ellipsis')[] => {
    const pages: (number | 'ellipsis')[] = [];
    const delta = 1;

    pages.push(1);

    const rangeStart = Math.max(2, currentPage - delta);
    const rangeEnd = Math.min(totalPages - 1, currentPage + delta);

    if (rangeStart > 2) pages.push('ellipsis');

    for (let i = rangeStart; i <= rangeEnd; i++) {
      pages.push(i);
    }

    if (rangeEnd < totalPages - 1) pages.push('ellipsis');

    if (totalPages > 1) pages.push(totalPages);

    return pages;
  };

  return (
    <div className="flex items-center justify-center gap-2 pt-8">
      <button
        type="button"
        onClick={() => onPageChange(currentPage - 1)}
        disabled={currentPage <= 1}
        className="flex items-center gap-1 rounded-lg border border-zinc-800 bg-zinc-950 px-3 py-2 text-xs font-semibold text-zinc-400 hover:text-zinc-200 transition disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
      >
        <ChevronLeft className="h-4 w-4" />
        Previous
      </button>

      {getPageNumbers().map((page, idx) =>
        page === 'ellipsis' ? (
          <span key={`ellipsis-${idx}`} className="px-2 text-zinc-600 text-sm">...</span>
        ) : (
          <button
            key={page}
            type="button"
            onClick={() => onPageChange(page)}
            className={`min-w-[36px] rounded-lg px-3 py-2 text-xs font-semibold transition cursor-pointer ${
              page === currentPage
                ? 'bg-teal-500/15 text-teal-400 border border-teal-500/20'
                : 'border border-zinc-800 bg-zinc-950 text-zinc-400 hover:text-zinc-200'
            }`}
          >
            {page}
          </button>
        )
      )}

      <button
        type="button"
        onClick={() => onPageChange(currentPage + 1)}
        disabled={currentPage >= totalPages}
        className="flex items-center gap-1 rounded-lg border border-zinc-800 bg-zinc-950 px-3 py-2 text-xs font-semibold text-zinc-400 hover:text-zinc-200 transition disabled:opacity-40 disabled:cursor-not-allowed cursor-pointer"
      >
        Next
        <ChevronRight className="h-4 w-4" />
      </button>
    </div>
  );
}
