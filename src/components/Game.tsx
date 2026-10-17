"use client";

import { useCallback, useEffect, useRef, useState } from "react";
import Link from "next/link";
import { AnimatePresence, motion } from "motion/react";
import {
  ArrowRight,
  Check,
  CircleCheck,
  CircleX,
  ExternalLink,
  Flame,
  Hourglass,
  Quote,
  SkipForward,
  SquareSplitHorizontal,
  TimerOff,
  X,
  type LucideIcon,
} from "lucide-react";
import OptionCard, { type CardState } from "./OptionCard";
import Results from "./Results";
import ShareButton from "./ShareButton";
import { Confetti, CountUp, buzz } from "./fx";
import {
  answerRound,
  friendlyError,
  nextRound,
  playJoker,
  startGame,
} from "@/lib/api";
import { quoteDetail } from "@/lib/share";
import type { GameMode, JokerName, Jokers, Reveal, Round, Summary } from "@/lib/types";

type Phase = "loading" | "question" | "answering" | "reveal" | "finished" | "error";

type Props = { mode: GameMode; category?: string; quoteId?: string; challengeId?: string };

const btnPrimary = "btn-pop bg-lime text-ink";
const btnGhost = "btn-pop bg-white/10 font-bold backdrop-blur";

const JOKERS: { name: JokerName; label: string; icon: LucideIcon }[] = [
  { name: "fifty", label: "50/50", icon: SquareSplitHorizontal },
  { name: "time", label: "+5s", icon: Hourglass },
  { name: "skip", label: "Pular", icon: SkipForward },
];

// frases longas ganham fonte menor para caber sem rolar
function quoteSize(text: string) {
  if (text.length > 160) return "text-xl md:text-3xl";
  if (text.length > 90) return "text-2xl md:text-4xl";
  return "text-3xl md:text-5xl";
}

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

// Só a primeira partida aberta depois de recarregar a página retoma a anterior. Entrar pelo botão
// Jogar (navegação dentro do app ou link novo) sempre começa do zero.
let canResume = true;
function shouldResume() {
  const ok = canResume;
  canResume = false;
  if (!ok) return false;
  try {
    const nav = performance.getEntriesByType("navigation")[0] as PerformanceNavigationTiming | undefined;
    return nav?.type === "reload";
  } catch {
    return false;
  }
}

