/** URL pública do site, usada em metadados, sitemap e links de compartilhamento. */
export const siteUrl = (
  process.env.NEXT_PUBLIC_SITE_URL ??
  (process.env.VERCEL_PROJECT_PRODUCTION_URL ? `https://${process.env.VERCEL_PROJECT_PRODUCTION_URL}` : "http://localhost:3000")
).replace(/\/$/, "");

/** Campos fixos do Open Graph. Página que define `openGraph` substitui o objeto inteiro, então espalhe isto nela. */
export const ogBase = { siteName: "Quem Disse Isso?", type: "website", locale: "pt_BR" } as const;

/** Imagem padrão de prévia (app/og). Só para páginas sem opengraph-image próprio: uma imagem explícita tem prioridade. */
export const ogDefault = {
  ...ogBase,
  images: [{ url: "/og", width: 1200, height: 630, alt: "Quem Disse Isso? Aparece a frase, você adivinha quem disse." }],
};
