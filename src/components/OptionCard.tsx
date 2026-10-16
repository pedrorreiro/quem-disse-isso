"use client";

import { motion, type TargetAndTransition } from "motion/react";
import type { Option } from "@/lib/types";

export type CardState = "idle" | "eliminated" | "correct" | "wrong" | "dimmed";

// inclinação fixa por posição: dá cara de figurinha jogada na mesa
const TILT = [-2.5, 1.8, -1.2, 2.2];

const RING: Record<CardState, string> = {
  idle: "ring-white/15 hover:ring-lime",
  eliminated: "ring-white/5",
  correct: "ring-4 ring-lime shadow-[0_0_40px_-4px_var(--color-lime)]",
  wrong: "ring-4 ring-pink",
  dimmed: "ring-white/5",
};

const ANIM: Record<CardState, TargetAndTransition> = {
  idle: { opacity: 1, scale: 1, x: 0, filter: "grayscale(0)" },
  eliminated: { opacity: 0.25, scale: 0.9, filter: "grayscale(1)" },
  correct: { opacity: 1, scale: [1, 1.1, 1.04], rotate: 0, filter: "grayscale(0)", transition: { duration: 0.5 } },
  wrong: { opacity: 1, scale: 1, x: [0, -12, 12, -9, 9, -4, 0], transition: { duration: 0.5 } },
  dimmed: { opacity: 0.35, scale: 0.96, filter: "grayscale(0.6)" },
};

type Props = {
  option: Option;
  index: number;
  state: CardState;
  disabled: boolean;
  onPick: (id: string) => void;
};

export default function OptionCard({ option, index, state, disabled, onPick }: Props) {
  const tilt = TILT[index % TILT.length];
  return (
    <motion.button
      type="button"
      disabled={disabled}
      onClick={() => onPick(option.id)}
      initial={{ opacity: 0, y: 48, rotate: tilt * 3, scale: 0.85 }}
      animate={{ y: 0, rotate: state === "correct" ? 0 : tilt, ...ANIM[state] }}
      transition={{ type: "spring", stiffness: 380, damping: 22, delay: 0.25 + index * 0.07 }}
      whileHover={disabled ? undefined : { y: -6, rotate: 0, scale: 1.03 }}
      whileTap={disabled ? undefined : { scale: 0.95 }}
      className={`relative flex flex-col overflow-hidden rounded-3xl bg-ink text-left shadow-[0_6px_0_0_rgb(0_0_0/0.5)] ring-2 transition-[box-shadow,--tw-ring-color] ${RING[state]}`}
    >
      {/* eslint-disable-next-line @next/next/no-img-element */}
      <img src={option.image_url} alt="" className="aspect-[4/3] w-full object-cover" draggable={false} />
      <span
        className={`flex flex-1 items-center justify-between gap-2 px-3 py-2.5 font-display text-sm font-bold leading-tight md:text-base ${
          state === "eliminated" ? "line-through" : ""
        }`}
      >
        {option.name}
        <kbd className="hidden rounded-md bg-white/10 px-1.5 font-sans text-xs font-normal text-white/50 md:inline">{index + 1}</kbd>
      </span>

      {(state === "correct" || state === "wrong") && (
        <motion.span
          initial={{ scale: 0, rotate: -40 }}
          animate={{ scale: 1, rotate: state === "correct" ? -8 : 8 }}
          transition={{ type: "spring", stiffness: 500, damping: 14, delay: 0.1 }}
          className={`absolute right-2 top-2 grid size-10 place-items-center rounded-full text-xl font-black shadow-[0_3px_0_0_rgb(0_0_0/0.5)] ${
            state === "correct" ? "bg-lime text-ink" : "bg-pink text-white"
          }`}
          aria-hidden
        >
          {state === "correct" ? "✓" : "✕"}
        </motion.span>
      )}
    </motion.button>
  );
}
