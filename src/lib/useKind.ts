"use client";

import { useSyncExternalStore } from "react";
import { setStoredKind, storedKind, subscribeKind, type Kind } from "./kind";

/** Tipo escolhido pelo jogador (lembrado no navegador). No servidor é sempre "iconica". */
export function useKind(): [Kind, (k: Kind) => void] {
  const kind = useSyncExternalStore(subscribeKind, storedKind, () => "iconica" as Kind);
  return [kind, setStoredKind];
}
