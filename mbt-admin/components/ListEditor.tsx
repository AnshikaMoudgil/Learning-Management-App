'use client';

import { Plus, X } from 'lucide-react';

interface ListEditorProps {
  items: string[];
  onChange: (items: string[]) => void;
  placeholder?: string;
  label: string;
}

export default function ListEditor({ items, onChange, placeholder = 'Add an item...', label }: ListEditorProps) {
  const handleChange = (index: number, value: string) => {
    const updated = [...items];
    updated[index] = value;
    onChange(updated);
  };

  const handleRemove = (index: number) => {
    onChange(items.filter((_, i) => i !== index));
  };

  const handleAdd = () => {
    onChange([...items, '']);
  };

  return (
    <div className="space-y-1.5">
      <label className="text-xs font-semibold uppercase tracking-wider text-zinc-400">{label}</label>
      <div className="space-y-2">
        {items.map((item, index) => (
          <div key={index} className="flex gap-2">
            <span className="flex h-10 w-8 shrink-0 items-center justify-center rounded-lg bg-zinc-800 text-xs font-bold text-zinc-400">
              {index + 1}
            </span>
            <input
              type="text"
              value={item}
              onChange={(e) => handleChange(index, e.target.value)}
              placeholder={placeholder}
              className="w-full rounded-lg border border-zinc-800 bg-zinc-950 py-3 px-4 text-sm text-zinc-100 placeholder-zinc-600 outline-none focus:border-teal-500 transition"
            />
            <button
              type="button"
              onClick={() => handleRemove(index)}
              className="flex h-10 w-10 shrink-0 items-center justify-center rounded-lg border border-zinc-800 text-zinc-500 hover:border-rose-900/30 hover:bg-rose-950/20 hover:text-rose-400 transition cursor-pointer"
            >
              <X className="h-4 w-4" />
            </button>
          </div>
        ))}
      </div>
      <button
        type="button"
        onClick={handleAdd}
        className="flex items-center gap-2 rounded-lg border border-dashed border-zinc-800 bg-zinc-950/50 px-4 py-2.5 text-sm font-semibold text-teal-400 hover:border-teal-500/40 hover:bg-teal-500/5 transition cursor-pointer w-full"
      >
        <Plus className="h-4 w-4" />
        Add {label.toLowerCase()}
      </button>
    </div>
  );
}
