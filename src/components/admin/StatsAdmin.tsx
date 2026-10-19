"use client";

import { useEffect, useMemo, useState, type ReactNode } from "react";
import { ArrowRight, Search } from "lucide-react";
import { adminStats, type Stats } from "@/lib/admin";
import { friendlyError } from "@/lib/api";
import { KIND_LABELS } from "@/lib/kind";
import { categoryLabel } from "@/lib/share";
import { Avatar, input } from "./ui";

const PERIODS: { days: number | null; label: string }[] = [
  { days: 1, label: "24 horas" },
  { days: 7, label: "7 dias" },
  { days: 30, label: "30 dias" },
  { days: null, label: "Tudo" },
];

const MODE_LABELS: Record<string, string> = { solo: "Solo", daily: "Diário", shared: "Frase compartilhada", challenge: "Desafio" };

type PersonSort = "answers" | "hardest" | "easiest" | "decoy";

const PERSON_SORTS: { id: PersonSort; label: string }[] = [
  { id: "answers", label: "Mais jogados" },
  { id: "hardest", label: "Mais errados" },
  { id: "easiest", label: "Mais acertados" },
  { id: "decoy", label: "Mais chutados por engano" },
];

const rate = (hits: number, answers: number) => (answers ? hits / answers : 0);
const pct = (hits: number, answers: number) => `${Math.round(rate(hits, answers) * 100)}%`;
const fold = (s: string) => s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();
const fmtDay = (d: string) => new Date(`${d}T12:00:00`).toLocaleDateString("pt-BR", { day: "2-digit", month: "2-digit", weekday: "short" });

/** Cor pela taxa de acerto: vermelho é difícil, verde é fácil. */
function tone(r: number) {
  if (r < 0.4) return { text: "text-rose-300", bar: "bg-rose-400", soft: "bg-rose-500/15" };
  if (r < 0.65) return { text: "text-amber-300", bar: "bg-amber-400", soft: "bg-amber-400/15" };
  return { text: "text-emerald-300", bar: "bg-emerald-400", soft: "bg-emerald-500/15" };
}

/** Estatísticas de acertos e erros: por famoso, por categoria e por dia. */
export default function StatsAdmin() {
  const [days, setDays] = useState<number | null>(null);
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState("");

  useEffect(() => {
    let alive = true;
    adminStats(days)
      .then((s) => alive && (setStats(s), setError("")))
      .catch((e) => alive && setError(friendlyError(e)))
      .finally(() => alive && setLoading(false));
    return () => {
      alive = false;
    };
  }, [days]);

  return (
    <div className={`flex flex-col gap-6 transition-opacity ${loading && stats ? "opacity-50" : ""}`}>
      <div className="flex flex-wrap gap-1">
        {PERIODS.map((p) => (
          <Chip
            key={p.label}
            active={days === p.days}
            onClick={() => {
              setLoading(true);
              setDays(p.days);
            }}
          >
            {p.label}
          </Chip>
        ))}
      </div>

      {error && <p className="text-rose-300">{error}</p>}
      {!stats && !error && <p className="animate-pulse text-white/50">Carregando…</p>}
      {stats && stats.totals.answers === 0 && <p className="text-white/50">Ninguém respondeu nada neste período.</p>}
      {stats && stats.totals.answers > 0 && <StatsBody stats={stats} />}
    </div>
  );
}

