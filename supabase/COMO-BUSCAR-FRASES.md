# Como buscar frases para uma carga

Guia para montar uma carga nova (`supabase/carga-NN-<tema>.sql`), por uma pessoa ou por um agente. O padrão a seguir é a [carga 4](carga-04-youtubers.sql).

## 0. Dois tipos de frase

Toda frase tem um `kind`, e o jogador escolhe na home qual quer jogar (o padrão é Icônicas):

- **`polemica`**: deu repercussão de verdade. É o critério da seção 1 abaixo.
- **`iconica`**: bordão, meme ou fala que o público sabe de cor ("Ô loco, meu!", "Vamos fazer um sarau?"). Não precisa ter dado treta, mas precisa ser famosa: a pessoa ouve e lembra na hora. Frase séria, desabafo ou opinião morna não entra em nenhum dos dois tipos.

Reality Show é sempre `iconica`. Nas outras categorias, cada frase recebe o tipo que melhor descreve por que ela é lembrada.

## 1. Polêmica: só frase que deu polêmica de verdade

A pergunta que decide é: **a frase em si virou notícia como polêmica?** Quem lê tem que pensar "não acredito que essa pessoa disse isso". Tem que ser algo que rodaria no Twitter/X.

Entra se a fala gerou pelo menos uma destas coisas:
- indignação pública registrada pela imprensa ("é criticado", "gera revolta", "vira trend");
- consequência concreta: demissão, perda de patrocínio, processo, investigação, cassação;
- pedido de desculpas ou retratação por causa da fala;
- choque pela contradição, como alguém que hoje defende X já tendo atacado X com força.

**Não entra:**
- **Treta leve ou palavrão sem repercussão.** Exemplo recusado: "Fútil é o c*ralho, eu elogiei o boy que você estava" (Mítico). É só uma resposta malcriada, e ninguém compartilharia.
- **Fala hipotética**, como "hoje eu responderia assim…". Tem que ser o que a pessoa disse de fato.
- **Frase genérica ou solta**: conselho, opinião morna, frase motivacional. (Bordão famoso entra, mas como `iconica`.)
- **Frase de outra pessoa** que a pessoa só compartilhou. Exemplo: "Não tem pobreza que resista a 14 horas de trabalho" é do Geraldo Rufino, não do Thiago Nigro.
- **Acusação sem prova contra alguém**, a menos que a própria fala seja o escândalo e a matéria trate como tal.
- **Assuntos que só machucam**, como aborto espontâneo ou morte de alguém próximo, ou casos de abuso infantil.

Teste rápido: se a manchete da matéria não fala da frase (ou da reação a ela), provavelmente a frase não serve.

## 2. Fontes: veículos grandes e confiáveis

Fonte principal, em ordem de preferência: **CNN Brasil, g1, O Globo, Folha, Terra, Metrópoles, Correio Braziliense, Veja, Exame, Poder360**. Para desmentidos e checagens, use **Aos Fatos**. Lance! só vale para futebol, e como fonte secundária.

- Estadão, UOL e BBC bloqueiam o buscador do agente. Podem entrar como fonte se alguém abrir a matéria no navegador, mas não conte com eles numa busca automática.
- Evite blogs, portais regionais pequenos e sites de fofoca sem nome (Tribuna de Jundiaí, ABC do ABC, Bahia Notícias etc.). Se a única fonte for dessas, a frase fica de fora.
- Na busca, filtre por domínio (por exemplo `allowed_domains`) para não cair em agregadores.

## 3. Como pesquisar

1. Liste nomes do tema (youtubers, futebol, política…) que já tiveram fama de polêmicos.
2. Busque `"<nome> fala polêmica"`, `"<nome> criticado"`, `"<nome> pede desculpas"`, `"<nome> processado"`, filtrando pelos domínios acima.
3. Abra a matéria e copie a fala **literalmente, entre aspas, como está no texto**. Não reescreva nem junte trechos de lugares diferentes. Palavrão censurado fica como a matéria publicou.
4. Anote:
   - a **data** em que a frase foi dita; se não houver, use a data da publicação e escreva isso no `review_note`;
   - **onde** foi dita (podcast, tuíte, live, entrevista);
   - **o que aconteceu depois** (a repercussão);
   - a **URL** da matéria.
5. Se a pessoa já existe no banco, confira o slug: `grep -h "'<slug>'" supabase/*.sql`.

## 4. Como escrever cada frase na carga

- **text**: a fala literal. Prefira o trecho mais chocante e que se entende sozinho.
- **context**: 1 a 3 frases que explicam onde a fala foi dita e o que veio depois. É o que o jogador lê depois de responder, então precisa deixar claro por que a frase foi polêmica.
- **source_type**: `video` (podcast, live ou vídeo), `post` (tuíte ou story), `entrevista`, `materia`, `discurso` ou `musica`.
- **kind**: `'polemica'` ou `'iconica'` (veja a seção 0). Se faltar, o banco grava `polemica`.
- **difficulty**:
  - `1` é a frase que quase todo mundo associa à pessoa (o partido nazista do Monark);
  - `2` é conhecida no nicho;
  - `3` surpreende ou engana (Felipe Neto chamando Lula de ladrão em 2016).
- **status**: sempre `'draft'`. Só o admin aprova em /admin.
- **review_note**: `Fonte: <veículo> · Por que: <uma linha sobre o choque> · Obs.: <o que conferir, datas aproximadas, fontes extras>`. Se a pessoa for nova, acrescente "Pessoa nova: aprove a foto em /admin → Fotos."

## 5. Formato do SQL

- `begin; … commit;`, e o arquivo precisa poder rodar mais de uma vez sem duplicar nada.
- Para cada pessoa nova: `insert into people (name, slug, category, area, gender, country, bio_short) … on conflict (slug) do nothing;`.
  - `category` é a categoria que aparece no app. A lista sai do banco; para uma categoria nova, coloque o rótulo em `CATEGORY_LABELS`, em `src/lib/share.ts`.
  - `area` agrupa as alternativas erradas (por exemplo, youtubers ficam com `internet`).
  - `gender` é `'m'` ou `'f'`.
- Cada frase segue o modelo `insert into quotes (...) select id, ... from people where slug = '…' and not exists (select 1 from quotes where text = '…');`, com o mesmo texto nos dois lugares.
- Aspas simples dentro dos textos viram `''`.
- Antes de commitar, verifique se as aspas estão balanceadas e se o texto do `select` bate com o do `not exists`. A carga 4 foi checada com um script Python curto.

## 6. Checklist final

- [ ] Toda frase passou no teste da seção 1 (gerou repercussão de verdade).
- [ ] Toda frase saiu literalmente de um veículo da seção 2, com a URL na carga.
- [ ] O contexto explica a polêmica e o que veio depois.
- [ ] Nada que só a pessoa compartilhou, nada hipotético, nada genérico.
- [ ] Tudo como `draft`, e o SQL pode rodar duas vezes sem duplicar.
