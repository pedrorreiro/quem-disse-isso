-- Carga 12: Internet, para chegar a pelo menos 20 frases por tipo (icônicas e polêmicas).
-- Fontes: CNN Brasil, Metrópoles, Terra e Correio Braziliense.
-- O agente não conseguiu abrir as matérias (o ambiente bloqueia os sites); os textos vêm dos trechos que a busca
-- devolveu. Por isso o review_note pede para conferir a frase na matéria antes de aprovar.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove em /admin → Fotos). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Maria Berklian', 'maria-berklian', 'internet', 'internet', 'f', 'BR', 'A "Rainha do Brasil", idosa que viralizou no TikTok achando tudo barato nos shoppings'),
  ('Cariúcha', 'cariucha', 'internet', 'internet', 'f', 'BR', 'Influenciadora e apresentadora, ex-A Fazenda'),
  ('Maíra Cardi', 'maira-cardi', 'internet', 'internet', 'f', 'BR', 'Influenciadora de emagrecimento, casada com Thiago Nigro'),
  ('Val Marchiori', 'val-marchiori', 'internet', 'internet', 'f', 'BR', 'Socialite, estrela do reality Mulheres Ricas'),
  ('Nego Di', 'nego-di', 'internet', 'internet', 'm', 'BR', 'Humorista gaúcho, ex-BBB 21'),
  ('Deolane Bezerra', 'deolane-bezerra', 'internet', 'internet', 'f', 'BR', 'Advogada e influenciadora, ex-A Fazenda'),
  ('Antonia Fontenelle', 'antonia-fontenelle', 'internet', 'internet', 'f', 'BR', 'Atriz e youtuber, viúva do diretor Marcos Paulo'),
  ('Bianca Andrade', 'bianca-andrade', 'internet', 'internet', 'f', 'BR', 'A Boca Rosa, influenciadora de beleza e ex-BBB 20')
on conflict (slug) do nothing;

-- ines-brasil
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Segura esse forninho', 'pt', null, 'Um dos bordões de Inês Brasil que viralizaram depois do vídeo de inscrição para o BBB.', 'video', 'https://www.terra.com.br/diversao/tv/blog-sala-de-tv/ines-brasil-vibra-ao-se-ver-na-tv-linda-e-bela-na-globo,dc50fb7b22658437727baf0b41d83031m54ritie.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão que virou meme · Obs.: A busca juntou matérias do Terra sobre ela; confira se esta cita o bordão.'
from people where slug = 'ines-brasil'
  and not exists (select 1 from quotes where text = 'Segura esse forninho');
-- narcisa-tamborindeguy
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Dont touch, its art', 'pt', null, 'Um dos bordões de Narcisa que viralizam nas redes. Virou até nome de batom da linha de maquiagem dela.', 'video', 'https://www.cnnbrasil.com.br/lifestyle/ai-que-loucura-narcisa-ganha-batons-inspirados-em-bordoes-classicos/', null, 2, 'iconica', 'draft', 'Fonte: CNN Brasil · Por que: Bordão clássico'
from people where slug = 'narcisa-tamborindeguy'
  and not exists (select 1 from quotes where text = 'Dont touch, its art');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Ai, que vista!', 'pt', null, 'Usado por Narcisa para celebrar a mudança para um apartamento de frente para a praia, em Ipanema.', 'video', 'https://www.metropoles.com/vida-e-estilo/narcisa-deixa-copacabana-e-se-muda-para-imovel-de-r-48-milhoes', null, 3, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão da socialite'
from people where slug = 'narcisa-tamborindeguy'
  and not exists (select 1 from quotes where text = 'Ai, que vista!');
-- gretchen
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu sou o evento', 'pt', null, 'Um dos memes favoritos da própria Gretchen, que virou estampa de camiseta da coleção dela.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/gretchen-faz-65-anos-relembre-os-melhores-memes-da-artista/', null, 2, 'iconica', 'draft', 'Fonte: CNN Brasil · Por que: Meme da Rainha dos Memes'
from people where slug = 'gretchen'
  and not exists (select 1 from quotes where text = 'Eu sou o evento');
