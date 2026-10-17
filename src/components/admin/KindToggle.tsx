"use client";

import { Flame, Sparkles, type LucideIcon } from "lucide-react";

type Kind = "iconica" | "polemica";

const OPTIONS: { id: Kind; label: string; Icon: LucideIcon; on: string }[] = [
  { id: "iconica", label: "Icônica", Icon: Sparkles, on: "text-neutral-950" },
  { id: "polemica", label: "Polêmica", Icon: Flame, on: "text-white" },
];

/** Seletor Icônica / Polêmica com as duas opções à vista; o destaque desliza até a escolhida. */
export default function KindToggle({
  value,
  onChange,
  disabled,
  label,
}: {
  value: Kind;
  onChange: (k: Kind) => void;
  disabled?: boolean;
  label: string;
}) {
  const iconica = value === "iconica";
  return (
    <div
      role="radiogroup"
      aria-label={label}
      className={`relative grid grid-rows-2 gap-0.5 rounded-xl bg-white/5 p-0.5 ring-1 ring-white/10 ${disabled ? "opacity-60" : ""}`}
    >
      <span
        aria-hidden
        className={`absolute inset-x-0.5 top-0.5 h-[calc(50%-3px)] rounded-[10px] shadow-sm transition-all duration-200 ease-out ${
          iconica ? "translate-y-0 bg-cyan" : "translate-y-[calc(100%+2px)] bg-pink"
        }`}
      />
      {OPTIONS.map(({ id, label: text, Icon, on }) => {
        const checked = id === value;
        return (
          <button
            key={id}
            type="button"
            role="radio"
            aria-checked={checked}
            disabled={disabled}
            onClick={() => !checked && onChange(id)}
            className={`relative z-10 flex items-center gap-1.5 rounded-[10px] px-2.5 py-1 text-xs font-bold transition-colors ${
              checked ? on : "text-white/45 hover:text-white/80"
            }`}
          >
            <Icon className="size-3.5" strokeWidth={2.5} aria-hidden />
            {text}
          </button>
        );
      })}
    </div>
  );
}
