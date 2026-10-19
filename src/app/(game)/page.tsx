import type { Metadata } from "next";
import Link from "next/link";
import Hero from "@/components/Hero";
import JsonLd from "@/components/JsonLd";
import { CATEGORY_LABELS } from "@/lib/share";
import { ogDefault, siteUrl } from "@/lib/site";

export const metadata: Metadata = {
  alternates: { canonical: "/" },
  openGraph: { ...ogDefault, url: "/", title: "Quem Disse Isso?", description: "Aparece a frase. Você adivinha quem disse. Dá pra acertar todas?" },
};

const FAQ = [
  {
    q: "Como funciona o Quem Disse Isso?",
    a: "Aparece uma frase real e as fotos de alguns famosos. Você tem poucos segundos para escolher quem disse. Quanto mais rápido e mais acertos seguidos, mais pontos.",
  },
  {
    q: "As frases são verdadeiras?",
    a: "Sim. Toda frase tem fonte (vídeo, entrevista, post ou reportagem). Fora do Reality Show, o link aparece no fim de cada rodada para você conferir.",
  },
  {
    q: "Qual a diferença entre Icônicas e Polêmicas?",
    a: "Icônicas são bordões, memes e falas que marcaram época. Polêmicas são declarações que deram repercussão pública e viraram notícia.",
  },
  {
    q: "Precisa pagar ou criar conta?",
    a: "Não. O jogo é grátis, roda no navegador do celular ou do computador e não pede cadastro.",
  },
  {
    q: "O que é o Desafio do dia?",
    a: "Uma partida nova por dia, com as mesmas frases para todo mundo. Dá para comparar o placar e mandar o link para os amigos tentarem bater.",
  },
];

const jsonLd = {
  "@context": "https://schema.org",
  "@graph": [
    {
      "@type": "WebSite",
      "@id": `${siteUrl}/#site`,
      name: "Quem Disse Isso?",
      alternateName: "Quem Disse",
      url: siteUrl,
      inLanguage: "pt-BR",
    },
    {
      "@type": ["VideoGame", "WebApplication"],
      name: "Quem Disse Isso?",
      url: siteUrl,
      description: "Jogo de adivinhar quem disse a frase: famosos, políticos, jogadores, BBBs e influenciadores. Toda frase tem fonte.",
      genre: ["Quiz", "Trivia"],
      gamePlatform: "Navegador",
      applicationCategory: "GameApplication",
      operatingSystem: "Qualquer",
      inLanguage: "pt-BR",
      isAccessibleForFree: true,
      offers: { "@type": "Offer", price: 0, priceCurrency: "BRL" },
    },
    {
      "@type": "FAQPage",
      mainEntity: FAQ.map(({ q, a }) => ({ "@type": "Question", name: q, acceptedAnswer: { "@type": "Answer", text: a } })),
    },
  ],
};

export default function Home() {
  return (
    <>
      <JsonLd data={jsonLd} />
      <div className="flex min-h-dvh flex-col justify-center gap-10 py-10">
        <Hero />

        <p className="text-center text-xs text-white/40">Toda frase tem fonte. Confira no fim de cada rodada.</p>
      </div>

      {/* texto para quem rola a página (e para o Google, que não vê o jogo) */}
      <section className="flex flex-col gap-8 pb-16 text-white/70 md:mx-auto md:max-w-xl">
        <div className="flex flex-col gap-3">
          <h2 className="font-display text-2xl font-black text-white">Jogo de adivinhar quem disse a frase</h2>
          <p>
            Quem Disse Isso? é um quiz de frases de famosos. Aparece uma fala real de jogador de futebol, político, cantor, ex-BBB,
            youtuber ou celebridade, e você descobre quem disse antes que o tempo acabe. Dá para jogar frases icônicas, que viraram
            meme e bordão, ou frases polêmicas, que deram o que falar.
          </p>
        </div>

        <div className="flex flex-col gap-3">
          <h2 className="font-display text-xl font-black text-white">Categorias</h2>
          <ul className="flex flex-wrap gap-2">
            {Object.entries(CATEGORY_LABELS).map(([id, label]) => (
              <li key={id}>
                <Link href={`/jogar?cat=${id}`} className="inline-block rounded-full bg-white/10 px-3 py-1.5 text-sm text-white/80 hover:bg-white/20">
                  Frases de {label}
                </Link>
              </li>
            ))}
          </ul>
        </div>

        <div className="flex flex-col gap-3">
          <h2 className="font-display text-xl font-black text-white">Perguntas frequentes</h2>
          {FAQ.map(({ q, a }) => (
            <details key={q} className="rounded-2xl bg-white/[0.06] px-4 py-3 ring-1 ring-white/10">
              <summary className="cursor-pointer font-bold text-white/90">{q}</summary>
              <p className="mt-2 text-sm">{a}</p>
            </details>
          ))}
        </div>
      </section>
    </>
  );
}
