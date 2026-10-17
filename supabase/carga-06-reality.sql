-- Carga 6: categoria Reality Show (BBB e A Fazenda). Aqui o critério é outro: humor. Bordões, memes e frases
-- engraçadas que o público lembra, não polêmicas. Fontes: CNN Brasil, Metrópoles, Correio Braziliense, Terra, DCI e listas de memes.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove em /admin → Fotos). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Ex-BBBs que já estavam em Internet e são conhecidos pelo reality passam para a categoria nova.
update people set category = 'reality', area = 'reality' where slug in ('karol-conka', 'nego-di', 'gil-do-vigor');

-- Bordões do Gil que tinham sido recusados pelo critério de polêmica voltam para a fila.
update quotes q set status = 'draft',
       review_note = 'Fonte: Diário do Nordeste / CNN Brasil · Por que: bordão icônico do BBB 21 · Obs.: Reaberta para a categoria Reality Show.'
  from people p
 where p.id = q.person_id and p.slug = 'gil-do-vigor' and q.status = 'rejected'
   and q.text in ('O Brasil tá lascado', 'Ai, Brasil!');

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Theo Becker', 'theo-becker', 'reality', 'reality', 'm', 'BR', 'Ator, participante de A Fazenda 1 (2009)'),
  ('Lu Schievano', 'lu-schievano', 'reality', 'reality', 'f', 'BR', 'Modelo, participante de A Fazenda 6 (2013)'),
  ('Andressa Urach', 'andressa-urach', 'reality', 'reality', 'f', 'BR', 'Modelo e ex-Miss Bumbum, participante de A Fazenda 6 (2013)'),
  ('Denise Rocha', 'denise-rocha', 'reality', 'reality', 'f', 'BR', 'Ex-assessora parlamentar apelidada de Furacão da CPI, participante de A Fazenda 6'),
  ('Nicole Bahls', 'nicole-bahls', 'reality', 'reality', 'f', 'BR', 'Modelo e apresentadora, participante de A Fazenda 5 e 9'),
  ('Rico Melquiades', 'rico-melquiades', 'reality', 'reality', 'm', 'BR', 'Humorista, campeão de A Fazenda 13 (2021)'),
  ('Fani Pacheco', 'fani-pacheco', 'reality', 'reality', 'f', 'BR', 'Modelo, participante do BBB 7'),
  ('Lia Khey', 'lia-khey', 'reality', 'reality', 'f', 'BR', 'Participante do BBB 10'),
  ('Ana Paula Renault', 'ana-paula-renault', 'reality', 'reality', 'f', 'BR', 'Jornalista, participante do BBB 16'),
  ('Manu Gavassi', 'manu-gavassi', 'reality', 'reality', 'f', 'BR', 'Cantora e atriz, participante do BBB 20'),
  ('Jéssica Mueller', 'jessica-mueller', 'reality', 'reality', 'f', 'BR', 'Participante do BBB 18'),
  ('Gleici Damasceno', 'gleici-damasceno', 'reality', 'reality', 'f', 'BR', 'Campeã do BBB 18'),
  ('Davi Brito', 'davi-brito', 'reality', 'reality', 'm', 'BR', 'Campeão do BBB 24'),
  ('Fernanda Bande', 'fernanda-bande', 'reality', 'reality', 'f', 'BR', 'Confeiteira, participante do BBB 24'),
  ('Beatriz Reis', 'beatriz-reis', 'reality', 'reality', 'f', 'BR', 'Vendedora do Brás, participante do BBB 24'),
  ('Rodolffo', 'rodolffo', 'reality', 'reality', 'm', 'BR', 'Cantor sertanejo da dupla Israel & Rodolffo, participante do BBB 21')
on conflict (slug) do nothing;

-- theo-becker
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Esse é irmão desse, e esse aqui é irmão desse aqui', 'pt', null, 'Em A Fazenda 1, em 2009, durante uma briga com Jonathan Haagensen por causa do tempo que ele ficava no banheiro. Ameaçou partir para a agressão batendo nos próprios bíceps.', 'video', 'https://dci.com.br/dci-mais/a-fazenda-2020/a-fazenda-tiktokers-dublam-frases-iconicas-de-thayse-teixeira-nadja-theo-becker-e-mais-veja/12935/amp', null, 1, 'draft', 'Fonte: DCI · Por que: Uma das frases mais lembradas da história de A Fazenda · Obs.: Texto conferido na matéria. Também em Ric e ND+ ("Esse é irmão desse!"). Sem data exata da cena. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'theo-becker'
  and not exists (select 1 from quotes where text = 'Esse é irmão desse, e esse aqui é irmão desse aqui');
