import Link from "next/link";
import ShareButton from "./ShareButton";
import { resultEmojis } from "@/lib/share";
import type { Summary } from "@/lib/types";

const btnPrimary = "rounded-xl bg-amber-400 px-4 py-3 text-center font-bold text-neutral-950 active:scale-[0.98]";
const btnGhost = "rounded-xl bg-white/10 px-4 py-3 text-center font-semibold active:scale-[0.98]";

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

  return (
    <div className="flex flex-1 flex-col gap-6 py-6">
      <div className="text-center">
        <p className="text-sm uppercase tracking-widest text-white/50">
          {isDaily ? "Desafio do dia" : "Resultado"}
        </p>
        <p className="mt-2 text-6xl font-black text-amber-400">{summary.score}</p>
        <p className="text-white/60">pontos</p>
      </div>

      <p className="text-center text-2xl tracking-normal" aria-label="Resumo das rodadas">
        {emojis}
      </p>

      <dl className="grid grid-cols-2 gap-3 text-center md:mx-auto md:w-full md:max-w-md">
        <div className="rounded-2xl bg-white/5 p-4">
          <dt className="text-xs uppercase tracking-wide text-white/50">Acertos</dt>
          <dd className="text-2xl font-bold">
            {summary.correct}/{summary.total_rounds}
          </dd>
        </div>
        <div className="rounded-2xl bg-white/5 p-4">
          <dt className="text-xs uppercase tracking-wide text-white/50">Maior sequência</dt>
          <dd className="text-2xl font-bold">{summary.best_streak}</dd>
        </div>
      </dl>

      <div className="mt-auto flex flex-col gap-3 md:mx-auto md:w-full md:max-w-md">
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
      </div>
    </div>
  );
}
