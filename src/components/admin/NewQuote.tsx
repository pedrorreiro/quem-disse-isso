"use client";

import { useEffect, useState } from "react";
import { adminPeople, createQuote, type Person, type QuoteFields } from "@/lib/admin";
import { friendlyError } from "@/lib/api";
import QuoteFieldsForm from "./QuoteFieldsForm";
import { btnPrimary } from "./ui";

const EMPTY: QuoteFields = { person_id: "", text: "", source_url: "", difficulty: 2 };

export default function NewQuote({ onChanged }: { onChanged: () => void }) {
  const [people, setPeople] = useState<Person[]>([]);
  const [fields, setFields] = useState<QuoteFields>(EMPTY);
  const [status, setStatus] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    adminPeople()
      .then(setPeople)
      .catch((e) => setStatus(friendlyError(e)));
  }, []);

  const valid = !!fields.person_id && !!fields.text?.trim() && /^https?:\/\//.test(fields.source_url ?? "");

  async function submit() {
    setBusy(true);
    setStatus("");
    try {
      await createQuote(fields);
      setFields(EMPTY);
      setStatus("Frase enviada para a fila de revisão.");
      onChanged();
    } catch (e) {
      setStatus(friendlyError(e));
    }
    setBusy(false);
  }

  return (
    <section className="flex flex-col gap-5 rounded-2xl bg-white/[0.03] p-4 ring-1 ring-white/10 md:p-6">
      <div>
        <h2 className="text-lg font-bold">Nova frase</h2>
        <p className="text-sm text-white/50">Entra como rascunho e aparece na fila de revisão para você aprovar.</p>
      </div>
      <QuoteFieldsForm value={fields} onChange={setFields} people={people} />
      <div className="flex items-center justify-end gap-3 border-t border-white/10 pt-4">
        {status && <p className="text-sm text-white/70">{status}</p>}
        <button type="button" className={btnPrimary} disabled={!valid || busy} onClick={() => void submit()}>
          {busy ? "Enviando…" : "Enviar para revisão"}
        </button>
      </div>
    </section>
  );
}