-- lu-schievano
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Amiga, assim não dá pra te defender', 'pt', null, 'Em A Fazenda 6, em 2013, depois de ver Andressa Urach nua na piscina da sede. Virou bordão entre quem acompanhou a edição.', 'video', 'https://www.dci.com.br/a-fazenda/a-fazenda-com-andressa-urach-relembre-a-participacao-iconica/163762/', null, 2, 'draft', 'Fonte: DCI · Por que: Bordão que virou meme de A Fazenda 6 · Obs.: Texto conferido na matéria. Sem data exata da cena. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'lu-schievano'
  and not exists (select 1 from quotes where text = 'Amiga, assim não dá pra te defender');
-- andressa-urach
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Olha, Britto, sinceramente, por mim poderiam sair as duas, né?', 'pt', null, 'Na formação da roça em A Fazenda 6, em 2013, respondendo ao apresentador Britto Jr. quem queria ver eliminada: Bárbara Evans ou Denise Rocha.', 'video', 'https://ric.com.br/entretenimento/a-fazenda-melhores-memes-do-reality/', null, 2, 'draft', 'Fonte: Ric · Por que: O "Olha, Britto, sinceramente" é um dos memes mais usados do reality · Obs.: Texto como a matéria transcreve o tuíte com a fala. Também em ND+. Sem data exata da cena. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'andressa-urach'
  and not exists (select 1 from quotes where text = 'Olha, Britto, sinceramente, por mim poderiam sair as duas, né?');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Bom dia, dona furacão da CPI', 'pt', null, 'Resposta ao "Bom dia, gatinha Miss Bumbum" de Denise Rocha, rival em A Fazenda 6, em 2013. As duas recriaram a cena num vídeo em 2021.', 'video', 'https://www.metropoles.com/colunas/pipocando/andressa-urach-e-denise-rocha-recriam-momento-historico-de-a-fazenda', null, 2, 'draft', 'Fonte: Metrópoles · Por que: Troca de farpas mais famosa de A Fazenda 6 · Obs.: Texto conferido na matéria (é a fala da recriação de 2021, igual à original). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'andressa-urach'
  and not exists (select 1 from quotes where text = 'Bom dia, dona furacão da CPI');
-- denise-rocha
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Bom dia, gatinha Miss Bumbum', 'pt', null, 'Bom dia para a rival Andressa Urach em A Fazenda 6, em 2013, que respondeu "Bom dia, dona furacão da CPI". As duas recriaram a cena num vídeo em 2021.', 'video', 'https://www.metropoles.com/colunas/pipocando/andressa-urach-e-denise-rocha-recriam-momento-historico-de-a-fazenda', null, 2, 'draft', 'Fonte: Metrópoles · Por que: Troca de farpas mais famosa de A Fazenda 6 · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'denise-rocha'
  and not exists (select 1 from quotes where text = 'Bom dia, gatinha Miss Bumbum');