-- maria-berklian
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Tá barato!', 'pt', null, 'A reação dela a cada produto de luxo que os vendedores mostravam nos shoppings de São Paulo, em vídeos gravados pelo neto no TikTok.', 'video', 'https://www.cnnbrasil.com.br/nacional/sudeste/sp/morre-maria-berklian-influenciadora-conhecida-pelo-meme-ta-barato/', null, 1, 'iconica', 'draft', 'Fonte: CNN Brasil · Por que: O meme da milionária · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'maria-berklian'
  and not exists (select 1 from quotes where text = 'Tá barato!');
-- cariucha
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu sou toda natural, bonita pra caramba', 'pt', null, 'Dito a Caco Barcellos no Profissão Repórter, antes da fama. Virou meme.', 'video', 'https://www.metropoles.com/colunas/fabia-oliveira/apos-a-fazenda-15-cariucha-se-consagra-como-icone-dos-memes', null, 2, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Frase que a fez virar meme · Obs.: Confira se esta matéria cita a frase (a busca a trouxe numa lista de memes). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'cariucha'
  and not exists (select 1 from quotes where text = 'Eu sou toda natural, bonita pra caramba');
-- jojo-todynho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Denise, sai da live', 'pt', null, 'Trecho de uma live antiga que foi resgatado em março de 2025 e virou o jeito de "expulsar" alguém de uma conversa.', 'video', 'https://www.cnnbrasil.com.br/pop/marisa-maio-e-mais-relembre-os-memes-que-marcaram-2025/', null, 1, 'iconica', 'draft', 'Fonte: CNN Brasil · Por que: Meme de 2025'
from people where slug = 'jojo-todynho'
  and not exists (select 1 from quotes where text = 'Denise, sai da live');
-- maira-cardi
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Se quiserem me chamar de terrorista alimentar por conta disso, de doida, de o que quer que seja, pode chamar.', 'pt', '2026-07-01', 'Depois de contar que jogou no lixo o refrigerante que veio no delivery do marido, Thiago Nigro.', 'post', 'https://www.correiobraziliense.com.br/colunistas/mariana-morais/2026/07/7458150-maira-cardi-joga-delivery-do-marido-no-lixo-na-minha-casa-nao.html', null, 2, 'iconica', 'draft', 'Fonte: Correio Braziliense · Por que: A saga do refrigerante do Primo Rico · Obs.: Data aproximada (julho de 2026). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'maira-cardi'
  and not exists (select 1 from quotes where text = 'Se quiserem me chamar de terrorista alimentar por conta disso, de doida, de o que quer que seja, pode chamar.');
-- val-marchiori
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Hello, eu sou rica, meu bem!', 'pt', null, 'Bordão de Val Marchiori no reality Mulheres Ricas, da Band, quase sempre seguido de uma gargalhada.', 'video', 'https://www.terra.com.br/diversao/tv/val-marchiori-produz-nova-temporada-do-reality-show-mulheres-ricas,bd8108f461ca17fe2b1a859b35e125b2zyn7lxp1.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão do Mulheres Ricas · Obs.: A busca atribuiu a frase ao Metrópoles; confira a fonte. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'val-marchiori'
  and not exists (select 1 from quotes where text = 'Hello, eu sou rica, meu bem!');
-- bianca-andrade
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Posso falar como convidada?', 'pt', '2018-01-01', 'No Pânico, depois de ser interrompida várias vezes por Emílio Surita numa discussão sobre privilégios de gênero. Foi parar nos assuntos mais comentados do Twitter.', 'video', 'https://www.metropoles.com/entretenimento/televisao/apos-interrupcoes-boca-rosa-corta-apresentador-do-panico-posso-falar', null, 2, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Cortou o apresentador ao vivo · Obs.: Data aproximada (2018). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'bianca-andrade'
  and not exists (select 1 from quotes where text = 'Posso falar como convidada?');
-- maira-cardi
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Ué, mas Maceió só tem ele, amor! Não tem nada em Maceió!', 'pt', '2025-11-01', 'No carro, a caminho de Maceió com Thiago Nigro, falando de Carlinhos Maia. A cidade reagiu e ela pediu desculpas.', 'video', 'https://www.terra.com.br/diversao/gente/maira-cardi-causa-polemica-ao-debochar-de-maceio-e-recebe-critica-da-web,80bcf9279cb48b91a2e6d787a2453796pi9ew1he.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Desprezou Maceió · Obs.: O Metrópoles traz "Uai, Maceió só tem ele, amor. Não tem nada em Maceió". Data aproximada (novembro de 2025).'
from people where slug = 'maira-cardi'
  and not exists (select 1 from quotes where text = 'Ué, mas Maceió só tem ele, amor! Não tem nada em Maceió!');
