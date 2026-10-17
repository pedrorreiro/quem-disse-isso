-- Carga 7: mais Reality Show (BBB 13 a BBB 26 e A Fazenda). Mesmo critério da carga 6: humor, bordões e memes que o
-- público lembra, não polêmicas. Fontes: CNN Brasil, Metrópoles, Terra, A Tarde e DCI.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove em /admin → Fotos). Rode depois da carga 6. Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Rafa Kalimann', 'rafa-kalimann', 'reality', 'reality', 'f', 'BR', 'Influenciadora e apresentadora, vice-campeã do BBB 20'),
  ('Flayslane', 'flay', 'reality', 'reality', 'f', 'BR', 'Cantora, participante do BBB 20'),
  ('Aline Mattos', 'aline-mattos', 'reality', 'reality', 'f', 'BR', 'Primeira eliminada do BBB 13'),
  ('Diogo Almeida', 'diogo-almeida', 'reality', 'reality', 'm', 'BR', 'Ator, participante do BBB 25'),
  ('Renata Saldanha', 'renata-saldanha', 'reality', 'reality', 'f', 'BR', 'Bailarina, campeã do BBB 25'),
  ('João Gabriel Castro', 'joao-gabriel-castro', 'reality', 'reality', 'm', 'BR', 'Um dos gêmeos do BBB 25'),
  ('Aline Patriarca', 'aline-patriarca', 'reality', 'reality', 'f', 'BR', 'Policial militar baiana, participante do BBB 25'),
  ('Chaiany Andrade', 'chaiany-andrade', 'reality', 'reality', 'f', 'BR', 'Participante do BBB 26'),
  ('Babu Santana', 'babu-santana', 'reality', 'reality', 'm', 'BR', 'Ator, participante do BBB 20 e do BBB 26'),
  ('Milena Moreira', 'milena-moreira', 'reality', 'reality', 'f', 'BR', 'Finalista do BBB 26'),
  ('Juliano Floss', 'juliano-floss', 'reality', 'reality', 'm', 'BR', 'Dançarino e tiktoker, finalista do BBB 26'),
  ('Nadja Pessoa', 'nadja-pessoa', 'reality', 'reality', 'f', 'BR', 'Influenciadora, expulsa de A Fazenda 10 (2018)')
on conflict (slug) do nothing;

-- rafa-kalimann
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não gosto de você. Não sinto verdade em você. Acho você, sim, incoerente.', 'pt', null, 'Começo do discurso para Flay no BBB 20. Os fãs decoraram a briga palavra por palavra e ela terminou com "extremamente soberba".', 'video', 'https://www.metropoles.com/colunas/leo-dias/bbb21-chegando-relembre-memes-iconicos-de-outras-temporadas-do-reality', null, 1, 'draft', 'Fonte: Metrópoles · Por que: Discurso que o público sabe de cor · Obs.: Texto conferido na matéria. Também no Terra. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'rafa-kalimann'
  and not exists (select 1 from quotes where text = 'Não gosto de você. Não sinto verdade em você. Acho você, sim, incoerente.');
-- flay
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Olha, eu não gosto de ignorância, viu, Victor Hugo', 'pt', null, 'No almoço do VIP do BBB 20, em 2020, para o psicólogo Victor Hugo.', 'video', 'https://www.terra.com.br/diversao/gente/relembre-os-bordoes-e-frases-que-fizeram-muito-sucesso-no-bbb,de481ad4ac1ebc037a1a8d4fef92e980d6aw1hub.html', null, 2, 'draft', 'Fonte: Terra · Por que: Bronca que virou meme do BBB 20 · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'flay'
  and not exists (select 1 from quotes where text = 'Olha, eu não gosto de ignorância, viu, Victor Hugo');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Vamos, galera, mulheres!', 'pt', null, 'No BBB 20, chamando as mulheres da casa para confrontar os homens depois que descobriram o que eles falavam delas.', 'video', 'https://atarde.com.br/bbb/10-frases-iconicas-do-bbb-que-viraram-parte-do-nosso-vocabulario-1314920', null, 2, 'draft', 'Fonte: A Tarde · Por que: Grito de guerra do BBB 20 · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'flay'
  and not exists (select 1 from quotes where text = 'Vamos, galera, mulheres!');
