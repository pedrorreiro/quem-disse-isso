# Quem Disse Isso?

Aparece uma frase de uma pessoa famosa; o jogador escolhe, entre 4 cartas (foto + nome), quem a disse. Toda frase tem fonte real clicável.

Next.js (App Router, mobile-first) + Supabase (Postgres, Auth anônimo, RPCs). O navegador só fala com o Next (`/api/*`); o Supabase é chamado apenas no servidor. Plano completo: [`../PLANO.md`](../PLANO.md).

## Rodando

1. **Supabase** — local (`supabase start`, aplica `supabase/migrations` e `supabase/seed.sql`) ou um projeto na nuvem:
   - rode as migrations em ordem (`supabase/migrations/*.sql`) e depois `supabase/seed.sql`;
   - em **Authentication → Sign In / Providers**, ative **Allow anonymous sign-ins** (jogadores) e o login por **e-mail** (admin);
   - em **Authentication → URL Configuration**, adicione `http://localhost:3000/admin` (e a URL de produção) nas Redirect URLs;
   - em **Authentication → Rate Limits**, aumente o limite de cadastros anônimos: as sessões são criadas pelo servidor, então muitos jogadores podem chegar do mesmo IP.
2. `cp .env.example .env.local` e preencha `SUPABASE_URL` e `SUPABASE_ANON_KEY` (só o servidor lê).
3. `npm install && npm run dev` → http://localhost:3000

## Como funciona

| Rota | O que é |
|---|---|
| `/` | Início, categorias vindas do banco |
| `/jogar?cat=…` | Partida solo de 10 rodadas (opcionalmente por categoria) |
| `/diario` | Desafio do dia: 5 frases iguais para todos, uma tentativa por dia (fuso America/Sao_Paulo) |
| `/desafio/<id>` | Desafio de um amigo: as mesmas frases, na mesma ordem, e no fim o placar "você x ele" |
| `/q/<id>` | Frase compartilhada já revelada: frase, quem disse, fonte e botão para jogar |
| `/creditos` | Créditos das fotos aprovadas (autor + licença) |
| `/admin` | Painel de revisão (só admins) |

No desktop: teclas **1–4** escolhem a carta e **Enter** avança.

## Revisão: só o admin aprova

1. Entre em `/admin` com seu e-mail (link mágico). Na primeira vez a tela mostra o SQL para virar admin:
   `insert into public.admins (user_id) values ('<seu id>');`
2. **Frases**: fila de rascunhos, uma por vez. Dá para editar, salvar rascunho, rejeitar (com anotação) ou aprovar. Fonte do YouTube aparece embutida no minuto informado.
3. **Fotos**: cada pessoa precisa de foto aprovada. *Trocar foto* busca a pessoa no Wikidata e puxa a foto do Commons já com autor e licença.
4. **Pessoas** / **Nova frase**: cadastro manual (frases novas entram como rascunho).

O jogo só usa frases `verified` **de pessoas com foto aprovada**. Um trigger impede marcar frase como `verified` ou foto como `approved` sem um admin registrado como responsável, inclusive por SQL direto. É uma trava contra engano: quem tem acesso total ao banco ainda pode desligar triggers. Trocar a foto de uma pessoa a devolve para `pending`.

### Regras (validadas no servidor)
- O resultado mostrado é em **acertos** (ex.: 7/10) e maior sequência. O servidor ainda calcula pontos internamente, mas eles não aparecem.
- 30 s por rodada. Curingas (solo e desafio): 50/50, +5 s, pular.
- **Desafiar um amigo**: ao terminar uma partida, o jogo gera um link `/desafio/<id>` com o nome escolhido. Quem abre joga as mesmas frases e compara os acertos. Cada pessoa joga cada desafio uma vez (abrir de novo retoma a mesma partida).
- As 3 opções erradas vêm da mesma **área** (futebol, música…), do mesmo **gênero** e do mesmo lado (brasileiro x gringo) de quem disse. Área e gênero ficam editáveis em /admin → Pessoas.

### Segurança
O navegador não conhece a URL nem a chave do Supabase. Ele chama `/api/rpc/<função>` (lista fechada de funções), `/api/categories` e `/api/auth/*`; o servidor do Next repassa ao Supabase. A sessão (anônima para jogadores, por e-mail para o admin) fica em cookies `httpOnly`, renovada no servidor.

No banco, o cliente **não lê** `quotes` nem `game_rounds` (RLS sem policies). Tudo passa por funções `SECURITY DEFINER` (`start_game`, `next_round`, `answer_round`, `use_joker`, `eliminate_option`, `get_session_summary`, `get_quote_preview`, `get_quote_public`, `create_challenge`, `get_challenge`, `start_challenge`) que não revelam a resposta antes de ela ser enviada e medem o tempo no servidor. Funções internas (`_pick_options`, …) não são executáveis pelo cliente.

## Dados de exemplo

`supabase/seed.sql` cria **12 pessoas e 14 frases fictícias inventadas** (`is_demo = true`, ilustrações em `public/demo/`), todas como rascunho e foto pendente. Aprove pelo painel para testar. Antes de publicar:

```sql
delete from quotes where is_demo;
delete from people where is_demo;
```

Frases reais só entram com `status = 'verified'`, fonte primária (`source_url`, `source_timestamp` se for vídeo) e snapshot (`archive_url`).

## Ainda não feito (próximas etapas)
- Curadoria das frases reais (candidatas entram como rascunho para revisão).
- Duelo ao vivo e salas com amigos.
- Rate limit / anti-abuso nas RPCs e ranking.
