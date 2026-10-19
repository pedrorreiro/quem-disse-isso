import type { Metadata } from "next";
import Link from "next/link";
import { notFound } from "next/navigation";
import { Play, Quote } from "lucide-react";
import JsonLd from "@/components/JsonLd";
import { KIND_ADJ, KINDS } from "@/lib/kind";
import { getPersonPublic, type PersonPublic } from "@/lib/preview";
import { categoryLabel, quoteDetail } from "@/lib/share";
import { ogDefault, siteUrl } from "@/lib/site";

// frases novas entram pelo admin; a página se refaz a cada hora
export const revalidate = 3600;

/** "icônicas e polêmicas", só com os tipos que a pessoa tem. */
function kindsLabel(person: PersonPublic) {
  return KINDS.filter((k) => person.quotes.some((q) => q.kind === k))
    .map((k) => KIND_ADJ[k])
    .join(" e ");
}

function describe(person: PersonPublic) {
  const n = person.quotes.length;
  const first = person.quotes[0].text;
  const lead = first.length > 90 ? `${first.slice(0, 90).replace(/\s+\S*$/, "")}…` : first;
  return `${n} ${n === 1 ? "frase" : "frases"} de ${person.name} com fonte, como “${lead}” Teste se você adivinha quem disse.`;
}

export async function generateMetadata({ params }: PageProps<"/famoso/[slug]">): Promise<Metadata> {
  const { slug } = await params;
  const person = await getPersonPublic(slug);
  if (!person) return { title: "Pessoa não encontrada", robots: { index: false, follow: false } };
  const title = `Frases de ${person.name}: ${kindsLabel(person)}`;
  const description = describe(person);
  const url = `/famoso/${person.slug}`;
  return {
    title,
    description,
    alternates: { canonical: url },
    openGraph: { ...ogDefault, type: "profile", url, title, description },
  };
}

export default async function FamosoPage({ params }: PageProps<"/famoso/[slug]">) {
  const { slug } = await params;
  const person = await getPersonPublic(slug);
  if (!person) notFound();

  const url = `${siteUrl}/famoso/${person.slug}`;
  const jsonLd = {
    "@context": "https://schema.org",
    "@graph": [
      {
        "@type": "Person",
        "@id": `${url}#pessoa`,
        name: person.name,
        ...(person.bio_short ? { description: person.bio_short } : {}),
        ...(person.image_url ? { image: person.image_url } : {}),
      },
      {
        "@type": "ItemList",
        "@id": `${url}#frases`,
        name: `Frases de ${person.name}`,
        url,
        numberOfItems: person.quotes.length,
        itemListElement: person.quotes.map((q, i) => ({
          "@type": "ListItem",
          position: i + 1,
          url: `${siteUrl}/q/${q.id}`,
          item: {
            "@type": "Quotation",
            "@id": `${siteUrl}/q/${q.id}`,
            text: q.text,
            inLanguage: "pt-BR",
            spokenByCharacter: { "@id": `${url}#pessoa` },
            ...(q.said_on ? { dateCreated: q.said_on } : {}),
          },
        })),
        isPartOf: { "@type": "WebSite", "@id": `${siteUrl}/#site`, name: "Quem Disse Isso?", url: siteUrl },
      },
    ],
  };

  return (
    <>
      <JsonLd data={jsonLd} />
      <div className="flex flex-col gap-8 py-10 md:mx-auto md:w-full md:max-w-xl">
        <header className="flex items-center gap-4">
          {person.image_url && (
            // eslint-disable-next-line @next/next/no-img-element
            <img src={person.image_url} alt={person.name} className="size-20 shrink-0 rounded-2xl object-cover ring-4 ring-lime md:size-24" />
          )}
          <div className="min-w-0">
            <p className="text-xs font-bold uppercase tracking-widest text-white/50">{categoryLabel(person.category)}</p>
            <h1 className="font-display text-3xl font-black leading-tight md:text-4xl">Frases de {person.name}</h1>
            {person.bio_short && <p className="text-sm text-white/60">{person.bio_short}</p>}
          </div>
        </header>

        <Link
          href={`/jogar?cat=${encodeURIComponent(person.category)}`}
          className="btn-pop flex items-center justify-center gap-2 bg-lime py-4 font-display text-xl font-black text-ink"
        >
          <Play className="size-5 fill-current" aria-hidden />
          Jogar: {categoryLabel(person.category)}
        </Link>

        {/* uma seção por tipo, icônicas primeiro (o padrão do app) */}
        {KINDS.map((kind) => {
          const quotes = person.quotes.filter((q) => q.kind === kind);
          if (quotes.length === 0) return null;
          return (
            <section key={kind} className="flex flex-col gap-3">
              <h2 className="font-display text-xl font-black text-white">
                Frases {KIND_ADJ[kind]} de {person.name}
              </h2>
              <ul className="flex flex-col gap-3">
                {quotes.map((q) => {
                  const detail = quoteDetail(q.context, q.said_on);
                  return (
                    <li key={q.id}>
                      <Link
                        href={`/q/${q.id}`}
                        className="flex gap-3 rounded-2xl bg-white/[0.07] px-4 py-4 ring-1 ring-white/10 transition hover:bg-white/[0.12] md:backdrop-blur"
                      >
                        <Quote className="mt-1 size-4 shrink-0 fill-current text-pink" aria-hidden />
                        <div className="min-w-0">
                          <p className="font-bold leading-snug text-white/90">{q.text}</p>
                          {detail && <p className="mt-1 text-xs text-white/50">{detail}</p>}
                        </div>
                      </Link>
                    </li>
                  );
                })}
              </ul>
            </section>
          );
        })}

        {person.related.length > 0 && (
          <section className="flex flex-col gap-3">
            <h2 className="font-display text-xl font-black text-white">Mais frases de {categoryLabel(person.category)}</h2>
            <ul className="flex flex-wrap gap-2">
              {person.related.map((r) => (
                <li key={r.slug}>
                  <Link href={`/famoso/${r.slug}`} className="inline-block rounded-full bg-white/10 px-3 py-1.5 text-sm text-white/80 hover:bg-white/20">
                    {r.name}
                  </Link>
                </li>
              ))}
            </ul>
          </section>
        )}

        {person.image_credit && (
          <p className="text-center text-[11px] text-white/35">
            Foto:{" "}
            {person.image_source_url ? (
              <a href={person.image_source_url} target="_blank" rel="noopener noreferrer" className="underline">
                {person.image_credit}
              </a>
            ) : (
              person.image_credit
            )}
            {person.image_license ? ` (${person.image_license})` : ""}
          </p>
        )}
      </div>
    </>
  );
}
