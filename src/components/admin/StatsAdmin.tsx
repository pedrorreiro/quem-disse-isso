"use client";

import { useEffect, useMemo, useState, type ReactNode } from "react";
import { Search } from "lucide-react";
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

function ago(iso: string) {
  const min = Math.round((Date.now() - new Date(iso).getTime()) / 60000);
  if (min < 60) return `há ${Math.max(min, 1)} min`;
  const h = Math.round(min / 60);
  if (h < 24) return `há ${h} h`;
  return `há ${Math.round(h / 24)} d`;
}

/** Cor pela taxa de acerto: vermelho é difícil, verde é fácil. */
function tone(r: number) {
  if (r < 0.4) return { text: "text-rose-300", bar: "bg-rose-400" };
  if (r < 0.65) return { text: "text-amber-300", bar: "bg-amber-400" };
  return { text: "text-emerald-300", bar: "bg-emerald-400" };
}

/** Estatísticas de acertos e erros: por famoso, por jogador, por categoria e por dia. */
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
    () => [...stats.quotes].sort((a, b) => rate(a.hits, a.answers) - rate(b.hits, b.answers) || b.answers - a.answers).slice(0, 8),
    [stats.quotes],
  );
  const easiest = useMemo(
    () => [...stats.quotes].sort((a, b) => rate(b.hits, b.answers) - rate(a.hits, a.answers) || b.answers - a.answers).slice(0, 8),
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

      <div className="grid gap-4 lg:grid-cols-2">
        <Card title="Por dia">
          <Bars
            rows={stats.by_day.slice(-14).map((d) => ({ label: fmtDay(d.day), sub: `${d.players} jog.`, answers: d.answers, hits: d.hits }))}
          />
        </Card>
        <Card title="Por categoria">
          <Bars rows={stats.by_category.map((c) => ({ label: categoryLabel(c.category), answers: c.answers, hits: c.hits }))} />
        </Card>
        <Card title="Por tipo de frase">
          <Bars rows={stats.by_kind.map((k) => ({ label: KIND_LABELS[k.kind] ?? k.kind, answers: k.answers, hits: k.hits }))} />
        </Card>
        <Card title="Por modo de jogo">
          <Bars rows={stats.by_mode.map((m) => ({ label: MODE_LABELS[m.mode] ?? m.mode, answers: m.answers, hits: m.hits }))} />
        </Card>
      </div>

      <PeopleStats people={stats.people} />

      <div className="grid gap-4 lg:grid-cols-3">
        <Card title="Confusões mais comuns" hint="A frase era de… mas chutaram…">
          {stats.confusions.length === 0 ? (
            <Empty />
          ) : (
            <ol className="flex flex-col gap-2 text-sm">
              {stats.confusions.map((c, i) => (
                <li key={i} className="flex items-baseline justify-between gap-3">
                  <span>
                    <strong>{c.said_by}</strong> <span className="text-white/40">→</span> {c.guessed}
                  </span>
                  <span className="shrink-0 text-xs text-white/50">{c.count}×</span>
                </li>
              ))}
            </ol>
          )}
        </Card>
        <Card title="Frases mais difíceis" hint="Com 3 ou mais respostas">
          <QuoteList quotes={hardest} />
        </Card>
        <Card title="Frases mais fáceis" hint="Com 3 ou mais respostas">
          <QuoteList quotes={easiest} />
        </Card>
      </div>

      <PlayersStats players={stats.players} />
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

function PlayersStats({ players }: { players: Stats["players"] }) {
  return (
    <Card title="Por jogador" hint="Os jogadores são anônimos: o código é o começo do id da sessão">
      <div className="-mx-4 overflow-x-auto px-4">
        <table className="w-full min-w-[760px] text-sm">
          <thead className="text-left text-xs uppercase tracking-wide text-white/40">
            <tr>
              <th className="py-2 font-semibold">Jogador</th>
              <th className="py-2 text-right font-semibold">Partidas</th>
              <th className="py-2 text-right font-semibold">Respostas</th>
              <th className="w-40 py-2 pl-4 font-semibold">Acerto</th>
              <th className="py-2 text-right font-semibold">Tempo médio</th>
              <th className="py-2 text-right font-semibold">Recorde</th>
              <th className="py-2 text-right font-semibold">Sequência</th>
              <th className="py-2 pl-4 font-semibold">Mais joga</th>
              <th className="py-2 text-right font-semibold">Última vez</th>
            </tr>
          </thead>
          <tbody className="divide-y divide-white/5">
            {players.map((p) => (
              <tr key={p.id}>
                <td className="py-2">
                  <span className="font-mono text-xs">#{p.id.slice(0, 6)}</span>{" "}
                  {p.is_admin ? (
                    <Tag className="bg-amber-400/15 text-amber-300">admin</Tag>
                  ) : (
                    !p.is_anonymous && <Tag className="bg-sky-400/15 text-sky-300">conta</Tag>
                  )}
                </td>
                <td className="py-2 text-right text-white/60">{p.games}</td>
                <td className="py-2 text-right">{p.answers}</td>
                <td className="py-2 pl-4">
                  <RateBar hits={p.hits} answers={p.answers} />
                </td>
                <td className="py-2 text-right text-white/60">{p.avg_secs != null ? `${p.avg_secs.toLocaleString("pt-BR")}s` : "—"}</td>
                <td className="py-2 text-right">{p.best_score?.toLocaleString("pt-BR") ?? "—"}</td>
                <td className="py-2 text-right text-white/60">{p.best_streak ?? "—"}</td>
                <td className="py-2 pl-4 text-white/60">{p.favorite_category ? categoryLabel(p.favorite_category) : "—"}</td>
                <td className="py-2 text-right text-xs text-white/50" title={new Date(p.last_seen).toLocaleString("pt-BR")}>
                  {ago(p.last_seen)}
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </Card>
  );
}

function QuoteList({ quotes }: { quotes: Stats["quotes"] }) {
  if (!quotes.length) return <Empty />;
  return (
    <ol className="flex flex-col gap-3 text-sm">
      {quotes.map((q) => (
        <li key={q.id} className="flex flex-col gap-1">
          <p className="line-clamp-2">“{q.text}”</p>
          <div className="flex items-center justify-between gap-2 text-xs text-white/50">
            <span>
              {q.person} · {KIND_LABELS[q.kind]}
            </span>
            <span className={tone(rate(q.hits, q.answers)).text}>
              {pct(q.hits, q.answers)} de {q.answers}
            </span>
          </div>
        </li>
      ))}
    </ol>
  );
}

function Bars({ rows }: { rows: { label: string; sub?: string; answers: number; hits: number }[] }) {
  if (!rows.length) return <Empty />;
  const max = Math.max(...rows.map((r) => r.answers));
  return (
    <ul className="flex flex-col gap-2 text-sm">
      {rows.map((r) => {
        const c = tone(rate(r.hits, r.answers));
        return (
          <li key={r.label} className="grid grid-cols-[7.5rem_1fr_auto] items-center gap-3">
            <span className="truncate">
              {r.label} {r.sub && <span className="text-xs text-white/40">{r.sub}</span>}
            </span>
            {/* barra cheia = respostas; parte colorida = acertos */}
            <div className="h-2.5 overflow-hidden rounded-full bg-white/5" title={`${r.hits} acertos de ${r.answers}`}>
              <div className="h-full rounded-full bg-white/15" style={{ width: `${(r.answers / max) * 100}%` }}>
                <div className={`h-full rounded-full ${c.bar}`} style={{ width: `${rate(r.hits, r.answers) * 100}%` }} />
              </div>
            </div>
            <span className="w-24 text-right text-xs text-white/50">
              <span className={`font-semibold ${c.text}`}>{pct(r.hits, r.answers)}</span> de {r.answers}
            </span>
          </li>
        );
      })}
    </ul>
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

function Tag({ className, children }: { className: string; children: ReactNode }) {
  return <span className={`rounded-full px-2 py-0.5 text-[10px] font-semibold uppercase ${className}`}>{children}</span>;
}

const Empty = () => <p className="text-sm text-white/40">Sem dados ainda.</p>;