-- aline-mattos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Meu corpo é ''brindado'', sua praga não pega', 'pt', null, 'Bordão da primeira eliminada do BBB 13, em 2013, que trocava "blindado" por "brindado".', 'video', 'https://www.metropoles.com/colunas/leo-dias/bbb21-chegando-relembre-memes-iconicos-de-outras-temporadas-do-reality', null, 2, 'draft', 'Fonte: Metrópoles · Por que: Erro de português que virou bordão · Obs.: Texto conferido na matéria. A CNN cita o bordão dela como "meu corpo é um templo". Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'aline-mattos'
  and not exists (select 1 from quotes where text = 'Meu corpo é ''brindado'', sua praga não pega');
-- fernanda-bande
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Houve um destempero', 'pt', '2024-02-01', 'Contando a Giovanna Pitel, já calma, como tinha sido a briga com Alane no BBB 24, um dia depois do "Chora, bonequinha!".', 'video', 'https://www.cnnbrasil.com.br/pop/bbb/e-o-brasil-do-brasil-relembre-frases-iconicas-do-bbb24/', null, 2, 'draft', 'Fonte: CNN Brasil · Por que: O eufemismo do ano depois do barraco · Obs.: Texto conferido na matéria.'
from people where slug = 'fernanda-bande'
  and not exists (select 1 from quotes where text = 'Houve um destempero');
-- diogo-almeida
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Vamos fazer um sarau?', 'pt', null, 'Repetida várias vezes no BBB 25 pelo ator, que queria paz e união na casa enquanto o público queria briga. Até Tadeu Schmidt brincou com o bordão.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/bbb25-quais-foram-os-bordoes-e-frases-marcantes-da-edicao/', null, 1, 'draft', 'Fonte: CNN Brasil · Por que: Bordão paz e amor que virou piada · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'diogo-almeida'
  and not exists (select 1 from quotes where text = 'Vamos fazer um sarau?');
-- renata-saldanha
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A surucucu voltou', 'pt', null, 'Entrando nos quartos ao voltar da Vitrine do Seu Fifi no BBB 25, em março de 2025, rebatendo o apelido que Aline tinha dado a ela. Depois ganhou o programa.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/bbb25-quais-foram-os-bordoes-e-frases-marcantes-da-edicao/', null, 1, 'draft', 'Fonte: CNN Brasil · Por que: Volta triunfal debochada · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'renata-saldanha'
  and not exists (select 1 from quotes where text = 'A surucucu voltou');
-- joao-gabriel-castro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Cê é burro, jumento!', 'pt', null, 'No BBB 25, em fevereiro de 2025, xingando o irmão gêmeo João Pedro, que quebrou o congelamento da dinâmica do freeze para abraçar Gracyanne Barbosa.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/bbb25-quais-foram-os-bordoes-e-frases-marcantes-da-edicao/', null, 2, 'draft', 'Fonte: CNN Brasil · Por que: Bronca de irmão em rede nacional · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'joao-gabriel-castro'
  and not exists (select 1 from quotes where text = 'Cê é burro, jumento!');
-- aline-patriarca
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Berimbau é o cacete, rapaz', 'pt', null, 'Discussão com João Gabriel no intervalo do Sincerão do BBB 25. Ela entendeu "berimbau" quando ele disse "menino bão", e ele acabou ganhando um miniberimbau da produção.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/bbb25-quais-foram-os-bordoes-e-frases-marcantes-da-edicao/', null, 2, 'draft', 'Fonte: CNN Brasil · Por que: Mal-entendido que virou meme · Obs.: Texto como na CNN Brasil (em outra matéria da CNN está censurado: "c*****"). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'aline-patriarca'
  and not exists (select 1 from quotes where text = 'Berimbau é o cacete, rapaz');
-- chaiany-andrade
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu voto é… Brigerton? É Brigerton?', 'pt', '2026-01-18', 'Na votação do primeiro Paredão do BBB 26, tentando votar em Brígido. A Netflix entrou na brincadeira e Tadeu Schmidt citou a série quando ele foi eliminado.', 'video', 'https://www.metropoles.com/entretenimento/televisao/bridgerton-netflix-reage-apos-chaiany-errar-nome-de-brigido-no-bbb-26', null, 1, 'draft', 'Fonte: Metrópoles · Por que: O voto mais atrapalhado do BBB 26 · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'chaiany-andrade'
  and not exists (select 1 from quotes where text = 'Eu voto é… Brigerton? É Brigerton?');
