"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import OptionCard, { type CardState } from "./OptionCard";
import Results from "./Results";
import ShareButton from "./ShareButton";
import {
  answerRound,
  eliminateOption,
  friendlyError,
  nextRound,
  playJoker,
  startGame,
} from "@/lib/api";
import type { GameMode, JokerName, Jokers, Reveal, Round, Summary } from "@/lib/types";

type Phase = "loading" | "question" | "answering" | "reveal" | "finished" | "error";

type Props = { mode: GameMode; category?: string; quoteId?: string };

const btnPrimary = "rounded-xl bg-amber-400 px-4 py-3 text-center font-bold text-neutral-950 active:scale-[0.98]";
const btnGhost = "rounded-xl bg-white/10 px-4 py-3 text-center font-semibold active:scale-[0.98]";

const JOKERS: { name: JokerName; label: string }[] = [
  { name: "fifty", label: "50/50" },
  { name: "time", label: "+5s" },
  { name: "skip", label: "Pular" },
];

function storage(key: string, value?: string | null): string | null {
  try {
    if (value === undefined) return sessionStorage.getItem(key);
    if (value === null) sessionStorage.removeItem(key);
    else sessionStorage.setItem(key, value);
  } catch {
    /* modo privado / storage bloqueado: o jogo funciona sem retomar */
  }
  return null;
}

