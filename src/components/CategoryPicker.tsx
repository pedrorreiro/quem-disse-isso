"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { motion } from "motion/react";
import { listCategories } from "@/lib/api";
import { categoryLabel } from "@/lib/share";

const CHIP = ["bg-cyan text-ink", "bg-pink text-white", "bg-grape text-white", "bg-white/10 text-white"];

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
      <h2 className="mb-3 font-display text-sm font-bold uppercase tracking-widest text-white/50 md:text-center">Por categoria</h2>
      <div className="flex flex-wrap gap-2 md:justify-center">
        {categories.map((c, i) => (
          <motion.div
            key={c}
            initial={{ opacity: 0, scale: 0.6 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ type: "spring", stiffness: 400, damping: 18, delay: 1 + i * 0.05 }}
            whileHover={{ rotate: i % 2 ? 3 : -3 }}
          >
            <Link
              href={`/jogar?cat=${encodeURIComponent(c)}`}
              className={`btn-pop block rounded-full px-4 py-2 text-sm ${CHIP[i % CHIP.length]}`}
            >
              {categoryLabel(c)}
            </Link>
          </motion.div>
        ))}
      </div>
    </section>
  );
}
