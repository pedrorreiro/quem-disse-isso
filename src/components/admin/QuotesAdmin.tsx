"use client";

import { useEffect, useMemo, useState } from "react";
import { ChevronDown, Search, Trash2 } from "lucide-react";
import {
  adminPeople,
  adminQuotes,
  deleteQuote,
  reviewQuote,
  type AdminQuote,
  type Person,
  type QuoteFields,
  type QuoteStatus,
  type ReviewAction,
} from "@/lib/admin";
import { friendlyError } from "@/lib/api";
import KindToggle from "./KindToggle";
import { QuoteEditor } from "./QuoteReview";
import { Avatar, btnDanger, input } from "./ui";

type Filter = "playable" | QuoteStatus | "all";

const FILTERS: { id: Filter; label: string }[] = [
  { id: "playable", label: "No jogo" },
  { id: "draft", label: "Rascunho" },
  { id: "rejected", label: "Fora do jogo" },
  { id: "all", label: "Todas" },
];

type KindFilter = "all" | "iconica" | "polemica";

const KIND_FILTERS: { id: KindFilter; label: string }[] = [
  { id: "all", label: "Todos os tipos" },
  { id: "iconica", label: "Icônicas" },
  { id: "polemica", label: "Polêmicas" },
];

const NEXT_STATUS: Record<ReviewAction, QuoteStatus | null> = {
  approve: "verified",
  reject: "rejected",
  reopen: "draft",
  save: null,
};

function statusBadge(q: AdminQuote): [string, string] {
  if (q.playable) return ["No jogo", "bg-emerald-500/15 text-emerald-300"];
  if (q.status === "verified") return ["Aprovada, sem foto aprovada", "bg-amber-400/15 text-amber-300"];
  if (q.status === "draft") return ["Rascunho", "bg-white/10 text-white/60"];
  return ["Fora do jogo", "bg-rose-500/15 text-rose-300"];
}

const inStatus = (q: AdminQuote, f: Filter) => (f === "playable" ? q.playable : f === "all" || q.status === f);

/** Sem acento e em minúsculas, para a busca achar "joao" em "João". */
const fold = (s: string) => s.normalize("NFD").replace(/[̀-ͯ]/g, "").toLowerCase();

