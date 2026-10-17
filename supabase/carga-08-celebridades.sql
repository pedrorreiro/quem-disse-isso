-- Carga 8: mais Celebridades (category gringos), só polêmicas (kind 'polemica'), como o Pedro pediu.
-- Fontes: CNN Brasil, Metrópoles, Terra e Exame.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove em /admin → Fotos). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Will Smith', 'will-smith', 'gringos', 'cinema', 'm', 'US', 'Ator americano, vencedor do Oscar de melhor ator em 2022'),
  ('Chris Rock', 'chris-rock', 'gringos', 'cinema', 'm', 'US', 'Comediante e ator americano'),
  ('J.K. Rowling', 'jk-rowling', 'gringos', 'cinema', 'f', 'GB', 'Escritora britânica, autora de Harry Potter'),
  ('Ryan Lochte', 'ryan-lochte', 'gringos', 'esportes', 'm', 'US', 'Nadador americano, seis vezes campeão olímpico'),
  ('Ricky Gervais', 'ricky-gervais', 'gringos', 'tv', 'm', 'GB', 'Comediante britânico, apresentador do Globo de Ouro'),
  ('Doja Cat', 'doja-cat', 'gringos', 'musica', 'f', 'US', 'Cantora e rapper americana'),
  ('Rachel Zegler', 'rachel-zegler', 'gringos', 'cinema', 'f', 'US', 'Atriz americana, a Branca de Neve do live-action da Disney')
on conflict (slug) do nothing;

-- will-smith
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Mantenha o nome da minha esposa longe da p*rra da sua boca!', 'pt', '2022-03-27', 'Gritado da plateia do Oscar 2022, logo depois de subir ao palco e dar um tapa em Chris Rock pela piada sobre a cabeça raspada de Jada Pinkett Smith. Ele foi banido dos eventos da Academia por dez anos.', 'video', 'https://www.metropoles.com/colunas/pipocando/denzel-washington-acalma-will-smith-apos-tapa-em-chris-rock', null, 1, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: O tapa mais famoso da história do Oscar · Obs.: Texto conferido na matéria (ele gritou duas vezes). A CNN Brasil traz "fora de sua boca", sem o palavrão. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'will-smith'
  and not exists (select 1 from quotes where text = 'Mantenha o nome da minha esposa longe da p*rra da sua boca!');
-- chris-rock
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Jada, eu te amo. ''G.I. Jane 2'', mal posso esperar para ver', 'pt', '2022-03-27', 'Piada do apresentador sobre a cabeça raspada de Jada Pinkett Smith, que tem alopecia, no Oscar 2022. Segundos depois, Will Smith subiu ao palco e deu um tapa nele.', 'video', 'https://www.terra.com.br/nos/pinkett-smith-fala-da-vergonha-pela-perda-de-cabelo-e-do-tapa-no-oscar,7ed328b57af6dff3ee34873b419afceeqt8qmj8g.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: A piada que causou o tapa · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'chris-rock'
  and not exists (select 1 from quotes where text = 'Jada, eu te amo. ''G.I. Jane 2'', mal posso esperar para ver');
-- jk-rowling
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, '''Pessoas que menstruam''. Tenho certeza que costumava haver uma palavra para essas pessoas. Alguém me ajude?', 'pt', '2020-06-06', 'Tuíte da autora de Harry Potter ironizando um artigo que usava a expressão. Ela foi acusada de transfobia, e Daniel Radcliffe, Emma Watson e Rupert Grint a criticaram em público.', 'post', 'https://www.cnnbrasil.com.br/pop/autora-de-harry-potter-jk-rowling-e-criticada-por-comunidade-lgbt-apos-tuite/', null, 2, 'polemica', 'draft', 'Fonte: CNN Brasil · Por que: Início da briga dela com a comunidade trans · Obs.: Texto conferido na matéria (tradução da Reuters). O tuíte continuava com os trocadilhos "Wumben? Wimpund? Woomud?". Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'jk-rowling'
  and not exists (select 1 from quotes where text = '''Pessoas que menstruam''. Tenho certeza que costumava haver uma palavra para essas pessoas. Alguém me ajude?');
-- ryan-lochte
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'O homem sacou a arma e apontou para a minha cabeça dizendo: deita', 'pt', null, 'Relato do nadador sobre um suposto assalto no Rio, na Olimpíada de 2016. Vídeos mostraram que os atletas tinham depredado o banheiro de um posto. A polícia concluiu que ele mentiu, e ele foi suspenso da natação.', 'entrevista', 'https://exame.com/brasil/video-mostra-nadadores-em-posto-e-desmente-versao-de-assalto/', null, 2, 'polemica', 'draft', 'Fonte: Exame · Por que: Mentira que virou escândalo internacional na Rio 2016 · Obs.: Texto conferido na matéria (18/08/2016). Relato dado em agosto de 2016; o processo foi arquivado depois (Terra). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'ryan-lochte'
  and not exists (select 1 from quotes where text = 'O homem sacou a arma e apontou para a minha cabeça dizendo: deita');
