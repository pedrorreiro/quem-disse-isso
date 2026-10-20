import type { Metadata, Viewport } from "next";
import { Analytics } from "@vercel/analytics/next";
import { SpeedInsights } from "@vercel/speed-insights/next";
import { Bricolage_Grotesque, Geist } from "next/font/google";
import "./globals.css";
import { ogDefault, siteUrl } from "@/lib/site";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const bricolage = Bricolage_Grotesque({
  variable: "--font-bricolage",
  subsets: ["latin"],
  axes: ["wdth", "opsz"],
});

const description =
  "Jogo de adivinhar quem disse a frase: frases icônicas e polêmicas de famosos, políticos, jogadores, BBBs e influenciadores. Grátis, sem cadastro, e toda frase tem fonte.";

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: { default: "Quem Disse Isso? — Jogo de adivinhar quem disse a frase", template: "%s | Quem Disse Isso?" },
  description,
  applicationName: "Quem Disse Isso?",
  keywords: [
    "quem disse isso",
    "quem disse",
    "jogo de frases",
    "adivinhe quem disse",
    "quiz de famosos",
    "frases polêmicas",
    "frases icônicas",
    "frases de famosos",
    "quiz online",
    "desafio do dia",
  ],
  openGraph: { ...ogDefault, title: "Quem Disse Isso?", description: "Aparece a frase. Você adivinha quem disse. Dá pra acertar todas?" },
  twitter: { card: "summary_large_image" },
  verification: { google: "3BzUTrouCM6_p-XL3lc5VCy1GnPWDmr25Gm5zaIeX5w" },
};

export const viewport: Viewport = {
  themeColor: "#0d0717",
  width: "device-width",
  initialScale: 1,
};

const MODE_SCRIPT = `try{if(!location.pathname.startsWith("/admin")&&localStorage.getItem("qdi:modo")==="polemica")document.documentElement.dataset.mode="polemica"}catch(e){}`;

export default function RootLayout({ children }: LayoutProps<"/">) {
  return (
    <html lang="pt-BR" className={`${geistSans.variable} ${bricolage.variable} h-full antialiased`} suppressHydrationWarning>
      <head>
        {/* modo polêmica antes do primeiro quadro, para a página não piscar com a paleta padrão */}
        <script dangerouslySetInnerHTML={{ __html: MODE_SCRIPT }} />
        <script defer src="https://cloud.umami.is/script.js" data-website-id="59f51bde-e664-4500-addf-281f8649b27f" />
      </head>
      <body className="min-h-dvh">
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