/** Todas as frases: buscar, editar, tirar do jogo ou trazer de volta. */
export default function QuotesAdmin({ onChanged }: { onChanged: () => void }) {
  const [quotes, setQuotes] = useState<AdminQuote[] | null>(null);
  const [people, setPeople] = useState<Person[]>([]);
  const [filter, setFilter] = useState<Filter>("playable");
  const [kindFilter, setKindFilter] = useState<KindFilter>("all");
  const [toggling, setToggling] = useState<string | null>(null);
  // frases com o tipo trocado agora: continuam na lista (apagadas) até mudar o filtro, para dar para desfazer
  const [kept, setKept] = useState<Set<string>>(new Set());
  const [query, setQuery] = useState("");
  const [open, setOpen] = useState<string | null>(null);
  const [error, setError] = useState("");
  const [deleting, setDeleting] = useState<string | "all" | null>(null);
  const [notice, setNotice] = useState("");

  useEffect(() => {
    Promise.all([adminQuotes(), adminPeople()])
      .then(([q, p]) => {
        setQuotes(q);
        setPeople(p);
      })
      .catch((e) => setError(friendlyError(e)));
  }, []);

  const counts = useMemo(() => {
    const c: Record<Filter, number> = { playable: 0, draft: 0, verified: 0, rejected: 0, all: 0 };
    for (const q of quotes ?? []) {
      c.all++;
      c[q.status]++;
      if (q.playable) c.playable++;
    }
    return c;
  }, [quotes]);

  // contagem por tipo dentro da situação escolhida
  const kindCounts = useMemo(() => {
    const c: Record<KindFilter, number> = { all: 0, iconica: 0, polemica: 0 };
    for (const q of quotes ?? []) {
      if (!inStatus(q, filter)) continue;
      c.all++;
      c[q.kind ?? "polemica"]++;
    }
    return c;
  }, [quotes, filter]);

  const shown = useMemo(() => {
    const words = fold(query).split(/\s+/).filter(Boolean);
    return (quotes ?? []).filter((q) => {
      if (!inStatus(q, filter)) return false;
      if (kindFilter !== "all" && (q.kind ?? "polemica") !== kindFilter && !kept.has(q.id)) return false;
      const hay = fold(`${q.text} ${q.person.name} ${q.context ?? ""}`);
      return words.every((w) => hay.includes(w));
    });
  }, [quotes, filter, kindFilter, query, kept]);

  if (error) return <p className="text-rose-300">{error}</p>;
  if (!quotes) return <p className="animate-pulse text-white/50">Carregando frases…</p>;

  async function act(q: AdminQuote, action: ReviewAction, fields: QuoteFields, note: string) {
    await reviewQuote(q.id, action, fields, note || undefined);
    const status = NEXT_STATUS[action] ?? q.status;
    setQuotes((all) =>
      all!.map((x) => {
        if (x.id !== q.id) return x;
        const person = people.find((p) => p.id === (fields.person_id ?? x.person_id)) ?? x.person;
        return {
          ...x,
          ...fields,
          person_id: person.id,
          person: { id: person.id, name: person.name, category: person.category, image_url: person.image_url, photo_status: person.photo_status },
          status,
          playable: status === "verified" && person.photo_status === "approved",
          review_note: note || x.review_note,
        } as AdminQuote;
      }),
    );
    if (action !== "save") setOpen(null);
    onChanged();
  }

  async function changeKind(q: AdminQuote, kind: "iconica" | "polemica") {
    const set = (k: AdminQuote["kind"]) => setQuotes((all) => all!.map((x) => (x.id === q.id ? { ...x, kind: k } : x)));
    setToggling(q.id);
    setKept((k) => new Set(k).add(q.id));
    set(kind);
    try {
      await reviewQuote(q.id, "save", { kind });
    } catch (e) {
      set(q.kind);
      setNotice(`Não deu para trocar o tipo: ${friendlyError(e)}`);
    }
    setToggling(null);
  }

  async function remove(list: AdminQuote[]) {
    const label = list.length === 1 ? `“${list[0].text.slice(0, 80)}”` : `as ${list.length} frases fora do jogo mostradas`;
    if (!window.confirm(`Apagar de vez ${label}? Não dá para desfazer.`)) return;
    setDeleting(list.length === 1 ? list[0].id : "all");
    setNotice("");
    const gone = new Set<string>();
    let failed = "";
    for (const q of list) {
      try {
        await deleteQuote(q.id);
        gone.add(q.id);
      } catch (e) {
        failed = friendlyError(e);
      }
    }
    setQuotes((all) => all!.filter((x) => !gone.has(x.id)));
    if (open && gone.has(open)) setOpen(null);
    setDeleting(null);
    setNotice(
      failed
        ? `${gone.size} apagada(s); ${list.length - gone.size} falharam: ${failed}`
        : `${gone.size} frase${gone.size === 1 ? " apagada" : "s apagadas"}.`,
    );
    onChanged();
  }

  const deletable = shown.filter((q) => q.status === "rejected");

  return (
    <div className="flex flex-col gap-4">
      <div className="flex flex-col gap-3 md:flex-row md:items-center">
        <label className="relative flex-1">
          <Search className="pointer-events-none absolute left-3 top-1/2 size-4 -translate-y-1/2 text-white/40" aria-hidden />
          <span className="sr-only">Buscar</span>
          <input
            className={`${input} pl-9`}
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Buscar por frase, pessoa ou contexto"
          />
        </label>
        <div className="flex gap-1 overflow-x-auto rounded-xl bg-white/5 p-1" role="group" aria-label="Filtrar por situação">
          {FILTERS.map((f) => (
            <button
              key={f.id}
              type="button"
              aria-pressed={filter === f.id}
              onClick={() => {
                setFilter(f.id);
                setKept(new Set());
              }}
              className={`whitespace-nowrap rounded-lg px-3 py-1.5 text-sm font-semibold ${
                filter === f.id ? "bg-amber-400 text-neutral-950" : "text-white/70 hover:bg-white/5"
              }`}
            >
              {f.label} <span className="opacity-60">{counts[f.id]}</span>
            </button>
          ))}
        </div>
      </div>

      <div className="flex w-fit gap-1 overflow-x-auto rounded-xl bg-white/5 p-1" role="group" aria-label="Filtrar por tipo">
        {KIND_FILTERS.map((f) => (
          <button
            key={f.id}
            type="button"
            aria-pressed={kindFilter === f.id}
            onClick={() => {
              setKindFilter(f.id);
              setKept(new Set());
            }}
            className={`whitespace-nowrap rounded-lg px-3 py-1.5 text-sm font-semibold ${
              kindFilter !== f.id
                ? "text-white/70 hover:bg-white/5"
                : f.id === "iconica"
                  ? "bg-cyan text-neutral-950"
                  : f.id === "polemica"
                    ? "bg-pink text-white"
                    : "bg-amber-400 text-neutral-950"
            }`}
          >
            {f.label} <span className="opacity-60">{kindCounts[f.id]}</span>
          </button>
        ))}
      </div>

      {filter === "rejected" && deletable.length > 0 && (
        <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl bg-rose-500/5 p-3 ring-1 ring-rose-500/20">
          <p className="text-sm text-white/60">
            Apagar remove a frase de vez, junto com as rodadas antigas em que ela apareceu. O placar das partidas já jogadas não muda.
          </p>
          <button type="button" className={`${btnDanger} inline-flex items-center gap-2`} disabled={!!deleting} onClick={() => remove(deletable)}>
            <Trash2 className="size-4" aria-hidden />
            {deleting === "all" ? "Apagando…" : `Apagar ${deletable.length === 1 ? "a frase mostrada" : `as ${deletable.length} mostradas`}`}
          </button>
        </div>
      )}
      {notice && <p className="text-sm text-white/60" role="status">{notice}</p>}

      {shown.length === 0 ? (
        <p className="rounded-2xl bg-white/5 p-8 text-center text-white/50">Nenhuma frase encontrada.</p>
      ) : (
        <ul className="flex flex-col gap-2">
          {shown.map((q) => {
            const [label, cls] = statusBadge(q);
            const isOpen = open === q.id;
            return (
              <li
                key={q.id}
                className={`flex flex-wrap overflow-hidden rounded-2xl bg-white/[0.03] ring-1 ring-white/10 transition-opacity ${
                  kindFilter !== "all" && (q.kind ?? "polemica") !== kindFilter ? "opacity-50" : ""
                }`}
              >
                <button
                  type="button"
                  aria-expanded={isOpen}
                  onClick={() => setOpen(isOpen ? null : q.id)}
                  className="flex min-w-0 flex-1 items-center gap-3 p-3 text-left hover:bg-white/[0.03] md:gap-4"
                >
                  <Avatar url={q.person.image_url} name={q.person.name} className="size-12 shrink-0 rounded-lg text-[10px]" />
                  <div className="min-w-0 flex-1">
                    <p className="line-clamp-2 text-sm font-semibold md:text-base">{q.text}</p>
                    <p className="mt-0.5 flex flex-wrap items-center gap-x-2 gap-y-1 text-xs text-white/50">
                      <span className="font-semibold text-white/70">{q.person.name}</span>
                      <span className={`rounded-full px-2 py-0.5 font-semibold ${cls}`}>{label}</span>
                      {q.plays > 0 && (
                        <span>
                          {q.plays} {q.plays === 1 ? "resposta" : "respostas"} · {Math.round((100 * q.hits) / q.plays)}% de acerto
                        </span>
                      )}
                      {q.is_demo && <span className="rounded-full bg-fuchsia-500/15 px-2 py-0.5 font-semibold text-fuchsia-300">DEMO</span>}
                    </p>
                  </div>
                  <ChevronDown className={`size-5 shrink-0 text-white/40 transition ${isOpen ? "rotate-180" : ""}`} aria-hidden />
                </button>
                <div className="flex shrink-0 items-center self-stretch border-l border-white/10 px-2 md:px-3">
                  <KindToggle
                    value={q.kind ?? "polemica"}
                    onChange={(k) => changeKind(q, k)}
                    disabled={toggling === q.id}
                    label={`Tipo da frase de ${q.person.name}`}
                  />
                </div>
                {q.status === "rejected" && (
                  <button
                    type="button"
                    onClick={() => remove([q])}
                    disabled={!!deleting}
                    aria-label={`Apagar a frase de ${q.person.name}`}
                    title="Apagar de vez"
                    className="grid w-12 shrink-0 place-items-center self-stretch border-l border-white/10 text-rose-300/70 hover:bg-rose-500/10 hover:text-rose-300 disabled:opacity-40"
                  >
                    <Trash2 className="size-4" aria-hidden />
                  </button>
                )}
                {isOpen && (
                  <div className="w-full border-t border-white/10 p-3 md:p-4">
                    <QuoteEditor
                      key={`${q.id}:${q.status}:${q.kind}`}
                      quote={q}
                      people={people}
                      onAct={(action, fields, note) => act(q, action, fields, note)}
                    />
                  </div>
                )}
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
