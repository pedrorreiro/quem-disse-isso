export type Option = {
  id: string;
  name: string;
  image_url: string;
  image_credit: string | null;
};

export type Jokers = { fifty?: number; time?: number; skip?: number };
export type JokerName = keyof Jokers;

export type Round = {
  finished: false;
  round_id: string;
  position: number;
  total_rounds: number;
  quote_text: string;
  options: Option[];
  eliminated: string[];
  total_seconds: number;
  seconds_left: number;
  score: number;
  streak: number;
  jokers: Jokers;
  /** sha256("<round_id>:<id de quem disse>"): o navegador confere a resposta sem esperar o servidor. */
  answer_key?: string;
};

export type RoundResult = "correct" | "wrong" | "skipped" | "pending";

export type Summary = {
  finished: true;
  session_id: string;
  mode: GameMode;
  daily_day: string | null;
  challenge_id: string | null;
  status: "playing" | "finished";
  score: number;
  correct: number;
  total_rounds: number;
  best_streak: number;
  results: RoundResult[];
};

export type Reveal = {
  correct: boolean;
  timed_out: boolean;
  points: number;
  multiplier: number;
  streak: number;
  score: number;
  finished: boolean;
  chosen_person_id: string | null;
  quote_id: string;
  person: Option & { image_license: string | null; image_source_url: string | null };
  quote: {
    text: string;
    said_on: string | null;
    context: string | null;
    source_type: string | null;
    /** Nulo em Reality Show, que não mostra fonte. */
    source_url: string | null;
    source_timestamp: string | null;
    archive_url: string | null;
  };
  /** Próxima rodada (sem relógio ainda) ou o resumo, quando a partida acabou. */
  next?: Omit<Round, "seconds_left"> | null;
  summary?: Summary | null;
};

export type GameMode = "solo" | "daily" | "shared" | "challenge";

/** Desafio público: nome e resultado de quem desafiou (sem as frases). */
export type Challenge = {
  id: string;
  name: string | null;
  mode: GameMode;
  correct: number;
  total_rounds: number;
  best_streak: number;
  results: RoundResult[];
};

/** Categoria na tela de escolha: quantos famosos tem e algumas fotos para a capa. */
export type CategoryInfo = { id: string; people: number; faces: string[] };

/** Frases jogáveis de uma categoria e quantas o jogador já respondeu. */
export type CategoryProgress = { category: string; total: number; seen: number };