function StatsBody({ stats }: { stats: Stats }) {
  const t = stats.totals;
  const hardest = useMemo(
    () =>
      stats.quotes
        .filter((q) => rate(q.hits, q.answers) < 0.5)
        .sort((a, b) => rate(a.hits, a.answers) - rate(b.hits, b.answers) || b.answers - a.answers)
        .slice(0, 6),
    [stats.quotes],
  );
  const easiest = useMemo(
    () =>
      stats.quotes
        .filter((q) => rate(q.hits, q.answers) >= 0.5)
        .sort((a, b) => rate(b.hits, b.answers) - rate(a.hits, a.answers) || b.answers - a.answers)
        .slice(0, 6),
    [stats.quotes],
  );

  return (
    <>
      <div className="grid grid-cols-2 gap-3 md:grid-cols-3 lg:grid-cols-6">
        <Kpi label="Jogadores" value={t.players} hint={`${t.players_today} hoje`} />
        <Kpi label="Respostas" value={t.answers} hint={`${t.answers_today} hoje`} />
        <Kpi label="Acerto geral" value={pct(t.hits, t.answers)} className={tone(rate(t.hits, t.answers)).text} hint={`${t.hits} acertos · ${t.answers - t.hits} erros`} />
        <Kpi label="Tempo médio" value={t.avg_secs != null ? `${t.avg_secs.toLocaleString("pt-BR")}s` : "—"} hint="para responder" />
        <Kpi label="Partidas" value={t.games} hint={`${pct(t.finished, t.games)} terminadas`} />
        <Kpi label="Tempo esgotado" value={t.timeouts} hint={`${pct(t.timeouts, t.answers)} das respostas`} />
      </div>

      <div className="flex flex-col gap-3">
        <RateLegend />
        <div className="grid gap-4 lg:grid-cols-2">
          <Card title="Acerto por dia" hint="Quantos % das respostas de cada dia estavam certas">
            <Bars
              rows={stats.by_day
                .slice(-14)
                .map((d) => ({ label: fmtDay(d.day), sub: `${d.players} jogador${d.players === 1 ? "" : "es"}`, answers: d.answers, hits: d.hits }))}
            />
          </Card>
          <Card title="Acerto por categoria" hint="Da mais jogada para a menos jogada">
            <Bars rows={stats.by_category.map((c) => ({ label: categoryLabel(c.category), answers: c.answers, hits: c.hits }))} />
          </Card>
          <Card title="Acerto por tipo de frase">
            <Bars rows={stats.by_kind.map((k) => ({ label: KIND_LABELS[k.kind] ?? k.kind, answers: k.answers, hits: k.hits }))} />
          </Card>
          <Card title="Acerto por modo de jogo">
            <Bars rows={stats.by_mode.map((m) => ({ label: MODE_LABELS[m.mode] ?? m.mode, answers: m.answers, hits: m.hits }))} />
          </Card>
        </div>
      </div>

      <PeopleStats people={stats.people} />

      <Card title="Confusões mais comuns" hint="A frase era de uma pessoa, mas a galera chutou outra">
        <Confusions items={stats.confusions} />
      </Card>

      <div className="grid gap-4 lg:grid-cols-2">
        <Card title="Frases mais difíceis" hint="Menos da metade acertou · só frases com 3 ou mais respostas">
          <QuoteList quotes={hardest} />
        </Card>
        <Card title="Frases mais fáceis" hint="Metade ou mais acertou · só frases com 3 ou mais respostas">
          <QuoteList quotes={easiest} />
        </Card>
      </div>

    </>
  );
}