export default function Game({ mode, category, quoteId }: Props) {
  const [phase, setPhase] = useState<Phase>("loading");
  const [error, setError] = useState("");
  const [round, setRound] = useState<Round | null>(null);
  const [eliminated, setEliminated] = useState<string[]>([]);
  const [jokers, setJokers] = useState<Jokers>({});
  const [totalSeconds, setTotalSeconds] = useState(20);
  const [deadline, setDeadline] = useState(0);
  const [now, setNow] = useState(0);
  const [score, setScore] = useState(0);
  const [streak, setStreak] = useState(0);
  const [reveal, setReveal] = useState<Reveal | null>(null);
  const [summary, setSummary] = useState<Summary | null>(null);

  const sessionId = useRef<string | null>(null);
  const busy = useRef(false);
  const autoElim = useRef(0);
  const started = useRef(false);
  const storageKey = `qdi:sid:${mode}:${category ?? ""}:${quoteId ?? ""}`;

  const fail = useCallback((e: unknown) => {
    busy.current = false;
    setError(friendlyError(e));
    setPhase("error");
  }, []);

  const loadRound = useCallback(
    async (sid: string) => {
      const r = await nextRound(sid);
      busy.current = false;
      if (r.finished) {
        storage(storageKey, null);
        setSummary(r);
        setPhase("finished");
        return;
      }
      const t = Date.now();
      setRound(r);
      setEliminated(r.eliminated);
      setJokers(r.jokers);
      setTotalSeconds(r.total_seconds);
      setScore(r.score);
      setStreak(r.streak);
      setReveal(null);
      setNow(t);
      setDeadline(t + r.seconds_left * 1000);
      autoElim.current = 0;
      setPhase("question");
    },
    [storageKey],
  );

  const begin = useCallback(
    async (fresh: boolean) => {
      setPhase("loading");
      try {
        // No solo, recarregar a página retoma a partida em andamento (o relógio é do servidor).
        const saved = !fresh && mode === "solo" ? storage(storageKey) : null;
        if (saved) {
          try {
            sessionId.current = saved;
            await loadRound(saved);
            return;
          } catch {
            storage(storageKey, null);
          }
        }
        const sid = await startGame(mode, { category, quoteId });
        sessionId.current = sid;
        if (mode === "solo") storage(storageKey, sid);
        await loadRound(sid);
      } catch (e) {
        fail(e);
      }
    },
    [mode, category, quoteId, storageKey, loadRound, fail],
  );

  useEffect(() => {
    if (started.current) return;
    started.current = true;
    void begin(false);
  }, [begin]);

  // relógio de exibição (a validação do tempo é feita no servidor)
  useEffect(() => {
    if (phase !== "question") return;
    const id = setInterval(() => setNow(Date.now()), 100);
    return () => clearInterval(id);
  }, [phase]);

  const remaining = Math.max(0, (deadline - now) / 1000);

  const answer = useCallback(
    async (personId: string | null) => {
      if (!round || busy.current) return;
      busy.current = true;
      setPhase("answering");
      try {
        const r = await answerRound(round.round_id, personId);
        busy.current = false;
        setReveal(r);
        setScore(r.score);
        setStreak(r.streak);
        setPhase("reveal");
      } catch (e) {
        fail(e);
      }
    },
    [round, fail],
  );

  // tempo esgotado (reagendado se o curinga +5s mudar o prazo)
  useEffect(() => {
    if (phase !== "question") return;
    const id = setTimeout(() => void answer(null), Math.max(0, deadline - Date.now()));
    return () => clearTimeout(id);
  }, [phase, deadline, answer]);

  // eliminação automática: uma opção errada some a cada terço do tempo (custa pontos)
  useEffect(() => {
    if (phase !== "question" || !round || busy.current) return;
    const elapsed = 1 - remaining / totalSeconds;
    const target = elapsed >= 2 / 3 ? 2 : elapsed >= 1 / 3 ? 1 : 0;
    if (target <= autoElim.current) return;
    autoElim.current = target;
    if (eliminated.length >= 2) return;
    eliminateOption(round.round_id)
      .then(setEliminated)
      .catch(() => {});
  }, [phase, round, remaining, totalSeconds, eliminated.length]);

  // desktop: 1–4 escolhem a carta, Enter avança
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      if (e.metaKey || e.ctrlKey || e.altKey || (e.target as HTMLElement).closest("input, textarea")) return;
      if (phase === "question" && round && /^[1-4]$/.test(e.key)) {
        const o = round.options[Number(e.key) - 1];
        if (o && !eliminated.includes(o.id)) void answer(o.id);
      } else if (phase === "reveal" && e.key === "Enter") {
        e.preventDefault();
        void advanceRef.current();
      }
    }
    window.addEventListener("keydown", onKey);
    return () => window.removeEventListener("keydown", onKey);
  }, [phase, round, eliminated, answer]);

  async function triggerJoker(name: JokerName) {
    if (!round || busy.current || (jokers[name] ?? 0) < 1) return;
    busy.current = true;
    try {
      const r = await playJoker(round.round_id, name);
      setJokers(r.jokers);
      if (name === "skip") {
        await loadRound(sessionId.current!);
        return;
      }
      setEliminated(r.eliminated);
      if (name === "time") {
        setTotalSeconds(r.total_seconds);
        setDeadline((d) => d + 5000);
      }
      busy.current = false;
    } catch (e) {
      fail(e);
    }
  }

  const advanceRef = useRef(advance);
  useEffect(() => {
    advanceRef.current = advance;
  });

  async function advance() {
    if (busy.current || !sessionId.current) return;
    busy.current = true;
    try {
      await loadRound(sessionId.current);
    } catch (e) {
      fail(e);
    }
  }

  if (phase === "loading") {
    return <p className="m-auto animate-pulse text-white/60">Carregando…</p>;
  }

  if (phase === "error") {
    return (
      <div className="m-auto flex max-w-xs flex-col gap-4 text-center">
        <p className="text-white/80">{error}</p>
        <button type="button" className={btnPrimary} onClick={() => void begin(true)}>
          Tentar de novo
        </button>
        <Link href="/" className={btnGhost}>
          Início
        </Link>
      </div>
    );
  }

  if (phase === "finished" && summary) {
    return <Results summary={summary} onReplay={() => void begin(true)} />;
  }

  if (!round) return null;

  const revealed = phase === "reveal" && reveal;
  const lowTime = remaining / totalSeconds < 0.25;
  const multiplier = 1 + Math.min(streak, 4) * 0.25;

  function cardState(id: string): CardState {
    if (revealed) {
      if (id === reveal.person.id) return "correct";
      if (id === reveal.chosen_person_id) return "wrong";
      return "dimmed";
    }
    return eliminated.includes(id) ? "eliminated" : "idle";
  }

  return (
    <div className="flex flex-1 flex-col gap-4 py-4">
      <header className="flex items-center justify-between text-sm">
        <Link href="/" className="text-white/50" aria-label="Voltar ao início">
          ✕
        </Link>
        <span className="text-white/60">
          {round.position}/{round.total_rounds}
        </span>
        <span className="font-bold tabular-nums">
          {score}
          {streak > 1 && <span className="ml-2 text-amber-400">🔥 x{multiplier.toFixed(2).replace(/\.?0+$/, "")}</span>}
        </span>
      </header>

      <div className="h-2 overflow-hidden rounded-full bg-white/10" aria-hidden>
        <div
          className={`h-full ${lowTime ? "bg-rose-500" : "bg-amber-400"}`}
          style={{ width: `${revealed ? 0 : (remaining / totalSeconds) * 100}%` }}
        />
      </div>

      <blockquote className="rounded-2xl bg-white/5 p-5 text-xl font-semibold leading-snug md:p-8 md:text-3xl">
        “{round.quote_text}”
      </blockquote>

      <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
        {round.options.map((o, idx) => (
          <OptionCard
            key={o.id}
            option={o}
            hotkey={idx + 1}
            state={cardState(o.id)}
            disabled={phase !== "question" || eliminated.includes(o.id)}
            onPick={(id) => void answer(id)}
          />
        ))}
      </div>

      {phase !== "reveal" && (
        <div className="flex justify-center gap-2">
          {JOKERS.filter(({ name }) => name in jokers).map(({ name, label }) => (
            <button
              key={name}
              type="button"
              disabled={phase !== "question" || (jokers[name] ?? 0) < 1}
              onClick={() => void triggerJoker(name)}
              className="rounded-full bg-white/10 px-4 py-2 text-sm font-semibold disabled:opacity-30"
            >
              {label} · {jokers[name] ?? 0}
            </button>
          ))}
        </div>
      )}

      {revealed && (
        <section className="mt-auto flex flex-col gap-3 rounded-2xl bg-white/5 p-4 md:mt-2 md:p-6">
          <div className="flex items-baseline justify-between">
            <h2 className={`text-lg font-bold ${reveal.correct ? "text-emerald-400" : "text-rose-400"}`}>
              {reveal.timed_out ? "Tempo esgotado" : reveal.correct ? "Correto" : "Errado"}
            </h2>
            {reveal.correct && (
              <span className="font-bold text-amber-400">
                +{reveal.points}
                {reveal.multiplier > 1 && <span className="ml-1 text-xs">x{reveal.multiplier}</span>}
              </span>
            )}
          </div>
          <p>
            <span className="font-semibold">{reveal.person.name}</span>
            {(reveal.quote.context || reveal.quote.said_on) && (
              <span className="text-sm text-white/60">
                {" "}
                — {[reveal.quote.context, reveal.quote.said_on?.slice(0, 4)].filter(Boolean).join(", ")}
              </span>
            )}
          </p>
          <div className="grid grid-cols-2 gap-2">
            <a
              href={reveal.quote.source_url}
              target="_blank"
              rel="noopener noreferrer"
              className={btnGhost}
            >
              Ver fonte{reveal.quote.source_timestamp ? ` (${reveal.quote.source_timestamp})` : ""} ↗
            </a>
            <ShareButton
              label="Compartilhar"
              className={btnGhost}
              getData={() => ({
                title: "Quem Disse Isso?",
                text: `Quem disse isso? “${reveal.quote.text}”`,
                url: `${window.location.origin}/q/${reveal.quote_id}`,
              })}
            />
          </div>
          {reveal.person.image_credit && (
            <p className="text-center text-xs text-white/40">
              Foto: {reveal.person.image_credit}
              {reveal.person.image_license && ` · ${reveal.person.image_license}`}
            </p>
          )}
          {reveal.quote.archive_url && (
            <a
              href={reveal.quote.archive_url}
              target="_blank"
              rel="noopener noreferrer"
              className="text-center text-xs text-white/40 underline"
            >
              Fonte arquivada
            </a>
          )}
          <button type="button" onClick={() => void advance()} className={btnPrimary}>
            {reveal.finished ? "Ver resultado" : "Próxima"}
            <kbd className="ml-2 hidden text-xs font-normal opacity-60 md:inline">Enter</kbd>
          </button>
        </section>
      )}
    </div>
  );
}
