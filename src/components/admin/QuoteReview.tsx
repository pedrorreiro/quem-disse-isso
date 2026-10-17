"use client";

import { useEffect, useState } from "react";
import { ArrowLeft, ArrowRight } from "lucide-react";
import {
  adminPeople,
  adminQuoteQueue,
  reviewQuote,
  youtubeEmbed,
  type DraftQuote,
  type Person,
  type QuoteFields,
  type ReviewAction,
} from "@/lib/admin";
import { friendlyError } from "@/lib/api";
import { categoryLabel } from "@/lib/share";
import QuoteFieldsForm from "./QuoteFieldsForm";
import { Avatar, Field, PhotoBadge, btnDanger, btnGhost, btnOk, input } from "./ui";

const EDITABLE: (keyof QuoteFields)[] = [
  "person_id", "text", "said_on", "context", "vibe", "source_type", "source_url", "source_timestamp", "archive_url", "difficulty", "kind",
];

function pickFields(q: DraftQuote): QuoteFields {
  return Object.fromEntries(EDITABLE.map((k) => [k, q[k] ?? null])) as QuoteFields;
}

export default function QuoteReview({ onChanged }: { onChanged: () => void }) {
  const [queue, setQueue] = useState<DraftQuote[] | null>(null);
  const [people, setPeople] = useState<Person[]>([]);
  const [index, setIndex] = useState(0);
  const [error, setError] = useState("");

  useEffect(() => {
    Promise.all([adminQuoteQueue(), adminPeople()])
      .then(([q, p]) => {
        setQueue(q);
        setPeople(p);
      })
      .catch((e) => setError(friendlyError(e)));
  }, []);

  if (error) return <p className="text-rose-300">{error}</p>;
  if (!queue) return <p className="animate-pulse text-white/50">Carregando fila…</p>;
  if (queue.length === 0) {
    return (
      <div className="rounded-2xl bg-white/5 p-10 text-center">
        <p className="text-lg font-semibold">Nenhuma frase esperando revisão.</p>
        <p className="mt-1 text-white/50">Cadastre novas em “Nova frase” ou importe candidatas por SQL (entram como rascunho).</p>
      </div>
    );
  }

  const i = Math.min(index, queue.length - 1);
  const current = queue[i];

  async function act(action: ReviewAction, fields: QuoteFields, note: string) {
    await reviewQuote(current.id, action, fields, note || undefined);
    if (action === "save") {
      setQueue((q) => q!.map((x) => (x.id === current.id ? { ...x, ...fields, review_note: note || x.review_note } : x)));
    } else {
      setQueue((q) => q!.filter((x) => x.id !== current.id));
    }
    onChanged();
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between text-sm text-white/60">
        <span>
          Frase <strong className="text-white">{i + 1}</strong> de {queue.length} na fila
        </span>
        <div className="flex gap-2">
          <button type="button" className={btnGhost} disabled={i === 0} onClick={() => setIndex(i - 1)}>
            <ArrowLeft className="mr-1 inline size-4" aria-hidden />
            Anterior
          </button>
          <button type="button" className={btnGhost} disabled={i === queue.length - 1} onClick={() => setIndex(i + 1)}>
            Pular
            <ArrowRight className="ml-1 inline size-4" aria-hidden />
          </button>
        </div>
      </div>
      <QuoteEditor key={current.id} quote={current} people={people} onAct={act} />
    </div>
  );
}