function PeopleStats({ people }: { people: Stats["people"] }) {
  const [sort, setSort] = useState<PersonSort>("answers");
  const [query, setQuery] = useState("");
  const [showAll, setShowAll] = useState(false);

  const rows = useMemo(() => {
    const q = fold(query.trim());
    const list = people.filter((p) => !q || fold(p.name).includes(q) || fold(categoryLabel(p.category)).includes(q));
    const by: Record<PersonSort, (a: (typeof list)[number], b: (typeof list)[number]) => number> = {
      answers: (a, b) => b.answers - a.answers,
      hardest: (a, b) => rate(a.hits, a.answers) - rate(b.hits, b.answers) || b.answers - a.answers,
      easiest: (a, b) => rate(b.hits, b.answers) - rate(a.hits, a.answers) || b.answers - a.answers,
      decoy: (a, b) => b.decoy - a.decoy || b.answers - a.answers,
    };
    return list.sort(by[sort]);
  }, [people, sort, query]);

  const visible = showAll || query ? rows : rows.slice(0, 15);

  return (
    <Card title="Por famoso" hint={`${people.length} pessoa(s) com frase respondida`}>
      <div className="flex flex-wrap items-center gap-2">
        <div className="relative w-full sm:w-64">
          <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-white/30" aria-hidden />
          <input className={`${input} pl-9`} placeholder="Buscar pessoa ou categoria" value={query} onChange={(e) => setQuery(e.target.value)} />
        </div>
        <div className="flex flex-wrap gap-1">
          {PERSON_SORTS.map((s) => (
            <Chip key={s.id} active={sort === s.id} onClick={() => setSort(s.id)}>
              {s.label}
            </Chip>
          ))}
        </div>
      </div>

      <div className="-mx-4 overflow-x-auto px-4">
        <table className="w-full min-w-[720px] text-sm">
          <thead className="text-left text-xs uppercase tracking-wide text-white/40">
            <tr>
              <th className="py-2 font-semibold">Pessoa</th>
              <th className="py-2 text-right font-semibold">Frases</th>
              <th className="py-2 text-right font-semibold">Respostas</th>
              <th className="w-40 py-2 pl-4 font-semibold">Acerto</th>
              <th className="py-2 text-right font-semibold" title="Vezes que a galera chutou esta pessoa numa frase de outra">
                Chutada
              </th>
              <th className="py-2 pl-4 font-semibold">Confundem com</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/5">
            {visible.map((p) => (
              <tr key={p.id}>
                <td className="py-2">
                  <div className="flex items-center gap-2">
                    <Avatar url={p.image_url} name={p.name} className="size-8 shrink-0 rounded-full text-[8px]" />
                    <div className="min-w-0">
                      <p className="truncate font-semibold">{p.name}</p>
                      <p className="text-xs text-white/40">{categoryLabel(p.category)}</p>
                    </div>
                  </div>
                </td>
                <td className="py-2 text-right text-white/60">{p.quotes}</td>
                <td className="py-2 text-right">{p.answers}</td>
                <td className="py-2 pl-4">
                  <RateBar hits={p.hits} answers={p.answers} />
                </td>
                <td className="py-2 text-right text-white/60">{p.decoy || "—"}</td>
                <td className="py-2 pl-4 text-xs text-white/60">
                  {p.confused_with?.map((c) => `${c.name} (${c.count})`).join(", ") || "—"}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
      {!query && rows.length > 15 && (
        <button type="button" className="self-start text-sm text-amber-300 underline" onClick={() => setShowAll((v) => !v)}>
          {showAll ? "Mostrar menos" : `Ver todas as ${rows.length}`}
        </button>
      )}
    </Card>
  );
}

function Confusions({ items }: { items: Stats["confusions"] }) {
  if (!items.length) return <Empty />;
  return (
    <ul className="grid gap-2 sm:grid-cols-2 lg:grid-cols-3">
      {items.map((c) => (
        <li key={`${c.said_by}>${c.guessed}`} className="flex items-center gap-3 rounded-lg bg-white/5 p-3">
          <div className="grid min-w-0 flex-1 grid-cols-[1fr_auto_1fr] items-center gap-2">
            <Face name={c.said_by} url={c.said_by_image} caption="disse" />
            <ArrowRight className="size-4 text-white/30" aria-hidden />
            <Face name={c.guessed} url={c.guessed_image} caption="chutaram" muted />
          </div>
          <span className="flex shrink-0 flex-col items-center rounded-lg bg-rose-500/15 px-2.5 py-1 leading-tight text-rose-300">
            <span className="text-lg font-black tabular-nums">{c.count}</span>
            <span className="text-[10px] uppercase tracking-wide">{c.count === 1 ? "vez" : "vezes"}</span>
          </span>
        </li>
      ))}
    </ul>
  );
}

function Face({ name, url, caption, muted }: { name: string; url: string | null; caption: string; muted?: boolean }) {
  return (
    <div className="flex min-w-0 flex-col items-center gap-1 text-center">
      <Avatar url={url} name={name} className={`size-10 rounded-full text-[8px] ${muted ? "opacity-70 grayscale" : ""}`} />
      <span className="line-clamp-2 w-full text-xs font-semibold leading-tight" title={name}>
        {name}
      </span>
      <span className="text-[10px] uppercase tracking-wide text-white/40">{caption}</span>
    </div>
  );
}

function QuoteList({ quotes }: { quotes: Stats["quotes"] }) {
  if (!quotes.length) return <Empty />;
  return (
    <ul className="flex flex-col divide-y divide-white/5">
      {quotes.map((q) => {
        const c = tone(rate(q.hits, q.answers));
        return (
          <li key={q.id} className="flex gap-3 py-3 first:pt-0 last:pb-0">
            <span className={`flex w-14 shrink-0 flex-col items-center justify-center rounded-lg py-2 leading-tight ${c.soft}`}>
              <span className={`text-lg font-black tabular-nums ${c.text}`}>{pct(q.hits, q.answers)}</span>
              <span className="text-[10px] uppercase tracking-wide text-white/40">acerto</span>
            </span>
            <div className="flex min-w-0 flex-1 flex-col gap-1.5">
              <p className="line-clamp-2 text-sm leading-snug">“{q.text}”</p>
              <div className="flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-white/50">
                <span className="inline-flex items-center gap-1.5">
                  <Avatar url={q.person_image} name={q.person} className="size-5 rounded-full text-[5px]" />
                  <span className="font-semibold text-white/70">{q.person}</span>
                </span>
                <span className="rounded-full bg-white/10 px-2 py-0.5 text-[10px] font-semibold uppercase">{KIND_LABELS[q.kind]}</span>
                <span>
                  {q.hits} de {q.answers} acertaram
                </span>
              </div>
            </div>
          </li>
        );
      })}
    </ul>
  );
}

/** Uma linha por grupo: a barra é a taxa de acerto (cheia = 100%), ao lado quantas respostas teve. */
function Bars({ rows }: { rows: { label: string; sub?: string; answers: number; hits: number }[] }) {
  if (!rows.length) return <Empty />;
  return (
    <ul className="flex flex-col gap-3 text-sm">
      {rows.map((r) => {
        const c = tone(rate(r.hits, r.answers));
        return (
          <li key={r.label} className="grid grid-cols-[8rem_1fr_6.5rem] items-center gap-3">
            <span className="flex min-w-0 flex-col leading-tight">
              <span className="truncate">{r.label}</span>
              {r.sub && <span className="text-xs text-white/40">{r.sub}</span>}
            </span>
            <div className="h-2.5 overflow-hidden rounded-full bg-white/10" title={`${r.hits} acertos e ${r.answers - r.hits} erros`}>
              <div className={`h-full rounded-full ${c.bar}`} style={{ width: `${rate(r.hits, r.answers) * 100}%` }} />
            </div>
            <span className="flex flex-col text-right leading-tight">
              <span className={`font-semibold ${c.text}`}>{pct(r.hits, r.answers)} de acerto</span>
              <span className="text-xs text-white/40">{r.answers.toLocaleString("pt-BR")} respostas</span>
            </span>
          </li>
        );
      })}
    </ul>
  );
}

function RateLegend() {
  const items = [
    ["bg-emerald-400", "65% ou mais: fácil"],
    ["bg-amber-400", "40% a 64%: médio"],
    ["bg-rose-400", "menos de 40%: difícil"],
  ];
  return (
    <p className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-white/50">
      <span>As barras mostram a taxa de acerto da galera.</span>
      {items.map(([cls, label]) => (
        <span key={label} className="inline-flex items-center gap-1.5">
          <span className={`size-2 rounded-full ${cls}`} aria-hidden />
          {label}
        </span>
      ))}
    </p>
  );
}

function RateBar({ hits, answers }: { hits: number; answers: number }) {
  const r = rate(hits, answers);
  const c = tone(r);
  return (
    <div className="flex items-center gap-2" title={`${hits} acertos · ${answers - hits} erros`}>
      <div className="h-1.5 flex-1 overflow-hidden rounded-full bg-white/10">
        <div className={`h-full rounded-full ${c.bar}`} style={{ width: `${r * 100}%` }} />
      </div>
      <span className={`w-10 text-right text-xs font-semibold ${c.text}`}>{pct(hits, answers)}</span>
    </div>
  );
}

function Kpi({ label, value, hint, className = "" }: { label: string; value: ReactNode; hint?: string; className?: string }) {
  return (
    <div className="flex flex-col gap-1 rounded-xl bg-white/5 p-4">
      <span className="text-xs font-semibold uppercase tracking-wide text-white/50">{label}</span>
      <span className={`text-2xl font-black tabular-nums ${className}`}>{value}</span>
      {hint && <span className="text-xs text-white/40">{hint}</span>}
    </div>
  );
}

function Card({ title, hint, children }: { title: string; hint?: string; children: ReactNode }) {
  return (
    <section className="flex flex-col gap-3 rounded-xl bg-white/5 p-4">
      <header>
        <h2 className="font-bold">{title}</h2>
        {hint && <p className="text-xs text-white/40">{hint}</p>}
      </header>
      {children}
    </section>
  );
}

function Chip({ active, onClick, children }: { active: boolean; onClick: () => void; children: ReactNode }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className={`rounded-full px-3 py-1 text-xs font-semibold ${active ? "bg-amber-400 text-neutral-950" : "bg-white/10 text-white/70 hover:bg-white/15"}`}
    >
      {children}
    </button>
  );
}

const Empty = () => <p className="text-sm text-white/40">Sem dados ainda.</p>;
