"use client";

import { useEffect } from "react";
import { motion } from "motion/react";
import { Flame } from "lucide-react";
import { useKind } from "@/lib/useKind";

/** Interruptor do modo polêmica: desligado, o jogo usa as frases icônicas (o padrão). */
export default function KindSwitch({ className = "" }: { className?: string }) {
  const [kind, setKind] = useKind();
  const on = kind === "polemica";
  return (
    <button
      type="button"
      role="switch"
      aria-checked={on}
      onClick={() => setKind(on ? "iconica" : "polemica")}
      className={`flex w-full items-center gap-3 rounded-2xl p-3 text-left ring-1 transition-colors md:backdrop-blur ${
        on ? "bg-pink/15 ring-pink/60" : "bg-white/[0.07] ring-white/10 hover:bg-white/10"
      } ${className}`}
    >
      <span
        className={`grid size-10 shrink-0 place-items-center rounded-xl transition-colors ${on ? "bg-pink text-white" : "bg-white/10 text-white/60"}`}
        aria-hidden
      >
        <Flame className={`size-5 ${on ? "fill-white" : ""}`} strokeWidth={2.5} />
      </span>
      <span className="min-w-0 flex-1">
        <span className="block font-display text-base font-black leading-tight">Modo polêmica</span>
        <span className="block text-sm text-white/60">{on ? "Só frases que deram treta" : "Troque os bordões pelas tretas"}</span>
      </span>
      <span className={`flex h-7 w-12 shrink-0 items-center rounded-full p-1 transition-colors ${on ? "justify-end bg-pink" : "justify-start bg-white/20"}`} aria-hidden>
        <motion.span layout transition={{ type: "spring", stiffness: 500, damping: 30 }} className="size-5 rounded-full bg-white shadow" />
      </span>
    </button>
  );
}

/** Põe o tema do modo polêmica na página enquanto o jogo está aberto (o script do layout já cuida do primeiro quadro). */
export function KindTheme() {
  const [kind] = useKind();
  useEffect(() => {
    const root = document.documentElement;
    if (kind === "polemica") root.dataset.mode = "polemica";
    else delete root.dataset.mode;
    return () => {
      delete root.dataset.mode;
    };
  }, [kind]);
  return null;
}