-- babu-santana
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Vamos, tesouro. Não se misture com essa gentalha', 'pt', '2026-02-03', 'Para Juliano Floss, numa discussão com Jonas Sulzbach no BBB 26, imitando a Dona Florinda de Chaves.', 'video', 'https://www.terra.com.br/diversao/tv/reality-shows/os-maiores-memes-do-bbb-26-que-conquistaram-a-internet,f6d079d833edd85d27ca5a49bf4d724dih9i7qhg.html', null, 2, 'draft', 'Fonte: Terra · Por que: Referência a Chaves no meio da treta · Obs.: Texto conferido na matéria. Data do tuíte citado. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'babu-santana'
  and not exists (select 1 from quotes where text = 'Vamos, tesouro. Não se misture com essa gentalha');
-- milena-moreira
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Amanhã vai ter uma terceira', 'pt', null, 'No BBB 26, como recreadora, acordou a casa pela segunda vez e respondeu assim quando Sol Vega reclamou. A casa virou um caos.', 'video', 'https://www.terra.com.br/diversao/tv/reality-shows/os-maiores-memes-do-bbb-26-que-conquistaram-a-internet,f6d079d833edd85d27ca5a49bf4d724dih9i7qhg.html', null, 2, 'draft', 'Fonte: Terra · Por que: Resposta debochada que virou meme · Obs.: Texto conferido na matéria. Sem data exata do episódio. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'milena-moreira'
  and not exists (select 1 from quotes where text = 'Amanhã vai ter uma terceira');
-- juliano-floss
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Tá com ciúmes, playboy?', 'pt', '2026-02-03', 'Resposta a Jonas Sulzbach, que tinha provocado ele e Babu com "Vai lá, papai e filhinho" no BBB 26.', 'video', 'https://www.terra.com.br/diversao/tv/reality-shows/os-maiores-memes-do-bbb-26-que-conquistaram-a-internet,f6d079d833edd85d27ca5a49bf4d724dih9i7qhg.html', null, 2, 'draft', 'Fonte: Terra · Por que: Troca de provocações que viralizou · Obs.: Texto conferido na matéria. Data do tuíte citado. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'juliano-floss'
  and not exists (select 1 from quotes where text = 'Tá com ciúmes, playboy?');
-- jojo-todynho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Tá num SPA? E é isso aí mesmo. Acabou', 'pt', null, 'Em A Fazenda 12, em 2020, cobrando Lucas Cartolouco, que não ajudava nas tarefas da sede. Ela venceu a edição.', 'video', 'https://www.cnnbrasil.com.br/pop/realities/a-fazenda-top-10-momentos-que-marcaram-o-reality-rural/', null, 1, 'draft', 'Fonte: CNN Brasil · Por que: O meme mais famoso de A Fazenda · Obs.: Texto conferido na matéria. Jojo continua na categoria Internet.'
from people where slug = 'jojo-todynho'
  and not exists (select 1 from quotes where text = 'Tá num SPA? E é isso aí mesmo. Acabou');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu preciso ir na polícia, roubaram o meu cabelo.', 'pt', null, 'Na primeira festa de A Fazenda 12, em 2020, depois de beber demais: ela usava peruca.', 'video', 'https://www.dci.com.br/dci-mais/a-fazenda-2020/a-fazenda-2020-ta-no-spa-veja-10-frases-memoraveis-jojo-no-reality/33674/', null, 2, 'draft', 'Fonte: DCI · Por que: Desespero de festa que virou meme · Obs.: Texto conferido na matéria. Jojo continua na categoria Internet.'
from people where slug = 'jojo-todynho'
  and not exists (select 1 from quotes where text = 'Eu preciso ir na polícia, roubaram o meu cabelo.');
-- nadja-pessoa
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu tenho pedigree', 'pt', null, 'Na briga com Caique Aguiar em A Fazenda 10, em 2018, que não queria tirar os pés da cama dela. Ela chutou a perna dele e foi expulsa.', 'video', 'https://www.cnnbrasil.com.br/pop/realities/a-fazenda-top-10-momentos-que-marcaram-o-reality-rural/', null, 2, 'draft', 'Fonte: CNN Brasil · Por que: Frase esnobe de uma das maiores brigas de A Fazenda · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'nadja-pessoa'
  and not exists (select 1 from quotes where text = 'Eu tenho pedigree');

-- Reality é sempre icônica (coluna kind, migração 20261027000000_tipo_frase).
update quotes q set kind = 'iconica' from people p where p.id = q.person_id and p.category = 'reality' and q.kind <> 'iconica';

commit;
