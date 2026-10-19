import { rpc } from "./api";

async function post(path: string, body: unknown = {}) {
  const res = await fetch(path, { method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(body) });
  const out = (await res.json().catch(() => ({}))) as { error?: string };
  if (!res.ok || out.error) throw new Error(out.error ?? `Erro ${res.status}`);
}

export async function me(): Promise<{ id: string; is_anonymous: boolean } | null> {
  const res = await fetch("/api/auth/me", { cache: "no-store" });
  const out = (await res.json().catch(() => ({}))) as { user?: { id: string; is_anonymous: boolean } | null; error?: string };
  if (!res.ok) throw new Error(out.error ?? `Erro ${res.status}`);
  return out.user ?? null;
}

export const sendOtp = (email: string) => post("/api/auth/otp", { email });
export const verifyOtp = (email: string, code: string) => post("/api/auth/verify", { email, code });
export const adoptSession = (access_token: string, refresh_token: string) =>
  post("/api/auth/session", { access_token, refresh_token });
export const logout = () => post("/api/auth/logout");

export type PhotoStatus = "pending" | "approved" | "rejected";

export type Person = {
  id: string;
  name: string;
  slug: string;
  category: string;
  area: string | null;
  gender: "m" | "f" | null;
  country: string | null;
  bio_short: string | null;
  wikidata_id: string | null;
  image_url: string | null;
  image_type: "foto" | "ilustracao";
  image_credit: string | null;
  image_license: string | null;
  image_source_url: string | null;
  photo_status: PhotoStatus;
  is_demo: boolean;
};

export type QuoteFields = {
  person_id?: string;
  text?: string;
  said_on?: string | null;
  context?: string | null;
  vibe?: string | null;
  source_type?: string | null;
  source_url?: string;
  source_timestamp?: string | null;
  archive_url?: string | null;
  difficulty?: number;
  kind?: "iconica" | "polemica";
};

export type DraftQuote = Required<Pick<QuoteFields, "text" | "source_url" | "difficulty">> &
  QuoteFields & {
    id: string;
    person_id: string;
    is_demo: boolean;
    review_note: string | null;
    status: QuoteStatus;
    person: Pick<Person, "id" | "name" | "category" | "image_url" | "photo_status">;
  };

export type QuoteStatus = "draft" | "verified" | "rejected";

/** Frase na lista completa do painel, com o uso no jogo. */
export type AdminQuote = DraftQuote & { playable: boolean; plays: number; hits: number; created_at: string };

export type Overview = {
  quotes_draft: number;
  quotes_verified: number;
  quotes_rejected: number;
  photos_pending: number;
  people_no_photo: number;
  playable: number;
};

type HitCount = { answers: number; hits: number };

/** Estatísticas de acertos e erros do painel. */
export type Stats = {
  totals: HitCount & {
    players: number;
    timeouts: number;
    avg_secs: number | null;
    players_today: number;
    answers_today: number;
    games: number;
    finished: number;
  };
  by_day: (HitCount & { day: string; players: number })[];
  by_category: (HitCount & { category: string })[];
  by_kind: (HitCount & { kind: "iconica" | "polemica" })[];
  by_mode: (HitCount & { mode: string })[];
  people: (HitCount & {
    id: string;
    name: string;
    category: string;
    image_url: string | null;
    quotes: number;
    timeouts: number;
    avg_secs: number | null;
    /** vezes que a galera chutou esta pessoa numa frase de outra */
    decoy: number;
    confused_with: { name: string; count: number }[] | null;
  })[];
  confusions: { said_by: string; said_by_image: string | null; guessed: string; guessed_image: string | null; count: number }[];
  /** frases com 3+ respostas */
  quotes: (HitCount & { id: string; text: string; person: string; person_image: string | null; kind: "iconica" | "polemica" })[];
};

export type ReviewAction = "approve" | "reject" | "save" | "reopen";

export const isAdmin = () => rpc<boolean>("is_admin");
export const adminOverview = () => rpc<Overview>("admin_overview");
export const adminStats = (days: number | null) => rpc<Stats>("admin_stats", { p_days: days });
export const adminPeople = () => rpc<Person[]>("admin_people");
export const adminQuoteQueue = () => rpc<DraftQuote[]>("admin_quote_queue");
export const adminQuotes = () => rpc<AdminQuote[]>("admin_quotes");
/** Apaga de vez uma frase rejeitada (o banco recusa as outras). */
export const deleteQuote = (id: string) => rpc<null>("admin_delete_quote", { p_quote_id: id });

export const reviewQuote = (id: string, action: ReviewAction, fields: QuoteFields = {}, note?: string) =>
  rpc<unknown>("admin_review_quote", { p_quote_id: id, p_action: action, p_fields: fields, p_note: note ?? null });

export const createQuote = (fields: QuoteFields) => rpc<string>("admin_create_quote", { p: fields });

export const upsertPerson = (p: Partial<Person>) => rpc<string>("admin_upsert_person", { p });

export const reviewPhoto = (personId: string, action: "approve" | "reject") =>
  rpc<null>("admin_review_photo", { p_person_id: personId, p_action: action });

export const SOURCE_TYPES = ["video", "entrevista", "post", "discurso", "musica", "materia"] as const;

export function slugify(s: string) {
  return s
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "")
    .toLowerCase()
    .replace(/[^a-z0-9]+/g, "-")
    .replace(/^-|-$/g, "");
}

/** URL de embed do YouTube começando no minuto da fonte, para conferir sem sair do painel. */
export function youtubeEmbed(url: string, timestamp?: string | null): string | null {
  const m = url.match(/(?:youtube\.com\/(?:watch\?v=|shorts\/|live\/)|youtu\.be\/)([\w-]{11})/);
  if (!m) return null;
  const start = (timestamp ?? "")
    .split(":")
    .map(Number)
    .reduce((acc, n) => (Number.isFinite(n) ? acc * 60 + n : acc), 0);
  return `https://www.youtube-nocookie.com/embed/${m[1]}${start ? `?start=${start}` : ""}`;
}
