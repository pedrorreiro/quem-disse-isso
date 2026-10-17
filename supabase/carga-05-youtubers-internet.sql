-- Carga 5: mais Youtubers e famosos da internet (10 frases). Só falas que deram polêmica de verdade, conferidas em veículos
-- grandes (CNN Brasil, Terra, Metrópoles, Correio Braziliense). Tudo entra como RASCUNHO: nada fica jogável até você aprovar
-- em /admin → Fila de revisão. Pessoas novas entram sem foto (aprove em /admin → Fotos).
-- Rode depois da carga 4. Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Nego Di', 'nego-di', 'internet', 'internet', 'm', 'BR', 'Humorista e influenciador gaúcho, ex-BBB 21'),
  ('Soso Careca', 'soso-careca', 'internet', 'internet', 'f', 'BR', 'Tiktoker de vídeos de humor'),
  ('Moskitão', 'moskitao', 'internet', 'internet', 'm', 'BR', 'Influenciador de vídeos gravados na rua'),
  ('Bettina Rudolph', 'bettina', 'internet', 'internet', 'f', 'BR', 'Garota-propaganda da Empiricus que virou meme em 2019')
on conflict (slug) do nothing;

-- felipe-neto
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Agora com a tigrinha na cobertura, sem chance.', 'pt', '2026-05-22', 'Post anunciando que não ia assistir à Copa de 2026 na Globo depois que a emissora escalou Virginia Fonseca, que fez propaganda do Jogo do Tigrinho, para a cobertura.', 'post', 'https://www.terra.com.br/diversao/tv/felipe-neto-declara-boicote-a-globo-na-copa-do-mundo-2026-por-causa-de-virginia-e-ataca-ex-de-vini-jr-tigrinha,ae599a145bde07a2728f118f8fa1647b1ttpt2c8.html', null, 2, 'draft', 'Fonte: Terra · Por que: Boicote público à Globo na Copa e ataque direto a Virginia · Obs.: Texto conferido na matéria.'
from people where slug = 'felipe-neto'
  and not exists (select 1 from quotes where text = 'Agora com a tigrinha na cobertura, sem chance.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'É absurdo que não se possa chamar um político de ''excrementíssimo''.', 'pt', '2025-06-04', 'Post no X depois que a Justiça do DF manteve a condenação a pagar R$ 20 mil a Arthur Lira, presidente da Câmara, que ele tinha chamado de ''excrementíssimo'' em 2024. Disse que ia recorrer ao STF.', 'post', 'https://www.terra.com.br/noticias/brasil/politica/justica-mantem-condenacao-de-felipe-neto-por-chamar-lira-de-excrementissimo-e-youtuber-vai-ao-stf,363c8b5ce46f32ed8904212e4b1fecba781uw693.html', null, 2, 'draft', 'Fonte: Terra · Por que: Condenado por xingar o presidente da Câmara, dobrou a aposta · Obs.: Texto conferido na matéria.'
from people where slug = 'felipe-neto'
  and not exists (select 1 from quotes where text = 'É absurdo que não se possa chamar um político de ''excrementíssimo''.');

-- felipe-castanhari
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não caiam nesse discursinho de merda do Marcius Melhem. Esse cara é um criminoso, um escroto, um assediador que merece cadeia por todo o sofrimento que causou', 'pt', '2020-12-05', 'Tuíte sobre o humorista Marcius Melhem, acusado de assédio por atrizes da Globo. A Justiça mandou apagar o post e condenou o youtuber a pagar indenização a Melhem.', 'post', 'https://www.terra.com.br/diversao/gente/justica-determina-que-felipe-castanhari-apague-ofensa-contra-marcius-melhem,a13edbbaaed694bc89ff3b501e8485a9rjchcima.html', null, 2, 'draft', 'Fonte: Terra · Por que: Ataque a Melhem que virou processo e ordem judicial para apagar · Obs.: Texto conferido na matéria. O nome de Melhem na frase entrega o caso, mas não o autor.'
from people where slug = 'felipe-castanhari'
  and not exists (select 1 from quotes where text = 'Não caiam nesse discursinho de merda do Marcius Melhem. Esse cara é um criminoso, um escroto, um assediador que merece cadeia por todo o sofrimento que causou');

-- virginia-fonseca
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não estou fazendo nada fora da lei. Se realmente faz tão mal para a população, então proíbe tudo.', 'pt', '2025-05-13', 'Depoimento à CPI das Bets no Senado, ao ser questionada sobre a propaganda que fazia de casas de apostas para milhões de seguidores.', 'discurso', 'https://www.terra.com.br/diversao/gente/4-falas-polemicas-da-virginia-fonseca-na-cpi-das-apostas,2b1cd40077eba730f1660789bb3d9613b83ybfh6.html', null, 2, 'draft', 'Fonte: Terra · Por que: Na CPI, jogou a responsabilidade das bets para o governo · Obs.: Texto conferido na matéria (a matéria usa ''[...]'' entre as duas frases). Também na CNN: https://www.cnnbrasil.com.br/politica/saiba-o-que-disse-virginia-a-cpi-das-bets/'
from people where slug = 'virginia-fonseca'
  and not exists (select 1 from quotes where text = 'Não estou fazendo nada fora da lei. Se realmente faz tão mal para a população, então proíbe tudo.');

-- jojo-todynho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Como você quer me chamar de opressora se quer oprimir a minha opinião?', 'pt', '2024-09-17', 'Resposta nas redes à deputada Erika Hilton, que a chamou de ''traidora'' depois que ela declarou voto em Alexandre Ramagem, candidato bolsonarista à Prefeitura do Rio.', 'post', 'https://www.terra.com.br/noticias/brasil/politica/jojo-todynho-entra-na-politica-como-preta-de-direita-promete-apagar-clipe-e-e-criticada-entenda,557c4676624c04080d9e4430a538e4e6r7a94hkd.html', null, 2, 'draft', 'Fonte: Terra · Por que: Briga pública com Erika Hilton na virada de Jojo para a direita · Obs.: Texto conferido na matéria. Data aproximada: a matéria é de 18/09/2024 e não dá o dia exato do post.'
from people where slug = 'jojo-todynho'
  and not exists (select 1 from quotes where text = 'Como você quer me chamar de opressora se quer oprimir a minha opinião?');

-- karol-conka
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Aí as pessoas dizem: é o jeito, porque na terra dessa pessoa é normal falar assim.', 'pt', '2021-01-29', 'No BBB 21, falando de Juliette com Thais e Sarah, e completando que era de Curitiba, ''uma cidade muito reservadinha''. Foi acusada de xenofobia contra a paraibana e o festival Rec-Beat cogitou cortá-la da programação.', 'video', 'https://www.correiobraziliense.com.br/diversao-e-arte/2021/02/4903963-apos-polemica-no-bbb21-karol-conka-podera-ser-cortada-de-festival-rec-beat.html', null, 2, 'draft', 'Fonte: Correio Braziliense · Por que: Fala xenofóbica sobre Juliette que começou a maior rejeição da história do BBB · Obs.: Texto conferido na matéria.'
from people where slug = 'karol-conka'
  and not exists (select 1 from quotes where text = 'Aí as pessoas dizem: é o jeito, porque na terra dessa pessoa é normal falar assim.');

-- nego-di
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Que revolução você faz defendendo vagabundo?', 'pt', '2021-02-02', 'No BBB 21, respondendo a Lucas Penteado, que tinha liderado ocupações de escolas por estudantes secundaristas em 2015 e 2016. Movimentos estudantis repudiaram a fala.', 'video', 'https://www.correiobraziliense.com.br/euestudante/cultura/2021/02/4904435-comunidade-estudantil-se-manifesta-apos-fala-de-nego-di-no-bbb.html', null, 2, 'draft', 'Fonte: Correio Braziliense · Por que: Chamou estudantes que ocuparam escolas de vagabundos em rede nacional · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'nego-di'
  and not exists (select 1 from quotes where text = 'Que revolução você faz defendendo vagabundo?');

-- soso-careca
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu estou ganhando mais dinheiro que você, que é CLT', 'pt', '2026-09-15', 'Em vídeo no TikTok, respondendo a quem dizia que fazer vídeo na internet não é trabalho. Depois da repercussão disse que não queria ofender todos os CLTs, ''só aqueles específicos''.', 'video', 'https://www.metropoles.com/celebridades/tiktoker-soso-careca-polemiza-apos-dizer-que-ganha-mais-que-clts-entenda', null, 3, 'draft', 'Fonte: Metrópoles · Por que: Debochou de quem trabalha de carteira assinada · Obs.: Texto conferido na matéria. Data da publicação; o vídeo é de dias antes. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'soso-careca'
  and not exists (select 1 from quotes where text = 'Eu estou ganhando mais dinheiro que você, que é CLT');

-- moskitao
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Imagine te ver pelada, eu vou brochar', 'pt', null, 'Em vídeo gravado na rua, falando para uma mulher desconhecida. Ela o processou e, em 2025, a Justiça de São Paulo condenou o influenciador a indenizá-la por humilhação.', 'video', 'https://www.cnnbrasil.com.br/nacional/sudeste/sp/influenciador-moskitao-e-condenado-por-humilhar-mulher-em-video/', null, 3, 'draft', 'Fonte: CNN Brasil · Por que: Humilhação de uma desconhecida para viralizar, que terminou em condenação · Obs.: Texto conferido na matéria (lá está em minúsculas). Sem data exata do vídeo; condenação noticiada em 20/08/2025. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'moskitao'
  and not exists (select 1 from quotes where text = 'Imagine te ver pelada, eu vou brochar');

-- bettina
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Oi. Meu nome é Bettina, eu tenho 22 anos e 1 milhão e 42 mil reais de patrimônio acumulado.', 'pt', '2019-03-20', 'Abertura do anúncio da Empiricus que aparecia antes de vídeos no YouTube, apresentando a jovem como milionária por investir. Virou meme, funk e alvo de críticas por propaganda enganosa.', 'video', 'https://www.correiobraziliense.com.br/app/noticia/diversao-e-arte/2019/03/20/interna_diversao_arte,744203/bettina-a-milionaria-da-bolsa-vira-tema-de-funk-apos-propaganda-pole.shtml', null, 1, 'draft', 'Fonte: Correio Braziliense · Por que: O anúncio mais zoado da internet brasileira · Obs.: Texto conferido na matéria. O nome na frase entrega a autora: dificuldade 1 de propósito. Data da matéria; o anúncio é de dias antes. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'bettina'
  and not exists (select 1 from quotes where text = 'Oi. Meu nome é Bettina, eu tenho 22 anos e 1 milhão e 42 mil reais de patrimônio acumulado.');

commit;