-- nicole-bahls
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, '8 horas pra fazer um arroz e fritar um peixe? Isso não existe!', 'pt', null, 'Reclamando da demora do almoço em A Fazenda 5, em 2012. Virou um dos memes mais usados do reality e até o MasterChef Brasil brincou com a frase.', 'video', 'https://www.tiktok.com/@masterchefbr/video/7382966677937442053', null, 1, 'draft', 'Fonte: TikTok (MasterChef Brasil) · Por que: Meme que você pediu, um dos mais famosos do reality · Obs.: ATENÇÃO: não achei a frase em veículo grande, só em vídeos do TikTok (o tempo varia: 2 ou 8 horas). Temporada também incerta (5 ou 6). Confira antes de aprovar. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'nicole-bahls'
  and not exists (select 1 from quotes where text = '8 horas pra fazer um arroz e fritar um peixe? Isso não existe!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu acho que tem mulher bonita que é inteligente, não é o meu caso.', 'pt', '2012-06-23', 'Conversa com os peões em A Fazenda 5, na mesma semana em que inventou palavras como "confletir" e "estrategístico".', 'video', 'https://www.terra.com.br/diversao/tv/a-fazenda/frases-de-nicole-bahls-divertem-peoes-em-a-fazenda,9e59237de142b310VgnCLD200000bbcceb0aRCRD.html', null, 2, 'draft', 'Fonte: Terra · Por que: Autocrítica que virou piada nacional · Obs.: Texto conferido na matéria. Data da publicação. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'nicole-bahls'
  and not exists (select 1 from quotes where text = 'Eu acho que tem mulher bonita que é inteligente, não é o meu caso.');
-- rico-melquiades
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Calada vence!', 'pt', null, 'Gritando pela sede ao voltar salvo da última roça de A Fazenda 13, em dezembro de 2021, garantindo vaga na final. Ganhou o programa dias depois.', 'video', 'https://ric.com.br/entretenimento/a-fazenda-melhores-memes-do-reality/', null, 2, 'draft', 'Fonte: Ric · Por que: Bordão de comemoração que virou meme · Obs.: Texto conferido na matéria. Sem data exata (dezembro de 2021). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'rico-melquiades'
  and not exists (select 1 from quotes where text = 'Calada vence!');
-- fani-pacheco
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Uhu, Nova Iguaçu!', 'pt', null, 'Grito do BBB 7, em 2007, para comemorar cada vitória no jogo, homenageando a cidade natal.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/uhu-nova-iguacu-olha-ela-e-mais-os-melhores-bordoes-do-bbb/', null, 1, 'draft', 'Fonte: CNN Brasil · Por que: Um dos bordões clássicos do BBB · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'fani-pacheco'
  and not exists (select 1 from quotes where text = 'Uhu, Nova Iguaçu!');
-- lia-khey
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O Brasil tá vendo!', 'pt', null, 'Bordão do BBB 10, em 2010, para avisar os colegas que o país acompanhava fofocas e combinados de voto. Virou a frase mais repetida da história do programa.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/uhu-nova-iguacu-olha-ela-e-mais-os-melhores-bordoes-do-bbb/', null, 2, 'draft', 'Fonte: CNN Brasil · Por que: Bordão que todo participante repete até hoje · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'lia-khey'
  and not exists (select 1 from quotes where text = 'O Brasil tá vendo!');
-- ana-paula-renault
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Olha ela!', 'pt', null, 'Gritado no BBB 16, ao voltar de um paredão falso e entrar no quarto do líder onde dormia a rival Juliana.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/uhu-nova-iguacu-olha-ela-e-mais-os-melhores-bordoes-do-bbb/', null, 1, 'draft', 'Fonte: CNN Brasil · Por que: Volta do paredão falso mais lembrada do BBB · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'ana-paula-renault'
  and not exists (select 1 from quotes where text = 'Olha ela!');
-- manu-gavassi
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Surtos leves e tênis', 'pt', null, 'Versão criada no BBB 20 para o "roupas leves e tênis" que o apresentador Tiago Leifert usava ao anunciar provas.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/uhu-nova-iguacu-olha-ela-e-mais-os-melhores-bordoes-do-bbb/', null, 1, 'draft', 'Fonte: CNN Brasil · Por que: Bordão que virou expressão do dia a dia · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'manu-gavassi'
  and not exists (select 1 from quotes where text = 'Surtos leves e tênis');
-- jessica-mueller
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Levanta a cabeça, princesa, senão a coroa cai', 'pt', null, 'Conselho a Patrícia no BBB 18. Era para ser motivacional e virou meme; ao sair, ela ganhou uma coroa de Ana Maria Braga.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/uhu-nova-iguacu-olha-ela-e-mais-os-melhores-bordoes-do-bbb/', null, 1, 'draft', 'Fonte: CNN Brasil · Por que: Uma das frases mais usadas da internet brasileira · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'jessica-mueller'
  and not exists (select 1 from quotes where text = 'Levanta a cabeça, princesa, senão a coroa cai');
-- gleici-damasceno
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Vocês não imaginam o prazer que é estar de volta', 'pt', null, 'Ao voltar de um paredão falso no BBB 18, que depois venceu. A fala imitava a personagem Clara, da novela O Outro Lado do Paraíso.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/uhu-nova-iguacu-olha-ela-e-mais-os-melhores-bordoes-do-bbb/', null, 2, 'draft', 'Fonte: CNN Brasil · Por que: Volta triunfal que virou meme · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'gleici-damasceno'
  and not exists (select 1 from quotes where text = 'Vocês não imaginam o prazer que é estar de volta');
-- davi-brito
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Calma, calabreso!', 'pt', '2024-01-31', 'Numa discussão com Lucas Buda e MC Bin Laden na festa do BBB 24. A gíria, do humorista Toninho Tornado, virou nome do fã-clube e o próprio Tadeu Schmidt abriu um programa com "Boa noite, meus calabresos".', 'video', 'https://www.correiobraziliense.com.br/diversao-e-arte/2024/02/6796236-bbb-24-toninho-tornado-explica-meme-calma-calabreso-usado-por-davi.html', null, 1, 'draft', 'Fonte: Correio Braziliense · Por que: Gíria que dominou o BBB 24 · Obs.: Texto conferido na matéria ("calma calabreso"). Também na CNN Brasil e A Tarde. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'davi-brito'
  and not exists (select 1 from quotes where text = 'Calma, calabreso!');
-- fernanda-bande
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Chora, bonequinha!', 'pt', '2024-01-31', 'Durante a briga com Alane no BBB 24, debochando do choro da bailarina. Virou trend no X e até fala de novela da Globo.', 'video', 'https://www.metropoles.com/entretenimento/bbb/chora-bonequinha-entenda-a-briga-de-fernanda-e-alane-no-bbb-24', null, 1, 'draft', 'Fonte: Metrópoles · Por que: Deboche que virou o meme do BBB 24 · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'fernanda-bande'
  and not exists (select 1 from quotes where text = 'Chora, bonequinha!');
-- beatriz-reis
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'É o Brasil do Brasil', 'pt', null, 'Bordão que a vendedora do Brás repetia o tempo todo no BBB 24.', 'video', 'https://atarde.com.br/bbb/10-frases-iconicas-do-bbb-que-viraram-parte-do-nosso-vocabulario-1314920', null, 1, 'draft', 'Fonte: A Tarde · Por que: Bordão mais repetido do BBB 24 · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'beatriz-reis'
  and not exists (select 1 from quotes where text = 'É o Brasil do Brasil');
-- karol-conka
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Qualquer coisa me coloca no Paredão. Eu tenho minha vida minha carreira bem bonita lá fora', 'pt', '2021-02-01', 'Na briga em que expulsou Lucas Penteado da mesa no BBB 21. Meses depois a frase virou meme em montagens no Twitter e ela mesma entrou na brincadeira.', 'video', 'https://www.metropoles.com/colunas/pipocando/o-twitter-ressuscitou-karol-conka-tudo-isso-por-conta-de-um-meme', null, 2, 'draft', 'Fonte: Metrópoles · Por que: Frase da vilã do BBB 21 que virou meme · Obs.: Texto conferido na matéria.'
from people where slug = 'karol-conka'
  and not exists (select 1 from quotes where text = 'Qualquer coisa me coloca no Paredão. Eu tenho minha vida minha carreira bem bonita lá fora');
-- rodolffo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Aliás, uma das criaturas que mais me fazem dar risada, é a criatura gay.', 'pt', null, 'Vídeo antigo que voltou a circular em fevereiro de 2021, quando ele estava no BBB 21. Queria mostrar que não tinha preconceito, mas foi acusado de homofobia por chamar gays de "criatura".', 'video', 'https://www.metropoles.com/entretenimento/bbb/bbb21-web-aponta-homofobia-em-video-contra-preconceito-feito-por-rodolffo', null, 2, 'draft', 'Fonte: Metrópoles · Por que: A tentativa de mostrar que não era preconceituoso que saiu pela culatra · Obs.: Texto conferido na matéria. O vídeo é de antes do BBB, sem data; viralizou em 01/02/2021. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'rodolffo'
  and not exists (select 1 from quotes where text = 'Aliás, uma das criaturas que mais me fazem dar risada, é a criatura gay.');

-- Reality é sempre icônica (coluna kind, migração 20261027000000_tipo_frase).
update quotes q set kind = 'iconica' from people p where p.id = q.person_id and p.category = 'reality' and q.kind <> 'iconica';

commit;
