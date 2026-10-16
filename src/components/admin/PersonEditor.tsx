"use client";

import { useState } from "react";
import { slugify, upsertPerson, type Person } from "@/lib/admin";
import { friendlyError } from "@/lib/api";
import { getPhoto, searchPeople, type WikiHit, type WikiPhoto } from "@/lib/wikimedia";
import { Avatar, ExternalLink, Field, btnGhost, btnPrimary, input } from "./ui";

type Draft = Partial<Person>;

type Props = {
  person?: Person;
  categories: string[];
  onSaved: () => void;
  onCancel: () => void;
};

export default function PersonEditor({ person, categories, onSaved, onCancel }: Props) {
  const [p, setP] = useState<Draft>(person ?? { name: "", category: "", country: "BR", image_type: "foto" });
  const [query, setQuery] = useState(person?.name ?? "");
  const [hits, setHits] = useState<WikiHit[] | null>(null);
  const [photo, setPhoto] = useState<WikiPhoto | null>(null);
  const [status, setStatus] = useState("");
  const [busy, setBusy] = useState(false);
  const [manual, setManual] = useState(false);

  const set = <K extends keyof Draft>(k: K, v: Draft[K]) => setP((x) => ({ ...x, [k]: v }));
  const imageChanged = (p.image_url ?? null) !== (person?.image_url ?? null);

  async function search() {
    setStatus("Buscando no Wikidata…");
    setHits(null);
    setPhoto(null);
    try {
      const r = await searchPeople(query);
      setHits(r);
      setStatus(r.length ? "" : "Nada encontrado.");
    } catch (e) {
      setStatus(`Não consegui acessar o Wikidata: ${friendlyError(e)}`);
    }
  }

  async function choose(hit: WikiHit) {
    setStatus(`Buscando a foto de ${hit.label}…`);
    try {
      const ph = await getPhoto(hit.id);
      setPhoto(ph);
      if (!p.name) set("name", hit.label);
      setStatus(ph ? "" : `${hit.label} não tem foto no Wikidata. Use outro resultado ou preencha manualmente.`);
    } catch (e) {
      setStatus(`Erro ao buscar a foto: ${friendlyError(e)}`);
    }
  }

  function applyPhoto(ph: WikiPhoto) {
    setP((x) => ({ ...x, ...ph, image_type: "foto" }));
    setPhoto(null);
    setHits(null);
  }

  async function save() {
    setBusy(true);
    setStatus("");
    try {
      await upsertPerson({ ...p, slug: p.slug || slugify(p.name ?? "") });
      onSaved();
    } catch (e) {
      setStatus(friendlyError(e));
      setBusy(false);
    }
  }

  const canSave = !!p.name?.trim() && !!p.category?.trim() && !busy;

  return (
    <section className="grid gap-6 rounded-2xl bg-white/[0.03] p-4 ring-1 ring-white/10 md:grid-cols-[260px_1fr] md:p-6">
      <aside className="flex flex-col gap-3">
        <Avatar url={p.image_url ?? null} name={p.name ?? ""} className="aspect-square w-full rounded-xl" />
        {p.image_url && (
          <p className="text-xs text-white/50">
            Foto: {p.image_credit ?? "?"} · {p.image_license ?? "?"} <ExternalLink href={p.image_source_url}>origem</ExternalLink>
          </p>
        )}
        {imageChanged && p.image_url && (
          <p className="rounded-lg bg-amber-400/10 p-3 text-xs text-amber-200">
            Foto nova: depois de salvar ela vai para a fila de aprovação (aba Fotos).
          </p>
        )}
      </aside>

      <div className="flex flex-col gap-5">
        <h2 className="text-lg font-bold">{person ? `Editar ${person.name}` : "Nova pessoa"}</h2>

        <div className="grid gap-4 sm:grid-cols-[1fr_200px_100px]">
          <Field label="Nome">
            <input className={input} value={p.name ?? ""} onChange={(e) => set("name", e.target.value)} />
          </Field>
          <Field label="Categoria">
            <input
              className={input}
              list="categories"
              value={p.category ?? ""}
              onChange={(e) => set("category", slugify(e.target.value))}
            />
            <datalist id="categories">
              {categories.map((c) => (
                <option key={c} value={c} />
              ))}
            </datalist>
          </Field>
          <Field label="País">
            <input
              className={input}
              value={p.country ?? ""}
              maxLength={2}
              onChange={(e) => set("country", e.target.value.toUpperCase())}
            />
          </Field>
        </div>

        <div className="flex flex-col gap-3 rounded-xl bg-white/5 p-4">
          <p className="text-sm font-semibold">Foto pelo Wikimedia Commons</p>
          <div className="flex gap-2">
            <input
              className={input}
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              onKeyDown={(e) => e.key === "Enter" && (e.preventDefault(), void search())}
              placeholder="Nome para buscar no Wikidata"
            />
            <button type="button" className={btnGhost} disabled={!query.trim()} onClick={() => void search()}>
              Buscar
            </button>
          </div>
          {status && <p className="text-sm text-white/60">{status}</p>}
          {hits && hits.length > 0 && !photo && (
            <ul className="flex flex-col divide-y divide-white/5 rounded-lg bg-black/20">
              {hits.map((h) => (
                <li key={h.id}>
                  <button
                    type="button"
                    onClick={() => void choose(h)}
                    className="w-full px-3 py-2 text-left text-sm hover:bg-white/5"
                  >
                    <span className="font-semibold">{h.label}</span>
                    {h.description && <span className="text-white/50"> — {h.description}</span>}
                    <span className="ml-2 text-xs text-white/30">{h.id}</span>
                  </button>
                </li>
              ))}
            </ul>
          )}
          {photo && (
            <div className="flex flex-col gap-3 sm:flex-row sm:items-start">
              <Avatar url={photo.image_url} name="" className="aspect-square w-40 rounded-lg" />
              <div className="flex flex-col gap-2 text-sm">
                <p>
                  <span className="text-white/50">Autor:</span> {photo.image_credit}
                </p>
                <p>
                  <span className="text-white/50">Licença:</span> {photo.image_license}
                </p>
                <ExternalLink href={photo.image_source_url}>Ver no Commons</ExternalLink>
                <div className="flex gap-2">
                  <button type="button" className={btnPrimary} onClick={() => applyPhoto(photo)}>
                    Usar esta foto
                  </button>
                  <button type="button" className={btnGhost} onClick={() => setPhoto(null)}>
                    Voltar
                  </button>
                </div>
              </div>
            </div>
          )}
          <button type="button" className="self-start text-xs text-white/50 underline" onClick={() => setManual((m) => !m)}>
            {manual ? "Esconder campos manuais" : "Preencher foto manualmente"}
          </button>
          {manual && (
            <div className="grid gap-3 sm:grid-cols-2">
              <Field label="URL da imagem">
                <input className={input} value={p.image_url ?? ""} onChange={(e) => set("image_url", e.target.value || null)} />
              </Field>
              <Field label="Página de origem">
                <input
                  className={input}
                  value={p.image_source_url ?? ""}
                  onChange={(e) => set("image_source_url", e.target.value || null)}
                />
              </Field>
              <Field label="Autor da foto">
                <input
                  className={input}
                  value={p.image_credit ?? ""}
                  onChange={(e) => set("image_credit", e.target.value || null)}
                />
              </Field>
              <Field label="Licença">
                <input
                  className={input}
                  value={p.image_license ?? ""}
                  onChange={(e) => set("image_license", e.target.value || null)}
                  placeholder="ex.: CC BY-SA 4.0"
                />
              </Field>
            </div>
          )}
        </div>

        <div className="flex justify-end gap-2 border-t border-white/10 pt-4">
          <button type="button" className={btnGhost} onClick={onCancel}>
            Cancelar
          </button>
          <button type="button" className={btnPrimary} disabled={!canSave} onClick={() => void save()}>
            {busy ? "Salvando…" : "Salvar pessoa"}
          </button>
        </div>
      </div>
    </section>
  );
}