export default function Game({ mode, category, quoteId, challengeId }: Props) {
  const [phase, setPhase] = useState<Phase>("loading");
  const [error, setError] = useState("");
  const [round, setRound] = useState<Round | null>(null);
  const [eliminated, setEliminated] = useState<string[]>([]);
  const [jokers, setJokers] = useState<Jokers>({});
  const [totalSeconds, setTotalSeconds] = useState(30);
  const [deadline, setDeadline] = useState(0);
  const [now, setNow] = useState(0);
  // resultado de cada rodada (posição → acerto/erro), para as bolinhas e o contador de acertos
  const [history, setHistory] = useState<Record<number, "correct" | "wrong" | "skipped">>({});
  const [streak, setStreak] = useState(0);
  const [reveal, setReveal] = useState<Reveal | null>(null);
  const [picked, setPicked] = useState<string | null>(null);
  const [openDetail, setOpenDetail] = useState<string | null>(null); // quote_id com o contexto aberto
  const [summary, setSummary] = useState<Summary | null>(null);

  const sessionId = useRef<string | null>(null);
  const busy = useRef(false);
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
      setStreak(r.streak);
      setReveal(null);
      setPicked(null);
      setNow(t);
      setDeadline(t + r.seconds_left * 1000);
      setPhase("question");
    },
    [storageKey],
  );

  const begin = useCallback(
    async (fresh: boolean) => {
      setPhase("loading");
      setHistory({});
      try {
        // No solo, recarregar a página retoma a partida em andamento (o relógio é do servidor).
        const saved = !fresh && mode === "solo" && shouldResume() ? storage(storageKey) : null;
        if (saved) {
          try {
            sessionId.current = saved;
            await loadRound(saved);
            return;
          } catch {
            storage(storageKey, null);
          }
        }
        const sid = await startGame(mode, { category, quoteId, challengeId });
        sessionId.current = sid;
        if (mode === "solo") storage(storageKey, sid);
        await loadRound(sid);
      } catch (e) {
        fail(e);
      }
    },
    [mode, category, quoteId, challengeId, storageKey, loadRound, fail],
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
      setPicked(personId);
      setPhase("answering");
      try {
        const r = await answerRound(round.round_id, personId);
        busy.current = false;
        setReveal(r);
        setHistory((h) => ({ ...h, [round.position]: r.correct ? "correct" : "wrong" }));
        setStreak(r.streak);
        setPhase("reveal");
        buzz(r.correct ? 30 : [40, 40, 40]);
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
        setHistory((h) => ({ ...h, [round.position]: "skipped" }));
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
    return (
      <div className="m-auto flex flex-col items-center gap-4" role="status" aria-label="Carregando">
        <div className="flex gap-2">
          {["bg-lime", "bg-pink", "bg-cyan"].map((c, i) => (
            <motion.span
              key={c}
              className={`size-4 rounded-full ${c}`}
              animate={{ y: [0, -14, 0] }}
              transition={{ duration: 0.6, repeat: Infinity, delay: i * 0.12, ease: "easeInOut" }}
            />
          ))}
        </div>
        <p className="font-display text-sm font-bold text-white/60">Embaralhando as frases…</p>
      </div>
    );
  }

  if (phase === "error") {
    return (
      <motion.div
        initial={{ opacity: 0, scale: 0.9 }}
        animate={{ opacity: 1, scale: 1 }}
        className="m-auto flex max-w-xs flex-col gap-4 text-center"
      >
        <p className="text-white/80">{error}</p>
        <button type="button" className={btnPrimary} onClick={() => void begin(true)}>
          Tentar de novo
        </button>
        <Link href="/" className={btnGhost}>
          Início
        </Link>
      </motion.div>
    );
  }

  if (phase === "finished" && summary) {
    return <Results summary={summary} onReplay={() => void begin(true)} />;
  }

  if (!round) return null;

  const revealed = phase === "reveal" && reveal;
  const fraction = revealed ? 0 : remaining / totalSeconds;
  const lowTime = fraction < 0.25;
  const hits = Object.values(history).filter((v) => v === "correct").length;
  const words = round.quote_text.split(/\s+/);

  function cardState(id: string): CardState {
    if (revealed) {
      if (id === reveal.person.id) return "correct";
      if (id === reveal.chosen_person_id) return "wrong";
      return "dimmed";
    }
    if (eliminated.includes(id)) return "eliminated";
    if (phase === "answering" && picked) return id === picked ? "picked" : "dimmed";
    return "idle";
  }

  const verdict = revealed
    ? reveal.timed_out
      ? { label: "Tempo esgotado", Icon: TimerOff, cls: "bg-pink text-white" }
      : reveal.correct
        ? { label: "Correto", Icon: CircleCheck, cls: "bg-lime text-ink" }
        : { label: "Errado", Icon: CircleX, cls: "bg-pink text-white" }
    : null;

  return (
    <div className="flex flex-1 flex-col gap-4 py-4 md:justify-center md:py-10">
      {/* resultado da rodada: aviso no topo da tela */}
      <div className="pointer-events-none fixed inset-x-0 top-3 z-40 flex justify-center">
      <AnimatePresence>
        {revealed && verdict && (
          <motion.div
            key={reveal.quote_id}
            role="status"
            initial={{ y: -90, opacity: 0, rotate: -4 }}
            animate={{ y: 0, opacity: 1, rotate: -1.5 }}
            exit={{ y: -90, opacity: 0 }}
            transition={{ type: "spring", stiffness: 420, damping: 20 }}
            className={`flex items-center gap-2 rounded-2xl px-5 py-3 font-display text-xl font-black uppercase shadow-[0_6px_0_0_rgb(0_0_0/0.5)] ${verdict.cls}`}
          >
            <verdict.Icon className="size-6" strokeWidth={3} aria-hidden />
            {verdict.label}
          </motion.div>
        )}
      </AnimatePresence>
      </div>

      <header className="flex items-center justify-between gap-3">
        <Link
          href="/"
          className="grid size-10 place-items-center rounded-full bg-white/10 text-white/70 transition hover:bg-white/20"
          aria-label="Voltar ao início"
        >
          <X className="size-5" />
        </Link>

        {/* progresso: uma bolinha por rodada */}
        <div className="flex flex-1 justify-center gap-1.5" aria-label={`Rodada ${round.position} de ${round.total_rounds}`}>
          {Array.from({ length: round.total_rounds }, (_, i) => (
            <motion.span
              key={i}
              layout
              className={`h-2 rounded-full ${
                history[i + 1] === "correct"
                  ? "bg-lime"
                  : history[i + 1] === "wrong"
                    ? "bg-pink"
                    : i + 1 === round.position
                      ? "bg-white"
                      : i + 1 < round.position
                        ? "bg-white/50"
                        : "bg-white/15"
              }`}
              animate={{ width: i + 1 === round.position ? 22 : 8 }}
            />
          ))}
        </div>

        <div className="flex items-center gap-2">
          <AnimatePresence>
            {streak > 1 && (
              <motion.span
                key={streak}
                initial={{ scale: 0, rotate: -30 }}
                animate={{ scale: 1, rotate: -6 }}
                exit={{ scale: 0 }}
                transition={{ type: "spring", stiffness: 500, damping: 15 }}
                className="flex items-center gap-0.5 rounded-full bg-pink px-2.5 py-1 font-display text-xs font-black text-white shadow-[0_3px_0_0_rgb(0_0_0/0.5)]"
                aria-label={`${streak} acertos seguidos`}
              >
                <Flame className="size-3.5 fill-white" aria-hidden />
                {streak}
              </motion.span>
            )}
          </AnimatePresence>
          <span
            className="flex items-center gap-1 rounded-full bg-white/10 px-3 py-1 font-display text-lg font-black tabular-nums text-lime"
            aria-label={`${hits} acertos`}
          >
            <Check className="size-4" strokeWidth={3.5} aria-hidden />
            <CountUp value={hits} />
          </span>
        </div>
      </header>

      {/* barra de tempo */}
      <div className="flex items-center gap-3" aria-hidden>
        <div className="h-3 flex-1 overflow-hidden rounded-full bg-white/10">
          <motion.div
            className={`h-full rounded-full ${lowTime ? "bg-pink" : "bg-gradient-to-r from-cyan to-lime"}`}
            style={{ width: `${fraction * 100}%` }}
            animate={lowTime && !revealed ? { opacity: [1, 0.45, 1] } : { opacity: 1 }}
            transition={lowTime ? { duration: 0.6, repeat: Infinity } : undefined}
          />
        </div>
        <span
          className={`w-9 text-right font-display text-sm font-black tabular-nums ${lowTime && !revealed ? "text-pink" : "text-white/60"}`}
        >
          {Math.ceil(revealed ? 0 : remaining)}s
        </span>
      </div>

      <AnimatePresence mode="wait">
        <motion.div
          key={round.round_id}
          initial={{ opacity: 0, x: 60 }}
          animate={{ opacity: 1, x: 0 }}
          exit={{ opacity: 0, x: -60, transition: { duration: 0.2 } }}
          transition={{ type: "spring", stiffness: 260, damping: 26 }}
          className="flex flex-col gap-4"
        >
          <blockquote className="relative rounded-[2rem] bg-white/[0.07] p-6 pt-8 ring-1 ring-white/10 backdrop-blur-md md:p-10">
            <motion.span
              aria-hidden
              initial={{ scale: 0, rotate: -40 }}
              animate={{ scale: 1, rotate: -10 }}
              transition={{ type: "spring", stiffness: 400, damping: 12, delay: 0.1 }}
              className="absolute -left-2 -top-4 grid size-12 place-items-center rounded-2xl bg-pink text-white shadow-[0_4px_0_0_rgb(0_0_0/0.5)]"
            >
              <Quote className="size-6 fill-white" />
            </motion.span>
            <p className={`font-display font-extrabold leading-[1.15] tracking-tight ${quoteSize(round.quote_text)}`}>
              <span className="sr-only">{round.quote_text}</span>
              <span aria-hidden>
                {words.map((w, i) => (
                  <motion.span
                    key={i}
                    className="inline-block"
                    initial={{ opacity: 0, y: 14, filter: "blur(6px)" }}
                    animate={{ opacity: 1, y: 0, filter: "blur(0px)" }}
                    transition={{ duration: 0.3, delay: Math.min(i * 0.035, 0.9) }}
                  >
                    {w}&nbsp;
                  </motion.span>
                ))}
              </span>
            </p>
          </blockquote>

          <div className="grid grid-cols-2 gap-3 md:grid-cols-4">
            {round.options.map((o, idx) => (
              <OptionCard
                key={o.id}
                option={o}
                index={idx}
                state={cardState(o.id)}
                disabled={phase !== "question" || eliminated.includes(o.id)}
                onPick={(id) => void answer(id)}
              />
            ))}
          </div>
        </motion.div>
      </AnimatePresence>

      {revealed && reveal.correct && <Confetti key={reveal.quote_id} />}

      {/* curingas (somem na revelação) */}
      <AnimatePresence initial={false}>
        {!revealed && (
          <motion.div key="jokers" exit={{ opacity: 0 }} className="flex justify-center gap-2">
            {JOKERS.filter(({ name }) => name in jokers).map(({ name, label, icon: Icon }) => (
              <motion.button
                key={name}
                type="button"
                whileTap={{ scale: 0.9, rotate: -4 }}
                disabled={phase !== "question" || (jokers[name] ?? 0) < 1}
                onClick={() => void triggerJoker(name)}
                className="btn-pop flex items-center gap-1.5 rounded-full bg-white/10 px-4 py-2 text-sm backdrop-blur"
              >
                <Icon className="size-4" aria-hidden />
                {label}
                <span className="grid size-5 place-items-center rounded-full bg-white/15 text-xs">{jokers[name] ?? 0}</span>
              </motion.button>
            ))}
          </motion.div>
        )}
      </AnimatePresence>

      {/* revelação: painel por cima de tudo, sem precisar rolar a tela */}
      <AnimatePresence>
        {revealed && (
          <>
            <motion.div
              key="shade"
              aria-hidden
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              className="fixed inset-0 z-30 bg-ink/50"
            />
            <motion.section
              key="sheet"
              aria-label="Resposta"
              initial={{ y: "110%" }}
              animate={{ y: 0 }}
              exit={{ y: "110%" }}
              transition={{ type: "spring", stiffness: 300, damping: 30, delay: 0.25 }}
              className="fixed inset-x-0 bottom-0 z-30 px-2 md:px-8"
            >
              <div className="mx-auto flex max-w-md flex-col gap-4 rounded-t-[2rem] bg-[#1d1230]/95 p-5 pb-[max(1.25rem,env(safe-area-inset-bottom))] shadow-[0_-10px_40px_rgb(0_0_0/0.5)] ring-1 ring-white/10 backdrop-blur-xl md:max-w-3xl md:p-6">
                <div className="mx-auto h-1.5 w-10 rounded-full bg-white/20" aria-hidden />
                <div className="flex items-center gap-4">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img
                    src={reveal.person.image_url}
                    alt=""
                    className="size-16 shrink-0 rounded-2xl object-cover ring-4 ring-lime"
                  />
                  <div className="min-w-0">
                    <p className="text-xs font-bold uppercase tracking-widest text-white/50">Quem disse</p>
                    <p className="font-display text-2xl font-black leading-tight">{reveal.person.name}</p>
                    {(reveal.quote.context || reveal.quote.said_on) && (
                      // toque abre o contexto inteiro; o painel cresce para cima
                      <button
                        type="button"
                        aria-expanded={openDetail === reveal.quote_id}
                        onClick={() => setOpenDetail((id) => (id === reveal.quote_id ? null : reveal.quote_id))}
                        className={`block text-left text-sm text-white/60 transition-colors hover:text-white/80 ${
                          openDetail === reveal.quote_id ? "max-h-[45vh] overflow-y-auto" : "line-clamp-2"
                        }`}
                      >
                        {quoteDetail(reveal.quote.context, reveal.quote.said_on)}
                      </button>
                    )}
                  </div>
                </div>
                <div className="flex gap-2">
                  <a
                    href={reveal.quote.source_url}
                    target="_blank"
                    rel="noopener noreferrer"
                    className={`${btnGhost} inline-flex items-center gap-2 px-4 text-sm`}
                  >
                    <ExternalLink className="size-4" aria-hidden />
                    Fonte{reveal.quote.source_timestamp ? ` ${reveal.quote.source_timestamp}` : ""}
                  </a>
                  <ShareButton
                    compact
                    label="Compartilhar"
                    className={`${btnGhost} px-4 text-sm`}
                    image={{ url: `/api/card/frase/${reveal.quote_id}`, name: "quem-disse-isso.png" }}
                    getData={() => ({
                      title: "Quem Disse Isso?",
                      text: "Você acertaria as outras?",
                      url: `${window.location.origin}/q/${reveal.quote_id}`,
                    })}
                  />
                  <button
                    type="button"
                    autoFocus
                    onClick={() => void advance()}
                    className={`${btnPrimary} inline-flex flex-1 items-center justify-center gap-2 text-lg`}
                  >
                    {reveal.finished ? "Resultado" : "Próxima"}
                    <ArrowRight className="size-5" strokeWidth={3} aria-hidden />
                    <kbd className="hidden text-xs font-normal opacity-60 md:inline">Enter</kbd>
                  </button>
                </div>
                {(reveal.person.image_credit || reveal.quote.archive_url) && (
                  <p className="text-center text-[11px] text-white/35">
                    {reveal.person.image_credit && (
                      <>
                        Foto: {reveal.person.image_credit}
                        {reveal.person.image_license && ` · ${reveal.person.image_license}`}
                      </>
                    )}
                    {reveal.quote.archive_url && (
                      <>
                        {reveal.person.image_credit && " · "}
                        <a href={reveal.quote.archive_url} target="_blank" rel="noopener noreferrer" className="underline">
                          Fonte arquivada
                        </a>
                      </>
                    )}
                  </p>
                )}
              </div>
            </motion.section>
          </>
        )}
      </AnimatePresence>
    </div>
  );
}
