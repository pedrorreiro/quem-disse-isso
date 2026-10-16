"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { listCategories } from "@/lib/api";
import { categoryLabel } from "@/lib/share";

export default function CategoryPicker() {
  const [categories, setCategories] = useState<string[]>([]);

  useEffect(() => {
    listCategories()
      .then(setCategories)
      .catch(() => {}); // sem banco configurado a home continua abrindo
  }, []);

  if (categories.length === 0) return null;

  return (
    <section>
      <h2 className="mb-3 text-sm uppercase tracking-widest text-white/50 md:text-center">Por categoria</h2>
      <div className="flex flex-wrap gap-2 md:justify-center">
        {categories.map((c) => (
          <Link
            key={c}
            href={`/jogar?cat=${encodeURIComponent(c)}`}
            className="rounded-full bg-white/10 px-4 py-2 text-sm font-semibold active:scale-95"
          >
            {categoryLabel(c)}
          </Link>
        ))}
      </div>
    </section>
  );
}
