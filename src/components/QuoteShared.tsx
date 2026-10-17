"use client";

import Link from "next/link";
import { motion } from "motion/react";
import { CalendarDays, ExternalLink, Play, Quote } from "lucide-react";
import ShareButton from "./ShareButton";
import { quoteDetail } from "@/lib/share";
import type { QuotePublic } from "@/lib/preview";

const btnGhost = "btn-pop bg-white/10 font-bold md:backdrop-blur";

/** Link de frase compartilhada: a frase já revelada, com quem disse, fonte e chamada para jogar. */
export default function QuoteShared({ quote }: { quote: QuotePublic | null }) {
  if (!quote) {
    return (
      <div className="m-auto flex max-w-xs flex-col gap-4 text-center">
        <p className="text-white/80">Essa frase não existe mais (ou o link veio cortado).</p>
        <Link href="/jogar" className="btn-pop bg-lime text-ink">
          Jogar uma partida
        </Link>
      </div>
    );
  }

  const { person } = quote;
  const detail = quoteDetail(quote.context, quote.said_on);

  return (
    <div className="flex flex-1 flex-col justify-center gap-8 py-10">
      <motion.figure
        initial={{ opacity: 0, y: 24 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ type: "spring", stiffness: 260, damping: 22 }}
        className="relative rounded-[2rem] bg-white/[0.07] px-6 pb-6 pt-10 ring-1 ring-white/10 md:backdrop-blur md:px-10 md:pb-8 md:pt-12"
      >
        <span
          className="absolute -top-6 left-5 grid size-12 -rotate-8 place-items-center rounded-2xl bg-pink text-white shadow-[0_4px_0_0_rgb(0_0_0/0.5)]"
          aria-hidden
        >
          <Quote className="size-6 fill-current" />
        </span>
        <blockquote className="font-display text-2xl font-black leading-snug md:text-4xl">{quote.text}</blockquote>

        <figcaption className="mt-6 flex items-center gap-4">
          {person.image_url && (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={person.image_url} alt="" className="size-16 shrink-0 rounded-2xl object-cover ring-4 ring-lime md:size-20" />
          )}
          <div className="min-w-0">
            <p className="text-xs font-bold uppercase tracking-widest text-white/50">Quem disse</p>
            <p className="font-display text-2xl font-black leading-tight text-lime md:text-3xl">{person.name}</p>
            {detail && <p className="text-sm text-white/60">{detail}</p>}
          </div>
        </figcaption>
      </motion.figure>

      <motion.div
        initial={{ opacity: 0, y: 30 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ type: "spring", stiffness: 260, damping: 22, delay: 0.25 }}
        className="flex flex-col gap-3 md:mx-auto md:w-full md:max-w-md"
      >
        <Link href="/jogar" className="btn-pop flex items-center justify-center gap-2 bg-lime py-5 font-display text-2xl font-black text-ink">
          <Play className="size-6 fill-current" aria-hidden />
          Adivinhar outras frases
        </Link>
        <div className="grid grid-cols-2 gap-3">
          <Link
            href="/diario"
            className={`${btnGhost} ${quote.source_url ? "" : "col-span-2"} inline-flex items-center justify-center gap-2 whitespace-nowrap px-3 text-sm md:text-base`}
          >
            <CalendarDays className="size-4" aria-hidden />
            Desafio do dia
          </Link>
          {quote.source_url && (
            <a
              href={quote.source_url}
              target="_blank"
              rel="noopener noreferrer"
              className={`${btnGhost} inline-flex items-center justify-center gap-2 whitespace-nowrap px-3 text-sm md:text-base`}
            >
              <ExternalLink className="size-4" aria-hidden />
              Fonte{quote.source_timestamp ? ` ${quote.source_timestamp}` : ""}
            </a>
          )}
        </div>
        <ShareButton
          label="Compartilhar"
          className={btnGhost}
          image={{ url: `/api/card/frase/${quote.id}`, name: "quem-disse-isso.png" }}
          getData={() => ({
            title: "Quem Disse Isso?",
            text: "Você acertaria as outras?",
            url: `${window.location.origin}/q/${quote.id}`,
          })}
        />
        {quote.archive_url && (
          <p className="text-center text-[11px] text-white/35">
            <a href={quote.archive_url} target="_blank" rel="noopener noreferrer" className="underline">
              cópia arquivada
            </a>
          </p>
        )}
      </motion.div>
    </div>
  );
}
