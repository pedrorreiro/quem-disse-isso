"use client";

import { useCallback, useEffect, useState } from "react";
import Link from "next/link";
import { adminOverview, adoptSession, isAdmin, logout, me, sendOtp, verifyOtp, type Overview } from "@/lib/admin";
import { friendlyError } from "@/lib/api";
import NewQuote from "./NewQuote";
import PeopleAdmin from "./PeopleAdmin";
import QuoteReview from "./QuoteReview";
import { Field, btnGhost, btnPrimary, input } from "./ui";

type Tab = "quotes" | "photos" | "people" | "new";
type Auth = { state: "loading" } | { state: "login" } | { state: "denied"; userId: string } | { state: "ok" };

export default function AdminApp() {
  const [auth, setAuth] = useState<Auth>({ state: "loading" });
  const [error, setError] = useState("");

  const check = useCallback(async () => {
    try {
      const user = await me();
      if (!user || user.is_anonymous) return setAuth({ state: "login" });
      setAuth((await isAdmin()) ? { state: "ok" } : { state: "denied", userId: user.id });
    } catch (e) {
      setError(friendlyError(e));
    }
  }, []);

  const signOut = useCallback(() => {
    logout().finally(() => void check());
  }, [check]);

  useEffect(() => {
    // link mágico: os tokens chegam no #hash; viram cookie no servidor e saem da URL
    const hash = new URLSearchParams(window.location.hash.slice(1));
    const at = hash.get("access_token");
    const rt = hash.get("refresh_token");
    if (at && rt) history.replaceState(null, "", window.location.pathname);
    const adopted = at && rt ? adoptSession(at, rt).catch(() => {}) : Promise.resolve();
    adopted.then(() => check());
  }, [check]);

  if (error) return <Centered><p className="text-rose-300">{error}</p></Centered>;
  if (auth.state === "loading") return <Centered><p className="animate-pulse text-white/50">Carregando…</p></Centered>;
  if (auth.state === "login") return <Centered><Login onDone={() => void check()} /></Centered>;
  if (auth.state === "denied") {
    return (
      <Centered>
        <div className="flex max-w-lg flex-col gap-4">
          <h1 className="text-xl font-bold">Esta conta não é admin</h1>
          <p className="text-white/60">Para liberar, rode no SQL Editor do Supabase:</p>
          <pre className="overflow-x-auto rounded-lg bg-white/5 p-3 text-sm">
            insert into public.admins (user_id) values (&apos;{auth.userId}&apos;);
          </pre>
          <button type="button" className={btnGhost} onClick={signOut}>
            Sair
          </button>
        </div>
      </Centered>
    );
  }
  return <Dashboard onSignOut={signOut} />;
}

function Centered({ children }: { children: React.ReactNode }) {
  return <div className="flex min-h-dvh items-center justify-center p-4">{children}</div>;
}

function Login({ onDone }: { onDone: () => void }) {
  const [email, setEmail] = useState("");
  const [code, setCode] = useState("");
  const [sent, setSent] = useState(false);
  const [msg, setMsg] = useState("");

  async function send() {
    setMsg("");
    try {
      await sendOtp(email);
      setSent(true);
    } catch (e) {
      setMsg(friendlyError(e));
    }
  }

  async function verify() {
    setMsg("");
    try {
      await verifyOtp(email, code);
      onDone();
    } catch (e) {
      setMsg(friendlyError(e));
    }
  }

  return (
    <form
      className="flex w-full max-w-sm flex-col gap-4"
      onSubmit={(e) => {
        e.preventDefault();
        void (sent ? verify() : send());
      }}
    >
      <h1 className="text-2xl font-black">Painel de revisão</h1>
      {!sent ? (
        <>
          <Field label="E-mail">
            <input className={input} type="email" required value={email} onChange={(e) => setEmail(e.target.value)} />
          </Field>
          <button className={btnPrimary} type="submit">
            Enviar link de acesso
          </button>
        </>
      ) : (
        <>
          <p className="text-sm text-white/60">
            Enviamos um link para <strong>{email}</strong>. Abra neste navegador. Se o e-mail trouxer um código, digite aqui:
          </p>
          <Field label="Código">
            <input className={input} inputMode="numeric" value={code} onChange={(e) => setCode(e.target.value)} />
          </Field>
          <button className={btnPrimary} type="submit" disabled={!code.trim()}>
            Entrar
          </button>
          <button className="text-sm text-white/50 underline" type="button" onClick={() => setSent(false)}>
            Trocar e-mail
          </button>
        </>
      )}
      {msg && <p className="text-sm text-rose-300">{msg}</p>}
    </form>
  );
}

function Dashboard({ onSignOut }: { onSignOut: () => void }) {
  const [tab, setTab] = useState<Tab>("quotes");
  const [overview, setOverview] = useState<Overview | null>(null);

  const refresh = useCallback(() => {
    adminOverview().then(setOverview).catch(() => {});
  }, []);
  useEffect(refresh, [refresh]);

  const tabs: { id: Tab; label: string; badge?: number }[] = [
    { id: "quotes", label: "Frases", badge: overview?.quotes_draft },
    { id: "photos", label: "Fotos", badge: overview?.photos_pending },
    { id: "people", label: "Pessoas" },
    { id: "new", label: "Nova frase" },
  ];

  return (
    <div className="mx-auto flex w-full max-w-6xl flex-col gap-6 px-4 py-6 md:px-8">
      <header className="flex flex-wrap items-center justify-between gap-4">
        <div>
          <h1 className="text-2xl font-black">
            Quem disse isso? <span className="text-amber-400">· Revisão</span>
          </h1>
          {overview && (
            <p className="text-sm text-white/50">
              {overview.playable} frase(s) no jogo · {overview.quotes_verified} aprovada(s) · {overview.quotes_rejected} rejeitada(s)
            </p>
          )}
        </div>
        <div className="flex gap-2">
          <Link href="/" className={btnGhost}>
            Ver o jogo
          </Link>
          <button type="button" className={btnGhost} onClick={onSignOut}>
            Sair
          </button>
        </div>
      </header>

      <nav className="flex gap-1 overflow-x-auto rounded-xl bg-white/5 p-1" aria-label="Seções">
        {tabs.map((t) => (
          <button
            key={t.id}
            type="button"
            onClick={() => setTab(t.id)}
            className={`flex items-center gap-2 whitespace-nowrap rounded-lg px-4 py-2 text-sm font-semibold ${
              tab === t.id ? "bg-amber-400 text-neutral-950" : "text-white/70 hover:bg-white/5"
            }`}
          >
            {t.label}
            {!!t.badge && (
              <span className={`rounded-full px-2 text-xs ${tab === t.id ? "bg-neutral-950/20" : "bg-amber-400/20 text-amber-300"}`}>
                {t.badge}
              </span>
            )}
          </button>
        ))}
      </nav>

      {tab === "quotes" && <QuoteReview onChanged={refresh} />}
      {tab === "photos" && <PeopleAdmin key="photos" view="photos" onChanged={refresh} />}
      {tab === "people" && <PeopleAdmin key="people" view="people" onChanged={refresh} />}
      {tab === "new" && <NewQuote onChanged={refresh} />}
    </div>
  );
}
