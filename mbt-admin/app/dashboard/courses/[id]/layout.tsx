'use client';

import { useParams, usePathname } from 'next/navigation';
import Link from 'next/link';
import { ArrowLeft, LayoutList, FileText, Edit3 } from 'lucide-react';

const TABS = [
  { href: 'syllabus', label: 'Syllabus', icon: LayoutList },
  { href: 'resources', label: 'Resources', icon: FileText },
  { href: 'renewal-plans', label: 'Renewal Plans', icon: FileText },
  { href: 'edit', label: 'Edit Course', icon: Edit3 },
];

export default function CourseLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const params = useParams();
  const courseId = params?.id as string;
  const activeTab = pathname.split('/').pop() || '';

  return (
    <div className="space-y-6 animate-in fade-in duration-300">
      <Link
        href="/dashboard/courses"
        className="inline-flex items-center gap-2 text-xs font-semibold text-gray-500 hover:text-gray-900 transition-colors"
      >
        <ArrowLeft className="h-4 w-4" /> Back to Courses
      </Link>

      <div className="flex gap-1 rounded-xl bg-white border border-gray-200 shadow-sm p-1">
        {TABS.map(({ href, label, icon: Icon }) => {
          const isActive = activeTab === href;
          return (
            <Link
              key={href}
              href={`/dashboard/courses/${courseId}/${href}`}
              className={`flex items-center gap-2 rounded-lg px-4 py-2.5 text-sm font-semibold transition-all ${
                isActive
                  ? 'bg-gray-100 text-gray-900 shadow-sm'
                  : 'text-gray-400 hover:text-gray-600'
              }`}
            >
              <Icon className="h-4 w-4" />
              {label}
            </Link>
          );
        })}
      </div>

      {children}
    </div>
  );
}
