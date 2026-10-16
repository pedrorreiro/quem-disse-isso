"use client";

import Link from "next/link";
import { motion } from "motion/react";
import ShareButton from "./ShareButton";
import { Confetti, CountUp } from "./fx";
import { resultEmojis } from "@/lib/share";
import type { RoundResult, Summary } from "@/lib/types";

const btnPrimary = "btn-pop bg-lime text-ink text-lg";
const btnGhost = "btn-pop bg-white/10 font-bold backdrop-blur";

const TILE: Record<RoundResult, string> = {
  correct: "bg-lime text-ink",
  wrong: "bg-pink text-white",
  skipped: "bg-white/15 text-white/60",
  pending: "bg-white/15 text-white/60",
};
const TILE_ICON: Record<RoundResult, string> = { correct: "✓", wrong: "✕", skipped: "–", pending: "–" };

const pop = (delay: number) => ({
  initial: { opacity: 0, y: 24, scale: 0.9 },
  animate: { opacity: 1, y: 0, scale: 1 },
  transition: { type: "spring" as const, stiffness: 320, damping: 22, delay },
});

function ddmm(day: string) {
  const [, m, d] = day.split("-");
  return `${d}/${m}`;
}

export default function Results({ summary, onReplay }: { summary: Summary; onReplay?: () => void }) {
  const emojis = resultEmojis(summary.results);
  const isDaily = summary.mode === "daily";

  const getData = () => {
    const origin = window.location.origin;
    const head = isDaily && summary.daily_day ? `Quem Disse Isso? — Desafio do dia ${ddmm(summary.daily_day)}` : "Quem Disse Isso?";
    return {
      title: "Quem Disse Isso?",
      text: `${head}\n${emojis}\n${summary.correct}/${summary.total_rounds} • ${summary.score} pts`,
      url: `${origin}${isDaily ? "/diario" : "/"}`,
    };
  };

  const good = summary.total_rounds > 0 && summary.correct / summary.total_rounds >= 0.6;

  return (
    <div className="flex flex-1 flex-col gap-6 py-6">
      {good && <Confetti count={40} />}
      <motion.div {...pop(0)} className="text-center">
        <p className="inline-block -rotate-2 rounded-lg bg-white/10 px-3 py-1 font-display text-xs font-bold uppercase tracking-widest text-white/70">
          {isDaily ? "Desafio do dia" : "Resultado"}
        </p>
        <p className="mt-3 font-display text-7xl font-black text-lime drop-shadow-[0_6px_0_rgb(0_0_0/0.5)] md:text-8xl">
          <CountUp value={summary.score} />
        </p>
        <p className="font-display font-bold text-white/60">pontos</p>
      </motion.div>

      <div className="flex flex-wrap justify-center gap-2" role="img" aria-label={`Resumo das rodadas: ${emojis}`}>
        {summary.results.map((r, i) => (
          <motion.span
            key={i}
            initial={{ rotateY: 90, opacity: 0 }}
            animate={{ rotateY: 0, opacity: 1 }}
            transition={{ duration: 0.35, delay: 0.3 + i * 0.08 }}
            className={`grid size-11 place-items-center rounded-xl font-display text-lg font-black shadow-[0_4px_0_0_rgb(0_0_0/0.5)] ${TILE[r]}`}
            aria-hidden
          >
            {TILE_ICON[r]}
          </motion.span>
        ))}
      </div>

      <dl className="grid grid-cols-2 gap-3 text-center md:mx-auto md:w-full md:max-w-md">
        <motion.div {...pop(0.5)} className="-rotate-1 rounded-3xl bg-white/[0.07] p-4 ring-1 ring-white/10 backdrop-blur">
          <dt className="text-xs font-bold uppercase tracking-wide text-white/50">Acertos</dt>
          <dd className="font-display text-3xl font-black">
            {summary.correct}/{summary.total_rounds}
          </dd>
        </motion.div>
        <motion.div {...pop(0.6)} className="rotate-1 rounded-3xl bg-white/[0.07] p-4 ring-1 ring-white/10 backdrop-blur">
          <dt className="text-xs font-bold uppercase tracking-wide text-white/50">Maior sequência</dt>
          <dd className="font-display text-3xl font-black">🔥 {summary.best_streak}</dd>
        </motion.div>
      </dl>

      <motion.div {...pop(0.75)} className="mt-auto flex flex-col gap-3 md:mx-auto md:w-full md:max-w-md">
        <ShareButton label="Compartilhar resultado" getData={getData} className={btnPrimary} />
        {summary.mode === "solo" && onReplay && (
          <button type="button" onClick={onReplay} className={btnGhost}>
            Jogar de novo
          </button>
        )}
        {summary.mode === "shared" && (
          <Link href="/jogar" className={btnGhost}>
            Jogar uma partida completa
          </Link>
        )}
        <Link href="/" className={btnGhost}>
          Início
        </Link>
      </motion.div>
    </div>
  );
}
