import type { Metadata, Viewport } from "next";
import { Analytics } from "@vercel/analytics/next";
import { SpeedInsights } from "@vercel/speed-insights/next";
import { Bricolage_Grotesque, Geist } from "next/font/google";
import "./globals.css";
import { siteUrl } from "@/lib/site";

const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const bricolage = Bricolage_Grotesque({
  variable: "--font-bricolage",
  subsets: ["latin"],
  axes: ["wdth", "opsz"],
});

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: "Quem Disse Isso?",
  description: "Aparece uma frase. Você adivinha quem foi que disse. Toda frase tem fonte.",
  openGraph: { title: "Quem Disse Isso?", siteName: "Quem Disse Isso?", type: "website", locale: "pt_BR" },
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
      </head>
      <body className="min-h-dvh">
        {children}
        <Analytics />
        <SpeedInsights />
      </body>
    </html>
  );
}
