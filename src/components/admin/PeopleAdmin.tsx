"use client";

import { useCallback, useEffect, useState } from "react";
import { adminPeople, reviewPhoto, upsertPerson, type Person } from "@/lib/admin";
import { friendlyError } from "@/lib/api";
import { categoryLabel } from "@/lib/share";
import { findPhoto } from "@/lib/wikimedia";
import PersonEditor from "./PersonEditor";
import { Avatar, ExternalLink, PhotoBadge, btnDanger, btnGhost, btnOk, btnPrimary } from "./ui";

type Mode = { kind: "review" } | { kind: "list" } | { kind: "edit"; person?: Person };

/** Aba "Fotos" (fila de aprovação) e aba "Pessoas" (lista + cadastro) compartilham este componente. */
export default function PeopleAdmin({ view, onChanged }: { view: "photos" | "people"; onChanged: () => void }) {
  const [people, setPeople] = useState<Person[] | null>(null);
  const [mode, setMode] = useState<Mode>({ kind: view === "photos" ? "review" : "list" });
  const [error, setError] = useState("");

  const load = useCallback(async () => {
    try {
      setPeople(await adminPeople());
    } catch (e) {
      setError(friendlyError(e));
    }
  }, []);

  useEffect(() => {
    adminPeople()
      .then(setPeople)
      .catch((e) => setError(friendlyError(e)));
  }, []);

  if (error) return <p className="text-rose-300">{error}</p>;
  if (!people) return <p className="animate-pulse text-white/50">Carregando…</p>;

  const categories = [...new Set(people.map((p) => p.category))].sort();
  const back = { kind: view === "photos" ? "review" : "list" } as const;
  const saved = async () => {
    await load();
    onChanged();
    setMode(back);
  };

  if (mode.kind === "edit") {
    return <PersonEditor person={mode.person} categories={categories} onSaved={() => void saved()} onCancel={() => setMode(back)} />;
  }

  if (mode.kind === "review") {
    const pending = people.filter((p) => p.photo_status === "pending" && p.image_url);
    const noPhoto = people.filter((p) => !p.image_url || p.photo_status === "rejected");
    const current = pending[0];

    async function decide(action: "approve" | "reject") {
      try {
        await reviewPhoto(current.id, action);
        await load();
        onChanged();
      } catch (e) {
        setError(friendlyError(e));
      }
    }

    return (
      <div className="flex flex-col gap-6">
        {current ? (
          <article className="grid gap-6 rounded-2xl bg-white/[0.03] p-4 ring-1 ring-white/10 md:grid-cols-[minmax(0,420px)_1fr] md:p-6">
            <Avatar url={current.image_url} name={current.name} className="aspect-square w-full rounded-xl" />
            <div className="flex flex-col gap-4">
              <p className="text-sm text-white/50">{pending.length} foto(s) esperando aprovação</p>
              <div>
                <h2 className="text-2xl font-bold">{current.name}</h2>
                <p className="text-white/50">{categoryLabel(current.category)}</p>
              </div>
              <dl className="grid grid-cols-[auto_1fr] gap-x-4 gap-y-1 text-sm">
                <dt className="text-white/50">Autor</dt>
                <dd>{current.image_credit ?? "—"}</dd>
                <dt className="text-white/50">Licença</dt>
                <dd>{current.image_license ?? "—"}</dd>
                <dt className="text-white/50">Origem</dt>
                <dd>
                  <ExternalLink href={current.image_source_url}>abrir</ExternalLink>
                  {!current.image_source_url && "—"}
                </dd>
                {current.wikidata_id && (
                  <>
                    <dt className="text-white/50">Wikidata</dt>
                    <dd>
                      <ExternalLink href={`https://www.wikidata.org/wiki/${current.wikidata_id}`}>{current.wikidata_id}</ExternalLink>
                    </dd>
                  </>
                )}
              </dl>
              <p className="text-sm text-white/50">
                Confira: é a pessoa certa? A foto é reconhecível? A licença permite uso (CC BY, CC BY-SA, domínio público)?
              </p>
              <div className="mt-auto flex flex-wrap gap-2">
                <button type="button" className={btnDanger} onClick={() => void decide("reject")}>
                  Rejeitar
                </button>
                <button type="button" className={btnGhost} onClick={() => setMode({ kind: "edit", person: current })}>
                  Trocar foto
                </button>
                <button type="button" className={btnOk} onClick={() => void decide("approve")}>
                  Aprovar foto
                </button>
              </div>
            </div>
          </article>
        ) : (
          <div className="rounded-2xl bg-white/5 p-10 text-center">
            <p className="text-lg font-semibold">Nenhuma foto esperando aprovação.</p>
          </div>
        )}

        {noPhoto.some((p) => !p.image_url) && (
          <BulkPhotos people={noPhoto.filter((p) => !p.image_url)} onDone={() => void load().then(onChanged)} />
        )}

        {noPhoto.length > 0 && (
          <section>
            <h3 className="mb-3 text-sm uppercase tracking-widest text-white/50">Sem foto ou com foto rejeitada</h3>
            <PeopleGrid people={noPhoto} onEdit={(p) => setMode({ kind: "edit", person: p })} action="Buscar foto" />
          </section>
        )}
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center justify-between">
        <p className="text-sm text-white/50">{people.length} pessoa(s)</p>
        <button type="button" className={btnPrimary} onClick={() => setMode({ kind: "edit" })}>
          + Nova pessoa
        </button>
      </div>
      <PeopleGrid people={people} onEdit={(p) => setMode({ kind: "edit", person: p })} action="Editar" />
    </div>
  );
}

/** Busca no Wikidata/Commons a foto de cada pessoa sem foto. Nada é aprovado aqui: tudo cai na fila acima. */
function BulkPhotos({ people, onDone }: { people: Person[]; onDone: () => void }) {
  const [running, setRunning] = useState(false);
  const [progress, setProgress] = useState("");
  const [misses, setMisses] = useState<string[]>([]);

  async function run() {
    setRunning(true);
    setMisses([]);
    const missed: string[] = [];
    for (const [i, p] of people.entries()) {
      setProgress(`${i + 1}/${people.length} · ${p.name}`);
      try {
        const photo = await findPhoto(p.name, p.wikidata_id);
        if (!photo) {
          missed.push(`${p.name}: nenhuma foto no Wikidata`);
          continue;
        }
        await upsertPerson({ id: p.id, ...photo, image_type: "foto" });
      } catch (e) {
        missed.push(`${p.name}: ${friendlyError(e)}`);
      }
    }
    setMisses(missed);
    setProgress(`Pronto: ${people.length - missed.length} foto(s) encontradas, esperando sua aprovação.`);
    setRunning(false);
    onDone();
  }

  return (
    <section className="flex flex-col gap-3 rounded-2xl bg-white/5 p-4">
      <div className="flex flex-wrap items-center justify-between gap-3">
        <p className="text-sm text-white/70">
          {people.length} pessoa(s) sem foto. A busca usa o Wikidata e o Commons, com autor e licença. Você ainda aprova uma por uma.
        </p>
        <button type="button" className={btnPrimary} disabled={running} onClick={() => void run()}>
          {running ? "Buscando…" : "Buscar fotos de todos"}
        </button>
      </div>
      {progress && <p className="text-sm text-white/50">{progress}</p>}
      {misses.length > 0 && (
        <ul className="list-disc pl-5 text-sm text-amber-200/80">
          {misses.map((m) => (
            <li key={m}>{m}</li>
          ))}
        </ul>
      )}
    </section>
  );
}

function PeopleGrid({ people, onEdit, action }: { people: Person[]; onEdit: (p: Person) => void; action: string }) {
  return (
    <ul className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
      {people.map((p) => (
        <li key={p.id} className="flex items-center gap-3 rounded-xl bg-white/5 p-3">
          <Avatar url={p.image_url} name={p.name} className="size-14 shrink-0 rounded-lg text-[10px]" />
          <div className="min-w-0 flex-1">
            <p className="truncate font-semibold">{p.name}</p>
            <div className="mt-1 flex flex-wrap items-center gap-2 text-xs text-white/50">
              {categoryLabel(p.category)}
              <PhotoBadge status={p.photo_status} hasImage={!!p.image_url} />
            </div>
          </div>
          <button type="button" className={btnGhost} onClick={() => onEdit(p)}>
            {action}
          </button>
        </li>
      ))}
    </ul>
  );
}
