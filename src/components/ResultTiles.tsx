"use client";

import { motion } from "motion/react";
import { Check, Minus, X, type LucideIcon } from "lucide-react";
import type { RoundResult } from "@/lib/types";

const TILE: Record<RoundResult, string> = {
  correct: "bg-lime text-ink",
  wrong: "bg-pink text-white",
  skipped: "bg-white/15 text-white/60",
  pending: "bg-white/15 text-white/60",
};
const ICON: Record<RoundResult, LucideIcon> = { correct: Check, wrong: X, skipped: Minus, pending: Minus };
const LABEL: Record<RoundResult, string> = { correct: "acerto", wrong: "erro", skipped: "pulada", pending: "pulada" };

/** Quadradinhos de acerto/erro por rodada, que viram em sequência. */
export default function ResultTiles({
  results,
  size = "md",
  delay = 0.3,
  className = "",
}: {
  results: RoundResult[];
  size?: "sm" | "md";
  delay?: number;
  className?: string;
}) {
  const box = size === "sm" ? "size-7 rounded-lg" : "size-11 rounded-xl";
  const icon = size === "sm" ? "size-3.5" : "size-5";
  return (
    <div
      className={`flex flex-wrap justify-center gap-1.5 md:gap-2 ${className}`}
      role="img"
      aria-label={`Rodadas: ${results.map((r) => LABEL[r]).join(", ")}`}
    >
      {results.map((r, i) => {
        const Icon = ICON[r];
        return (
          <motion.span
            key={i}
            initial={{ rotateY: 90, opacity: 0 }}
            animate={{ rotateY: 0, opacity: 1 }}
            transition={{ duration: 0.35, delay: delay + i * 0.06 }}
            className={`grid place-items-center shadow-[0_3px_0_0_rgb(0_0_0/0.5)] ${box} ${TILE[r]}`}
            aria-hidden
          >
            <Icon className={icon} strokeWidth={3.5} />
          </motion.span>
        );
      })}
    </div>
  );
}
