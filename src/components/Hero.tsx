"use client";

import Link from "next/link";
import { motion } from "motion/react";
import { CalendarDays, Play, Quote } from "lucide-react";

function Letters({ text, className, delay }: { text: string; className?: string; delay: number }) {
  return (
    <span className={`inline-block ${className ?? ""}`} aria-hidden>
      {Array.from(text).map((ch, i) => (
        <motion.span
          key={i}
          className="inline-block"
          initial={{ opacity: 0, y: 40, rotate: (i % 2 ? 1 : -1) * 20 }}
          animate={{ opacity: 1, y: 0, rotate: 0 }}
          transition={{ type: "spring", stiffness: 420, damping: 18, delay: delay + i * 0.04 }}
        >
          {ch === " " ? " " : ch}
        </motion.span>
      ))}
    </span>
  );
}

export default function Hero() {
  return (
    <>
      <header className="text-center">
        <motion.span
          initial={{ scale: 0, rotate: -30 }}
          animate={{ scale: 1, rotate: -8 }}
          transition={{ type: "spring", stiffness: 400, damping: 12, delay: 0.7 }}
          className="mb-4 inline-grid size-16 place-items-center rounded-2xl bg-pink text-white shadow-[0_5px_0_0_rgb(0_0_0/0.5)]"
          aria-hidden
        >
          <Quote className="size-8 fill-white" />
        </motion.span>
        <h1 className="font-display text-6xl font-black leading-[0.9] tracking-tight md:text-8xl" aria-label="Quem disse isso?">
          <Letters text="Quem" delay={0} />
          <br />
          <Letters text="disse isso?" className="text-lime" delay={0.2} />
        </h1>
        <motion.p
          initial={{ opacity: 0 }}
          animate={{ opacity: 1 }}
          transition={{ delay: 0.8 }}
          className="mt-5 text-white/70"
        >
          Aparece a frase. Você descobre quem soltou essa pérola.
        </motion.p>
      </header>

      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ type: "spring", stiffness: 260, damping: 22, delay: 0.9 }}
        className="flex flex-col gap-4 md:mx-auto md:w-full md:max-w-md"
      >
        <Link href="/jogar" className="btn-pop flex items-center justify-center gap-2 bg-lime py-5 font-display text-2xl font-black text-ink">
          <Play className="size-6 fill-ink" aria-hidden />
          Jogar
        </Link>
        <Link href="/diario" className="btn-pop flex items-center justify-center gap-2 bg-white/10 py-4 font-display text-lg backdrop-blur">
          <CalendarDays className="size-5" aria-hidden />
          Desafio do dia
        </Link>
      </motion.div>
    </>
  );
}
