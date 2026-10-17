-- Carga 14: Futebol, para chegar a pelo menos 20 frases por tipo (icônicas e polêmicas).
-- Fontes: Terra (listas do Lance!), Metrópoles e Correio Braziliense.
-- O agente não conseguiu abrir as matérias (o ambiente bloqueia os sites); os textos vêm dos trechos que a busca
-- devolveu. Por isso o review_note pede para conferir a frase na matéria antes de aprovar.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove em /admin → Fotos). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Zagallo', 'zagallo', 'futebol', 'futebol', 'm', 'BR', 'O Velho Lobo, único tetracampeão do mundo, como jogador e técnico'),
  ('Dadá Maravilha', 'dada-maravilha', 'futebol', 'futebol', 'm', 'BR', 'Centroavante do Atlético-MG, campeão do mundo em 1970'),
  ('Vicente Matheus', 'vicente-matheus', 'futebol', 'futebol', 'm', 'BR', 'Presidente histórico do Corinthians'),
  ('Muricy Ramalho', 'muricy-ramalho', 'futebol', 'futebol', 'm', 'BR', 'Técnico tricampeão brasileiro pelo São Paulo'),
  ('Adriano Imperador', 'adriano-imperador', 'futebol', 'futebol', 'm', 'BR', 'Centroavante do Flamengo e da Inter de Milão'),
  ('Eurico Miranda', 'eurico-miranda', 'futebol', 'futebol', 'm', 'BR', 'Cartola, ex-presidente do Vasco'),
  ('Abel Braga', 'abel-braga', 'futebol', 'futebol', 'm', 'BR', 'Técnico, campeão mundial pelo Internacional em 2006')
on conflict (slug) do nothing;

-- zagallo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Vocês vão ter que me engolir!', 'pt', '1997-06-29', 'Logo depois de vencer a Bolívia em La Paz e ganhar a Copa América, respondendo às críticas da imprensa. Em 2017 ele contou que era indireta para dois jornalistas.', 'entrevista', 'https://www.metropoles.com/esportes/relembre-frases-iconicas-de-zagallo', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: A frase mais famosa do Velho Lobo · Obs.: Versão mais longa no Lance!: "Vocês sabem quem são. Não preciso dizer mais nada, vocês vão ter que me engolir!". Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'zagallo'
  and not exists (select 1 from quotes where text = 'Vocês vão ter que me engolir!');
