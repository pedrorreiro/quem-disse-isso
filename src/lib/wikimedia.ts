// Busca de pessoas e fotos no Wikidata / Wikimedia Commons (roda no navegador; APIs com CORS via origin=*).

export type WikiHit = { id: string; label: string; description?: string };

export type WikiPhoto = {
  wikidata_id: string;
  image_url: string;
  image_credit: string;
  image_license: string;
  image_source_url: string;
};

const WIKIDATA = "https://www.wikidata.org/w/api.php";
const COMMONS = "https://commons.wikimedia.org/w/api.php";

async function getJson(base: string, params: Record<string, string>) {
  const url = `${base}?${new URLSearchParams({ format: "json", origin: "*", ...params })}`;
  const res = await fetch(url);
  if (!res.ok) throw new Error(`Wikimedia respondeu ${res.status}`);
  return res.json();
}

export async function searchPeople(query: string): Promise<WikiHit[]> {
  const data = await getJson(WIKIDATA, {
    action: "wbsearchentities",
    search: query,
    language: "pt",
    uselang: "pt",
    type: "item",
    limit: "8",
  });
  return (data.search ?? []).map((h: { id: string; label: string; description?: string }) => ({
    id: h.id,
    label: h.label,
    description: h.description,
  }));
}

function htmlToText(html: string) {
  return new DOMParser().parseFromString(html, "text/html").body.textContent?.trim() ?? "";
}

/**
 * Para a carga em lote: usa o wikidata_id se já houver; senão pega o primeiro resultado
 * da busca pelo nome que tenha foto. A foto continua indo para a fila de aprovação.
 */
export async function findPhoto(name: string, wikidataId?: string | null): Promise<WikiPhoto | null> {
  const ids = wikidataId ? [wikidataId] : (await searchPeople(name)).slice(0, 3).map((h) => h.id);
  for (const id of ids) {
    const photo = await getPhoto(id);
    if (photo) return photo;
  }
  return null;
}

/** Foto principal (P18) da pessoa no Wikidata, com autor e licença vindos do Commons. */
export async function getPhoto(wikidataId: string): Promise<WikiPhoto | null> {
  const entity = await getJson(WIKIDATA, { action: "wbgetentities", ids: wikidataId, props: "claims" });
  const file: string | undefined = entity.entities?.[wikidataId]?.claims?.P18?.[0]?.mainsnak?.datavalue?.value;
  if (!file) return null;

  const info = await getJson(COMMONS, {
    action: "query",
    titles: `File:${file}`,
    prop: "imageinfo",
    iiprop: "url|extmetadata",
    iiurlwidth: "600",
  });
  const page = Object.values(info.query?.pages ?? {})[0] as
    | { imageinfo?: { thumburl?: string; url: string; descriptionurl: string; extmetadata?: Record<string, { value: string }> }[] }
    | undefined;
  const ii = page?.imageinfo?.[0];
  if (!ii) return null;
  const meta = ii.extmetadata ?? {};
  return {
    wikidata_id: wikidataId,
    image_url: ii.thumburl ?? ii.url,
    image_credit: htmlToText(meta.Artist?.value ?? "") || "Desconhecido",
    image_license: meta.LicenseShortName?.value ?? "ver fonte",
    image_source_url: ii.descriptionurl,
  };
}