export function QuoteEditor({
  quote,
  people,
  onAct,
}: {
  quote: DraftQuote;
  people: Person[];
  onAct: (action: ReviewAction, fields: QuoteFields, note: string) => Promise<void>;
}) {
  const [fields, setFields] = useState<QuoteFields>(() => pickFields(quote));
  const [note, setNote] = useState(quote.review_note ?? "");
  const [busy, setBusy] = useState<ReviewAction | null>(null);
  const [error, setError] = useState("");

  const person = people.find((p) => p.id === fields.person_id) ?? (quote.person as Person);
  const embed = fields.source_url ? youtubeEmbed(fields.source_url, fields.source_timestamp) : null;
  const dirty = JSON.stringify(fields) !== JSON.stringify(pickFields(quote)) || note !== (quote.review_note ?? "");
  const missing = !fields.text?.trim() || !/^https?:\/\//.test(fields.source_url ?? "");

  async function run(action: ReviewAction) {
    setBusy(action);
    setError("");
    try {
      await onAct(action, fields, note);
    } catch (e) {
      setError(friendlyError(e));
    }
    setBusy(null);
  }

  return (
    <article className="grid gap-6 rounded-2xl bg-white/[0.03] p-4 ring-1 ring-white/10 md:grid-cols-[260px_1fr] md:p-6">
      <aside className="flex flex-col gap-3">
        <Avatar url={person.image_url} name={person.name} className="aspect-square w-full rounded-xl" />
        <div>
          <p className="text-lg font-bold leading-tight">{person.name}</p>
          <p className="text-sm text-white/50">{categoryLabel(person.category)}</p>
        </div>
        <div className="flex flex-wrap gap-2">
          <PhotoBadge status={person.photo_status} hasImage={!!person.image_url} />
          {quote.is_demo && (
            <span className="rounded-full bg-fuchsia-500/15 px-2 py-0.5 text-xs font-semibold text-fuchsia-300">DEMO</span>
          )}
        </div>
        {person.photo_status !== "approved" && (
          <p className="rounded-lg bg-amber-400/10 p-3 text-xs text-amber-200">
            A foto desta pessoa ainda não foi aprovada. A frase só aparece no jogo depois disso (aba Fotos).
          </p>
        )}
      </aside>

      <div className="flex flex-col gap-5">
        <QuoteFieldsForm value={fields} onChange={setFields} people={people} />

        {embed && (
          <div className="overflow-hidden rounded-xl ring-1 ring-white/10">
            <iframe
              src={embed}
              title="Fonte em vídeo"
              className="aspect-video w-full"
              allow="encrypted-media; picture-in-picture"
              allowFullScreen
            />
          </div>
        )}

        <Field label="Anotação da revisão (opcional)">
          <input
            className={input}
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder={quote.status === "verified" ? "ex.: por que saiu do jogo" : "ex.: fonte não confirma a frase"}
          />
        </Field>

        {error && <p className="text-sm text-rose-300">{error}</p>}

        <div className="flex flex-wrap items-center justify-end gap-2 border-t border-white/10 pt-4">
          {quote.status === "verified" ? (
            <button type="button" className={btnDanger} disabled={!!busy} onClick={() => run("reject")}>
              {busy === "reject" ? "Tirando…" : "Tirar do jogo"}
            </button>
          ) : quote.status === "rejected" ? (
            <button type="button" className={btnGhost} disabled={!!busy} onClick={() => run("reopen")}>
              {busy === "reopen" ? "Voltando…" : "Voltar para rascunho"}
            </button>
          ) : (
            <button type="button" className={btnDanger} disabled={!!busy} onClick={() => run("reject")}>
              {busy === "reject" ? "Rejeitando…" : "Rejeitar"}
            </button>
          )}
          <button type="button" className={btnGhost} disabled={!!busy || !dirty || missing} onClick={() => run("save")}>
            {busy === "save" ? "Salvando…" : quote.status === "draft" ? "Salvar rascunho" : "Salvar alterações"}
          </button>
          {quote.status !== "verified" && (
            <button
              type="button"
              className={btnOk}
              disabled={!!busy || missing}
              title={missing ? "Preencha a frase e uma URL de fonte" : undefined}
              onClick={() => run("approve")}
            >
              {busy === "approve" ? "Aprovando…" : dirty ? "Salvar e aprovar" : "Aprovar"}
            </button>
          )}
        </div>
      </div>
    </article>
  );
}