-- dada-maravilha
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Me diz o nome de três coisas que param no ar. Beija-flor, helicóptero e Dadá Maravilha.', 'pt', null, 'Como Dadá explicava o próprio cabeceio, sua especialidade.', 'entrevista', 'https://www.terra.com.br/esportes/lance/romario-eurico-edmundo-tulio-vampeta-felipe-melo-relembre-frases-marcantes-nos-ultimos-anos,af8bf1a097e7ea1f9660165867aaa9bemtgcaa2v.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Frase folclórica do futebol · Obs.: Texto pelo trecho da busca (lista do Lance! publicada no Terra). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'dada-maravilha'
  and not exists (select 1 from quotes where text = 'Me diz o nome de três coisas que param no ar. Beija-flor, helicóptero e Dadá Maravilha.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Não existe gol feio, feio é não fazer gol.', 'pt', null, 'Filosofia de centroavante de Dadá, repetida até hoje por jogadores e técnicos.', 'entrevista', 'https://www.terra.com.br/esportes/lance/romario-eurico-edmundo-tulio-vampeta-felipe-melo-relembre-frases-marcantes-nos-ultimos-anos,af8bf1a097e7ea1f9660165867aaa9bemtgcaa2v.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Frase folclórica do futebol · Obs.: O texto varia entre as fontes.'
from people where slug = 'dada-maravilha'
  and not exists (select 1 from quotes where text = 'Não existe gol feio, feio é não fazer gol.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Só existe três poderes no universo: Deus no céu, o Papa no Vaticano e Dadá na grande área.', 'pt', null, 'Mais uma das frases de Dadá sobre ele mesmo.', 'entrevista', 'https://www.terra.com.br/esportes/lance/romario-eurico-edmundo-tulio-vampeta-felipe-melo-relembre-frases-marcantes-nos-ultimos-anos,af8bf1a097e7ea1f9660165867aaa9bemtgcaa2v.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Frase folclórica do futebol'
from people where slug = 'dada-maravilha'
  and not exists (select 1 from quotes where text = 'Só existe três poderes no universo: Deus no céu, o Papa no Vaticano e Dadá na grande área.');
-- vicente-matheus
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'O Sócrates é inegociável, invendável e imprestável', 'pt', null, 'Do presidente corintiano, recusando propostas pelo Doutor Sócrates. Era para dizer que o craque não podia ser emprestado.', 'entrevista', 'https://www.terra.com.br/esportes/lance/20-anos-de-saudades-relembre-as-melhores-frases-de-vicente-matheus,790b6e14bd455e27d74affe355e25ee7g5ic2nen.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Pérola de cartola · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'vicente-matheus'
  and not exists (select 1 from quotes where text = 'O Sócrates é inegociável, invendável e imprestável');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Haja o que hajar, o Corinthians vai ser campeão', 'pt', null, 'Outra das frases folclóricas do presidente corintiano.', 'entrevista', 'https://www.terra.com.br/esportes/lance/20-anos-de-saudades-relembre-as-melhores-frases-de-vicente-matheus,790b6e14bd455e27d74affe355e25ee7g5ic2nen.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Pérola de cartola'
from people where slug = 'vicente-matheus'
  and not exists (select 1 from quotes where text = 'Haja o que hajar, o Corinthians vai ser campeão');
-- muricy-ramalho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Aqui é trabalho, meu filho', 'pt', null, 'Surgiu numa resposta a um repórter depois de um jogo e virou jargão da torcida do São Paulo. Até Renato Gaúcho adotou.', 'entrevista', 'https://www.correiobraziliense.com.br/esportes/2025/04/7103707-bom-tecnico-nao-importa-o-pais-diz-muricy-ramalho.html', null, 1, 'iconica', 'draft', 'Fonte: Correio Braziliense · Por que: Bordão de técnico · Obs.: A busca citou a origem do bordão; confira se está nesta matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'muricy-ramalho'
  and not exists (select 1 from quotes where text = 'Aqui é trabalho, meu filho');
-- adriano-imperador
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Morde as costas', 'pt', null, 'Bordão que Adriano diz ter herdado de Zelão, amigo do pai dele. Virou meme e mote do podcast dele.', 'video', 'https://www.terra.com.br/esportes/adriano-imperador-explica-origem-de-bordoes-na-internet-apertei-sem-querer,f8818f722c008355e585bca15a3c9c2cgfplllg8.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão do Imperador · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'adriano-imperador'
  and not exists (select 1 from quotes where text = 'Morde as costas');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Habib és', 'pt', null, 'Nasceu de um erro de digitação: ele queria escrever "rs" e o corretor trocou por "és". "Habib" vem da passagem dele pela Arábia.', 'post', 'https://www.terra.com.br/esportes/adriano-imperador-explica-origem-de-bordoes-na-internet-apertei-sem-querer,f8818f722c008355e585bca15a3c9c2cgfplllg8.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão do Imperador'
from people where slug = 'adriano-imperador'
  and not exists (select 1 from quotes where text = 'Habib és');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Nem cavalo aguenta', 'pt', null, 'Outro bordão que Adriano diz ter ouvido de Zelão, amigo do pai dele, quando era criança.', 'video', 'https://www.terra.com.br/esportes/adriano-imperador-explica-origem-de-bordoes-na-internet-apertei-sem-querer,f8818f722c008355e585bca15a3c9c2cgfplllg8.html', null, 3, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão do Imperador'
from people where slug = 'adriano-imperador'
  and not exists (select 1 from quotes where text = 'Nem cavalo aguenta');
-- neymar
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'O pai tá on', 'pt', '2020-08-12', 'Comemorando a classificação do PSG para a semifinal da Champions. Virou bordão e ganhou música de MC Kekel dias depois.', 'post', 'https://www.metropoles.com/entretenimento/musica/thiaguinho-mt-e-dany-bala-lancam-o-pai-ta-on-musica-inspirada-em-neymar', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão que virou funk · Obs.: Data aproximada (agosto de 2020). As matérias não dizem quem criou a expressão, só que Neymar a popularizou.'
from people where slug = 'neymar'
  and not exists (select 1 from quotes where text = 'O pai tá on');
-- romario
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'O que eu posso falar para a torcida do Vasco é que, quando tiver Vasco x Flamengo, levem lenços para o Maracanã', 'pt', '1995-01-01', 'Provocação de Romário quando chegou ao Flamengo, em 1995.', 'entrevista', 'https://www.terra.com.br/esportes/lance/romario-eurico-edmundo-tulio-vampeta-felipe-melo-relembre-frases-marcantes-nos-ultimos-anos,af8bf1a097e7ea1f9660165867aaa9bemtgcaa2v.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Provocação de clássico · Obs.: Data aproximada (1995).'
from people where slug = 'romario'
  and not exists (select 1 from quotes where text = 'O que eu posso falar para a torcida do Vasco é que, quando tiver Vasco x Flamengo, levem lenços para o Maracanã');
-- eurico-miranda
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Leão sem juba é miau', 'pt', null, 'Alfinetada do cartola vascaíno no técnico Emerson Leão.', 'entrevista', 'https://www.terra.com.br/esportes/lance/perolas-relembre-as-polemicas-frases-de-eurico-miranda-no-vasco,66d8cce3316f00c8d532423b26c16e08bs46bj4b.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Pérola de cartola · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'eurico-miranda'
  and not exists (select 1 from quotes where text = 'Leão sem juba é miau');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Todo mundo é baba-ovo do Guardiola', 'pt', null, 'Na apresentação do técnico Cristóvão Borges no Vasco.', 'entrevista', 'https://www.terra.com.br/esportes/lance/perolas-relembre-as-polemicas-frases-de-eurico-miranda-no-vasco,66d8cce3316f00c8d532423b26c16e08bs46bj4b.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Pérola de cartola'
from people where slug = 'eurico-miranda'
  and not exists (select 1 from quotes where text = 'Todo mundo é baba-ovo do Guardiola');
-- felipe-melo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Caldeirão é lá no chiqueiro', 'pt', null, 'Provocação ao Santos quando jogava no Palmeiras, dizendo que nunca tinha visto caldeirão com 5 ou 8 mil torcedores na Vila Belmiro.', 'entrevista', 'https://www.terra.com.br/esportes/lance/as-10-frases-mais-ousadas-de-felipe-melo-pelo-palmeiras,12af71558e1644a3119f91b58394f94aykfeh4o0.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Provocação ao rival · Obs.: Data não confirmada (época de Palmeiras, 2017 a 2020). Talvez sirva como polêmica.'
from people where slug = 'felipe-melo'
  and not exists (select 1 from quotes where text = 'Caldeirão é lá no chiqueiro');
-- eurico-miranda
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Futebol não pode ser apitado por veado', 'pt', null, 'Em entrevista a uma rádio, contra o fair-play e contra a presença de mulheres e gays no esporte.', 'entrevista', 'https://www.terra.com.br/esportes/vasco/eurico-rechaca-fair-play-no-futebol-e-diz-nao-pode-ser-apitado-por-veado,dcc80dbf07eec63c1f3b02dee2ebc1b0scucRCRD.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Homofobia de cartola · Obs.: Texto é a manchete do Terra; confira a fala completa e a data.'
from people where slug = 'eurico-miranda'
  and not exists (select 1 from quotes where text = 'Futebol não pode ser apitado por veado');
-- abel-braga
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu não quero o meu time treinando com uma camisa rosa, porque parece um time de veado', 'pt', '2025-11-30', 'Na apresentação como técnico do Internacional, sobre o uniforme de treino. A imprensa internacional repercutiu, e o STJD o puniu com cinco jogos de suspensão e multa de R$ 20 mil.', 'entrevista', 'https://www.metropoles.com/esportes/relembre-fala-homofobica-de-abel-braga-condenado-pelo-stjd', null, 1, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Fala homofóbica que virou punição no STJD · Obs.: Há versões com palavrão ("Eu não quero a porra do meu time treinando de camisa rosa, parece time de viado"); confira. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'abel-braga'
  and not exists (select 1 from quotes where text = 'Eu não quero o meu time treinando com uma camisa rosa, porque parece um time de veado');

commit;
