"use client";

import { useEffect, useState } from "react";
import Link from "next/link";
import { ArrowLeft } from "lucide-react";
import { rpc } from "@/lib/api";

type Credit = {
  name: string;
  image_url: string;
  image_credit: string | null;
  image_license: string | null;
  image_source_url: string | null;
};

export default function Credits() {
  const [credits, setCredits] = useState<Credit[] | null>(null);

  useEffect(() => {
    rpc<Credit[]>("photo_credits")
      .then(setCredits)
      .catch(() => setCredits([]));
  }, []);

  return (
    <div className="flex flex-col gap-6 py-8">
      <Link href="/" className="inline-flex items-center gap-1 text-sm text-white/50">
        <ArrowLeft className="size-4" aria-hidden />
        Início
      </Link>
      <h1 className="text-3xl font-black">Créditos das fotos</h1>
      {!credits ? (
        <p className="animate-pulse text-white/50">Carregando…</p>
      ) : (
        <ul className="grid grid-cols-1 gap-3 sm:grid-cols-2">
          {credits.map((c) => (
            <li key={c.name} className="flex min-w-0 items-center gap-3 rounded-xl bg-white/5 p-3 text-sm">
              {/* eslint-disable-next-line @next/next/no-img-element */}
              <img src={c.image_url} alt="" className="size-12 shrink-0 rounded-lg object-cover" />
              <div className="min-w-0">
                <p className="font-semibold">{c.name}</p>
                <p className="text-white/50 [overflow-wrap:anywhere]">
                  {c.image_credit ?? "Autor desconhecido"} · {c.image_license ?? "—"}
                  {c.image_source_url && (
                    <>
                      {" · "}
                      <a href={c.image_source_url} target="_blank" rel="noopener noreferrer" className="underline">
                        origem
                      </a>
                    </>
                  )}
                </p>
              </div>
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
