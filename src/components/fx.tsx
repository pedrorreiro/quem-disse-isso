"use client";

import { useEffect } from "react";
import { MotionConfig, animate, motion, useMotionValue, useTransform } from "motion/react";

/** Respeita "reduzir movimento" do sistema em todo o jogo. */
export function MotionRoot({ children }: { children: React.ReactNode }) {
  return <MotionConfig reducedMotion="user">{children}</MotionConfig>;
}

/** Fundo com manchas de cor em movimento (CSS puro, fica atrás de tudo). */
export function Backdrop() {
  return (
    <div aria-hidden className="pointer-events-none fixed inset-0 -z-10 overflow-hidden">
      <div className="blob left-[-15%] top-[-10%] size-[60vmax] bg-grape" />
      <div className="blob right-[-20%] top-[20%] size-[50vmax] bg-pink [animation-delay:-7s]" />
      <div className="blob bottom-[-25%] left-[10%] size-[45vmax] bg-cyan/60 [animation-delay:-14s]" />
      <div className="grain" />
    </div>
  );
}

/** Número que "conta" até o valor novo. */
export function CountUp({ value, className }: { value: number; className?: string }) {
  const mv = useMotionValue(value);
  const text = useTransform(mv, (v) => Math.round(v).toLocaleString("pt-BR"));
  useEffect(() => {
    const controls = animate(mv, value, { duration: 0.8, ease: "easeOut" });
    return () => controls.stop();
  }, [mv, value]);
  return <motion.span className={className}>{text}</motion.span>;
}

const CONFETTI_COLORS = ["#c8ff2e", "#ff4fb8", "#3ee6ff", "#ffd43b", "#a78bfa"];

/** Explosão de confete (posições determinísticas, sem dependência externa). */
export function Confetti({ count = 28 }: { count?: number }) {
  return (
    <div aria-hidden className="pointer-events-none fixed inset-0 z-50 flex items-center justify-center overflow-hidden">
      {Array.from({ length: count }, (_, i) => {
        const angle = (i * 137.5 * Math.PI) / 180;
        const dist = 140 + ((i * 53) % 160);
        const x = Math.cos(angle) * dist;
        const y = Math.sin(angle) * dist - 80;
        const wide = i % 3 === 0;
        return (
          <motion.span
            key={i}
            className="absolute rounded-sm"
            style={{
              width: wide ? 14 : 8,
              height: wide ? 6 : 12,
              background: CONFETTI_COLORS[i % CONFETTI_COLORS.length],
            }}
            initial={{ x: 0, y: 0, opacity: 1, rotate: 0, scale: 0.4 }}
            animate={{ x, y: [y, y + 260], opacity: [1, 1, 0], rotate: (i % 2 ? 1 : -1) * (180 + i * 20), scale: 1 }}
            transition={{ duration: 1.3, ease: [0.15, 0.6, 0.35, 1], times: [0, 0.7, 1] }}
          />
        );
      })}
    </div>
  );
}

/** Vibração curta no celular (ignorada onde não existe). */
export function buzz(pattern: number | number[]) {
  try {
    navigator.vibrate?.(pattern);
  } catch {
    /* sem suporte */
  }
}