-- val-marchiori
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Sou alta, loira e linda. Sorry para as gordas', 'pt', '2013-02-01', 'Em entrevista no Carnaval de Salvador, quando era estrela do Mulheres Ricas. A frase continuava: "para as aspirantes a ser famosa".', 'entrevista', 'https://www.terra.com.br/diversao/carnaval/salvador/val-marchiori-sou-alta-loira-e-linda-sorry-para-as-gordas,c1b6a2383bccc310VgnVCM4000009bcceb0aRCRD.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Gordofobia sem disfarce · Obs.: Data aproximada (Carnaval de 2013).'
from people where slug = 'val-marchiori'
  and not exists (select 1 from quotes where text = 'Sou alta, loira e linda. Sorry para as gordas');
-- nego-di
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Velha sem vergonha', 'pt', '2020-01-01', 'Em vídeo no YouTube, sobre a deputada Luciana Genro (PSOL). Foi condenado por difamação e injúria e teve de prestar serviços à comunidade.', 'video', 'https://www.terra.com.br/nos/nego-di-e-condenado-por-difamacao-e-injuria-contra-deputada-velha-sem-vergonha,39fee4b9ba93f56354a1a55bdfc04630eep10u0d.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Ofensa a deputada que virou condenação · Obs.: Data aproximada (vídeo de 2020). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'nego-di'
  and not exists (select 1 from quotes where text = 'Velha sem vergonha');
-- deolane-bezerra
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'É inacreditável o tanto de pessoas comemorando as mortes', 'pt', '2025-10-29', 'Sobre os mortos na megaoperação policial no Rio. A postagem viralizou e dividiu opiniões.', 'post', 'https://tvprime.correiobraziliense.com.br/noticia/341824/celebridades/o-polemico-comentario-de-deolane-bezerra-sobre-os-mortos-em-megaoperacao-no-rio-29102025', null, 3, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: Criticou quem comemorou as mortes da megaoperação · Obs.: Fonte é o TV Prime, do Correio. Avalie se a repercussão basta para ser polêmica. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'deolane-bezerra'
  and not exists (select 1 from quotes where text = 'É inacreditável o tanto de pessoas comemorando as mortes');
-- antonia-fontenelle
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Triste saber que existem mulher como você, dona Giselle Itié. Volta pro teu país, é o melhor que tu faz', 'pt', '2022-01-01', 'Em vídeo, depois que a atriz Giselle Itié, que é mexicana, relatou assédio do diretor Marcos Paulo, ex-marido de Fontenelle. Ela foi condenada a pagar R$ 50 mil por danos morais, e a juíza viu xenofobia.', 'video', 'https://www.terra.com.br/diversao/gente/antonia-fontenelle-e-condenada-a-pagar-r-50-mil-a-giselle-itie,a8f8f3f621b0e8f01257e438995f6ae55aoyojjz.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Xenofobia que virou condenação · Obs.: A matéria escreve "Volta pro teu país". Data do vídeo não confirmada: confira. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'antonia-fontenelle'
  and not exists (select 1 from quotes where text = 'Triste saber que existem mulher como você, dona Giselle Itié. Volta pro teu país, é o melhor que tu faz');
-- virginia-fonseca
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Que pegada foi essa', 'pt', '2026-05-17', 'Legenda do vídeo em Dubai em que ela dá um selinho num macaco, dias depois do fim do namoro com Vini Jr. Foi acusada de incitar racismo contra o jogador e pediu desculpas.', 'post', 'https://www.metropoles.com/colunas/lucas-pasin/entenda-a-polemica-de-racismo-com-virginia-apos-termino-com-vini-jr', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Vídeo com macaco após o término com Vini Jr. · Obs.: Data aproximada (maio de 2026; o pedido de desculpas foi em 20/05).'
from people where slug = 'virginia-fonseca'
  and not exists (select 1 from quotes where text = 'Que pegada foi essa');

commit;
