"use client";

import { SOURCE_TYPES, type Person, type QuoteFields } from "@/lib/admin";
import { categoryLabel } from "@/lib/share";
import { ExternalLink, Field, input } from "./ui";

type Props = {
  value: QuoteFields;
  onChange: (v: QuoteFields) => void;
  people: Person[];
  showAuthor?: boolean;
};

export default function QuoteFieldsForm({ value, onChange, people, showAuthor = true }: Props) {
  const set = <K extends keyof QuoteFields>(k: K, v: QuoteFields[K]) => onChange({ ...value, [k]: v });

  return (
    <div className="flex flex-col gap-4">
      {showAuthor && (
        <Field label="Quem disse">
          <select className={input} value={value.person_id ?? ""} onChange={(e) => set("person_id", e.target.value)}>
            <option value="" disabled>
              Escolha a pessoa
            </option>
            {people.map((p) => (
              <option key={p.id} value={p.id}>
                {p.name} — {categoryLabel(p.category)}
                {p.photo_status !== "approved" ? " (foto não aprovada)" : ""}
              </option>
            ))}
          </select>
        </Field>
      )}

      <Field label="Frase">
        <textarea
          className={`${input} min-h-24 text-base`}
          value={value.text ?? ""}
          onChange={(e) => set("text", e.target.value)}
        />
      </Field>

      <div className="grid gap-4 sm:grid-cols-[1fr_auto]">
        <Field label="Fonte (URL)">
          <input
            className={input}
            type="url"
            value={value.source_url ?? ""}
            onChange={(e) => set("source_url", e.target.value)}
            placeholder="https://…"
          />
        </Field>
        <div className="flex items-end pb-2">
          <ExternalLink href={value.source_url}>Abrir fonte</ExternalLink>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-3">
        <Field label="Tipo de fonte">
          <select
            className={input}
            value={value.source_type ?? ""}
            onChange={(e) => set("source_type", e.target.value || null)}
          >
            <option value="">—</option>
            {SOURCE_TYPES.map((t) => (
              <option key={t} value={t}>
                {t}
              </option>
            ))}
          </select>
        </Field>
        <Field label="Minuto (vídeo)" hint="ex.: 12:34">
          <input
            className={input}
            value={value.source_timestamp ?? ""}
            onChange={(e) => set("source_timestamp", e.target.value || null)}
          />
        </Field>
        <Field label="Data em que foi dita">
          <input
            className={input}
            type="date"
            value={value.said_on ?? ""}
            onChange={(e) => set("said_on", e.target.value || null)}
          />
        </Field>
      </div>

      <div className="grid gap-4 sm:grid-cols-[1fr_auto]">
        <Field label="Snapshot arquivado (Wayback Machine)">
          <input
            className={input}
            type="url"
            value={value.archive_url ?? ""}
            onChange={(e) => set("archive_url", e.target.value || null)}
            placeholder="https://web.archive.org/…"
          />
        </Field>
        <div className="flex items-end pb-2">
          <ExternalLink href={value.archive_url}>Abrir snapshot</ExternalLink>
        </div>
      </div>

      <div className="grid gap-4 sm:grid-cols-[1fr_160px_160px]">
        <Field label="Contexto (aparece na revelação)" hint="Neutro, só o dado. Ex.: Entrevista ao Fantástico">
          <input
            className={input}
            value={value.context ?? ""}
            onChange={(e) => set("context", e.target.value || null)}
          />
        </Field>
        <Field label="Dificuldade">
          <select
            className={input}
            value={value.difficulty ?? 2}
            onChange={(e) => set("difficulty", Number(e.target.value))}
          >
            <option value={1}>1 — fácil</option>
            <option value={2}>2 — médio</option>
            <option value={3}>3 — difícil</option>
          </select>
        </Field>
        <Field label="Vibe (interna)">
          <input className={input} value={value.vibe ?? ""} onChange={(e) => set("vibe", e.target.value || null)} />
        </Field>
      </div>
    </div>
  );
}
