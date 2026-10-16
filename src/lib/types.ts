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
};

export type RoundResult = "correct" | "wrong" | "skipped" | "pending";

export type Summary = {
  finished: true;
  session_id: string;
  mode: GameMode;
  daily_day: string | null;
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
    source_url: string;
    source_timestamp: string | null;
    archive_url: string | null;
  };
};

export type GameMode = "solo" | "daily" | "shared";