-- ricky-gervais
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Então, se você vencer, não use este lugar para fazer um discurso político. Apenas receba seu pequeno prêmio, agradeça ao seu agente e saia fora.', 'pt', '2020-01-05', 'Na abertura do Globo de Ouro de 2020, para a plateia de astros de Hollywood. O monólogo cheio de alfinetadas dividiu a plateia e a imprensa.', 'discurso', 'https://www.terra.com.br/diversao/tv/as-frases-mais-polemicas-de-ricky-gervais-no-globo-de-ouro,f1dd53857d6955362bc5c2b4a92395120qp0u8m9.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Esculacho em Hollywood ao vivo · Obs.: Texto conferido na matéria ("As frases mais polêmicas de Ricky Gervais"). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'ricky-gervais'
  and not exists (select 1 from quotes where text = 'Então, se você vencer, não use este lugar para fazer um discurso político. Apenas receba seu pequeno prêmio, agradeça ao seu agente e saia fora.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Vocês não sabem nada sobre o mundo real e a maioria de vocês passou menos tempo na escola do que a Greta Thunberg.', 'pt', '2020-01-05', 'Também na abertura do Globo de Ouro de 2020, falando para os atores e atrizes na plateia.', 'discurso', 'https://www.terra.com.br/diversao/tv/as-frases-mais-polemicas-de-ricky-gervais-no-globo-de-ouro,f1dd53857d6955362bc5c2b4a92395120qp0u8m9.html', null, 3, 'polemica', 'draft', 'Fonte: Terra · Por que: Ofensa direta à plateia · Obs.: Texto conferido na matéria.'
from people where slug = 'ricky-gervais'
  and not exists (select 1 from quotes where text = 'Vocês não sabem nada sobre o mundo real e a maioria de vocês passou menos tempo na escola do que a Greta Thunberg.');
-- doja-cat
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Se você se chama de ''gatinho'', significa que você precisa desligar o telefone, arrumar um emprego e ajudar seus pais em casa', 'pt', null, 'Resposta da cantora no Threads, em julho de 2023, aos fãs que se chamavam de "kittenz". Também disse que não amava os fãs porque nem os conhecia, e perdeu mais de 200 mil seguidores no Instagram.', 'post', 'https://www.metropoles.com/entretenimento/musica/doja-cat-causa-revolta-na-web-apos-criticar-fas-arrumem-emprego', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Cantora mandando os próprios fãs arrumarem emprego · Obs.: Texto conferido na matéria (23/07/2023). Perda de seguidores segundo o Terra. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'doja-cat'
  and not exists (select 1 from quotes where text = 'Se você se chama de ''gatinho'', significa que você precisa desligar o telefone, arrumar um emprego e ajudar seus pais em casa');
-- rachel-zegler
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Ela não será salva pelo príncipe e não estará sonhando com o amor verdadeiro', 'pt', null, 'Sobre a sua Branca de Neve, em entrevista à Variety na D23 Expo de 2022. A fala gerou uma onda de críticas, e o live-action fracassou nas bilheterias em 2025.', 'entrevista', 'https://www.metropoles.com/entretenimento/cinema/rachel-zegler-causa-polemica-apos-homenagear-branca-de-neve-original', null, 3, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Mudar a princesa clássica virou guerra cultural · Obs.: Texto conferido na matéria (19/03/2025). Fracasso de bilheteria também no Metrópoles (04/04/2025). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'rachel-zegler'
  and not exists (select 1 from quotes where text = 'Ela não será salva pelo príncipe e não estará sonhando com o amor verdadeiro');
-- kanye-west
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu enxergo coisas boas sobre Hitler também.', 'pt', '2022-12-01', 'Em entrevista ao vivo ao conspiracionista Alex Jones. Até Jones discordou; no dia seguinte, o rapper postou uma suástica e teve a conta no Twitter suspensa.', 'entrevista', 'https://www.terra.com.br/diversao/gente/kanye-west-elogia-hitler-posta-suastica-e-e-suspenso-do-twitter,10b2159b71655e9d152a6a3c355b071dyvk82r4d.html', null, 1, 'polemica', 'draft', 'Fonte: Terra · Por que: Elogio a Hitler ao vivo · Obs.: Texto conferido na matéria.'
from people where slug = 'kanye-west'
  and not exists (select 1 from quotes where text = 'Eu enxergo coisas boas sobre Hitler também.');
-- elon-musk
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Vergonha, Alexandre. Vergonha.', 'pt', '2024-04-07', 'Fim do post no X em que atacou o ministro Alexandre de Moraes, do STF, dizendo que ele deveria renunciar ou sofrer impeachment. Moraes o incluiu no inquérito das milícias digitais.', 'post', 'https://www.cnnbrasil.com.br/politica/musk-pede-renuncia-ou-impeachment-de-moraes-e-diz-que-ministro-traiu-a-constituicao/', null, 1, 'polemica', 'draft', 'Fonte: CNN Brasil · Por que: Dono do X peitando o STF · Obs.: Texto conferido na matéria. Inclusão no inquérito segundo o Poder360.'
from people where slug = 'elon-musk'
  and not exists (select 1 from quotes where text = 'Vergonha, Alexandre. Vergonha.');

commit;
