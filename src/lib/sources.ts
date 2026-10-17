// Veículos grandes e conhecidos aceitos como fonte das frases (o subdomínio não importa: g1.globo.com → globo.com).
const TRUSTED = [
  // Brasil
  "globo.com", "folha.uol.com.br", "uol.com.br", "estadao.com.br", "cnnbrasil.com.br", "abril.com.br",
  "terra.com.br", "metropoles.com", "istoe.com.br", "correiobraziliense.com.br", "poder360.com.br",
  "exame.com", "infomoney.com.br", "cartacapital.com.br", "gazetadopovo.com.br", "em.com.br", "uai.com.br", "jb.com.br", "opovo.com.br",
  "band.com.br", "r7.com", "sbt.com.br", "jovempan.com.br", "lance.com.br", "rollingstone.com.br",
  // fora do Brasil
  "cnn.com", "bbc.com", "bbc.co.uk", "nytimes.com", "washingtonpost.com", "theguardian.com", "reuters.com",
  "apnews.com", "npr.org", "nbcnews.com", "cbsnews.com", "abcnews.go.com", "time.com", "variety.com",
  "rollingstone.com", "espn.com", "espn.com.br", "goal.com", "skysports.com", "nbcsports.com", "foxsports.com",
  "eonline.com", "elpais.com", "clarin.com", "lanacion.com.ar", "dn.pt", "publico.pt", "cmjornal.pt",
  // canais oficiais
  "youtube.com", "premierleague.com", "palmeiras.com.br",
];

/** A fonte é de um veículo grande? URL inválida conta como não. */
export function isTrustedSource(url: string | null | undefined): boolean {
  let host: string;
  try {
    host = new URL(url ?? "").hostname.replace(/^www\./, "");
  } catch {
    return false;
  }
  return TRUSTED.some((d) => host === d || host.endsWith(`.${d}`));
}
