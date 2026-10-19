import type { Metadata } from "next";
import JsonLd from "@/components/JsonLd";
import QuoteShared from "@/components/QuoteShared";
import { getQuotePublic, type QuotePublic } from "@/lib/preview";
import { quoteDetail } from "@/lib/share";
import { ogBase, siteUrl } from "@/lib/site";

/** Trecho da frase para o título: o Google corta por volta de 60 caracteres. */
function snippet(text: string, max = 70) {
  if (text.length <= max) return text;
  const cut = text.slice(0, max);
  return `${cut.slice(0, cut.lastIndexOf(" ") > 40 ? cut.lastIndexOf(" ") : max).replace(/[\s,.;:!?]+$/, "")}…`;
}

function describe(quote: QuotePublic) {
  const detail = quoteDetail(quote.context, quote.said_on).replace(/[.\s]+$/, "");
  return `“${quote.text}” Quem disse foi ${quote.person.name}${detail ? ` (${detail})` : ""}. Veja a fonte e teste se você adivinha outras frases.`;
}

export async function generateMetadata({ params }: PageProps<"/q/[id]">): Promise<Metadata> {
  const { id } = await params;
  const quote = await getQuotePublic(id);
  if (!quote) {
    // frase inexistente responde 200 com mensagem de erro: não deixar o Google indexar
    return { title: "Frase não encontrada", robots: { index: false, follow: false } };
  }
  // quem pesquisa costuma digitar o começo da frase: ela vem primeiro no título
  const title = `“${snippet(quote.text)}” — ${quote.person.name}`;
  const description = describe(quote);
  return {
    title,
    description,
    alternates: { canonical: `/q/${id}` },
    openGraph: { ...ogBase, type: "article", url: `/q/${id}`, title: `Quem disse isso? ${quote.person.name}`, description: `“${quote.text}”` },
  };
}

export default async function SharedQuote({ params }: PageProps<"/q/[id]">) {
  const { id } = await params;
  const quote = await getQuotePublic(id);
  return (
    <>
      {quote && (
        <JsonLd
          data={{
            "@context": "https://schema.org",
            "@type": "Quotation",
            "@id": `${siteUrl}/q/${quote.id}`,
            url: `${siteUrl}/q/${quote.id}`,
            text: quote.text,
            inLanguage: "pt-BR",
            spokenByCharacter: { "@type": "Person", name: quote.person.name, ...(quote.person.image_url ? { image: quote.person.image_url } : {}) },
            ...(quote.said_on ? { dateCreated: quote.said_on } : {}),
            ...(quote.context ? { description: quote.context } : {}),
            ...(quote.source_url ? { isBasedOn: quote.source_url } : {}),
            isPartOf: { "@type": "WebSite", "@id": `${siteUrl}/#site`, name: "Quem Disse Isso?", url: siteUrl },
          }}
        />
      )}
      <QuoteShared quote={quote} />
    </>
  );
}
