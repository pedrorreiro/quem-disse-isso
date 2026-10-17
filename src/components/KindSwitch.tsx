"use client";

import { Flame, Sparkles, type LucideIcon } from "lucide-react";
import { KIND_LABELS, KINDS, type Kind } from "@/lib/kind";
import { useKind } from "@/lib/useKind";

const ICON: Record<Kind, LucideIcon> = { iconica: Sparkles, polemica: Flame };
const ON: Record<Kind, string> = { iconica: "bg-cyan text-ink", polemica: "bg-pink text-white" };

/** Seletor Icônicas / Polêmicas: vale para o Jogar e para as categorias. */
export default function KindSwitch({ className = "" }: { className?: string }) {
  const [kind, setKind] = useKind();
  return (
    <div role="radiogroup" aria-label="Tipo de frase" className={`grid grid-cols-2 gap-1 rounded-2xl bg-white/10 p-1 md:backdrop-blur ${className}`}>
      {KINDS.map((k) => {
        const Icon = ICON[k];
        const on = k === kind;
        return (
          <button
            key={k}
            type="button"
            role="radio"
            aria-checked={on}
            onClick={() => setKind(k)}
            className={`flex items-center justify-center gap-1.5 rounded-xl py-2.5 font-display text-base font-black transition-colors ${
              on ? ON[k] : "text-white/60 hover:text-white"
            }`}
          >
            <Icon className="size-4" strokeWidth={2.5} aria-hidden />
            {KIND_LABELS[k]}
          </button>
        );
      })}
    </div>
  );
}
