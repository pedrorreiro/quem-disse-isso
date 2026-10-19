/** Dados estruturados (schema.org) para o Google entender a página. `<` escapado contra injeção de HTML. */
export default function JsonLd({ data }: { data: object }) {
  return <script type="application/ld+json" dangerouslySetInnerHTML={{ __html: JSON.stringify(data).replace(/</g, "\\u003c") }} />;
}
