-- Carga 9: TV, para chegar a pelo menos 20 frases por tipo (icônicas e polêmicas).
-- Fontes: Terra, Metrópoles, Correio Braziliense, CNN Brasil e Exame.
-- O agente não conseguiu abrir as matérias (o ambiente bloqueia os sites); os textos vêm dos trechos que a busca
-- devolveu. Por isso o review_note pede para conferir a frase na matéria antes de aprovar.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove em /admin → Fotos). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('William Waack', 'william-waack', 'tv', 'tv', 'm', 'BR', 'Jornalista e apresentador, ex-âncora do Jornal da Globo'),
  ('Rafinha Bastos', 'rafinha-bastos', 'tv', 'tv', 'm', 'BR', 'Humorista, ex-apresentador do CQC'),
  ('Boris Casoy', 'boris-casoy', 'tv', 'tv', 'm', 'BR', 'Jornalista e âncora de telejornal'),
  ('Sikêra Jr', 'sikera-jr', 'tv', 'tv', 'm', 'BR', 'Apresentador do Alerta Nacional, da RedeTV!'),
  ('Rachel Sheherazade', 'rachel-sheherazade', 'tv', 'tv', 'f', 'BR', 'Jornalista, ex-âncora do SBT Brasil'),
  ('Ratinho', 'ratinho', 'tv', 'tv', 'm', 'BR', 'Apresentador do Programa do Ratinho, no SBT'),
  ('Patrícia Abravanel', 'patricia-abravanel', 'tv', 'tv', 'f', 'BR', 'Apresentadora do SBT, filha de Silvio Santos'),
  ('Danilo Gentili', 'danilo-gentili', 'tv', 'tv', 'm', 'BR', 'Humorista, apresentador do The Noite, no SBT'),
  ('Chacrinha', 'chacrinha', 'tv', 'tv', 'm', 'BR', 'O Velho Guerreiro, apresentador de auditório que jogava bacalhau na plateia'),
  ('Jô Soares', 'jo-soares', 'tv', 'tv', 'm', 'BR', 'Humorista e apresentador de talk show'),
  ('Hebe Camargo', 'hebe-camargo', 'tv', 'tv', 'f', 'BR', 'A Rainha da TV brasileira, apresentadora de auditório'),
  ('Osmar Santos', 'osmar-santos', 'tv', 'tv', 'm', 'BR', 'Narrador esportivo de rádio e TV'),
  ('Sérgio Mallandro', 'sergio-mallandro', 'tv', 'tv', 'm', 'BR', 'Apresentador e humorista, rei das pegadinhas'),
  ('Marcelo Rezende', 'marcelo-rezende', 'tv', 'tv', 'm', 'BR', 'Jornalista, apresentador do Cidade Alerta, da Record')
on conflict (slug) do nothing;

-- william-waack
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'É preto. É coisa de preto.', 'pt', '2016-11-08', 'Dito em voz baixa, irritado com uma buzina, durante a cobertura da eleição americana em frente à Casa Branca. O vídeo vazou um ano depois, a Globo o afastou e encerrou o contrato em dezembro de 2017.', 'video', 'https://exame.com/carreira/globo-decide-demitir-william-waack-apos-polemica-racista/', null, 1, 'polemica', 'draft', 'Fonte: Exame · Por que: Fala racista que tirou o âncora da Globo · Obs.: Texto pelo trecho da busca; confira na matéria. Data: noite da eleição americana de 2016 (vídeo vazou em nov/2017). Waack chamou de "piada idiota" em artigo na Folha (Poder360). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'william-waack'
  and not exists (select 1 from quotes where text = 'É preto. É coisa de preto.');
-- rafinha-bastos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Comeria ela e o bebê', 'pt', '2011-09-19', 'Comentário no CQC, da Band, sobre Wanessa Camargo, que estava grávida. O humorista saiu do programa e foi condenado a indenizar a família da cantora.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/bbb/rafinha-bastos-faz-piada-com-expulsao-de-wanessa-camargo-dia-especial/', null, 1, 'polemica', 'draft', 'Fonte: CNN Brasil · Por que: Piada que custou o CQC e uma indenização · Obs.: Texto conferido no trecho da busca (CNN Brasil e Correio Braziliense). Data aproximada (setembro de 2011); confira. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'rafinha-bastos'
  and not exists (select 1 from quotes where text = 'Comeria ela e o bebê');
-- boris-casoy
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Dois lixeiros, o mais baixo da escala do trabalho', 'pt', '2009-12-31', 'Comentário que vazou no ar no Jornal da Band, logo depois de dois garis desejarem feliz ano novo. Ele pediu desculpas ao vivo no dia seguinte e foi processado.', 'video', 'https://www.terra.com.br/diversao/tv/off-de-boris-casoy-sobre-garis-deixa-band-em-saia-justa,8a40f001fdc7a310VgnCLD200000bbcceb0aRCRD.html', null, 1, 'polemica', 'draft', 'Fonte: Terra · Por que: Off que vazou ao vivo · Obs.: Texto pelo trecho da busca; o comentário começava com "que m...". Confira na matéria. Processo segundo o Correio Braziliense. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'boris-casoy'
  and not exists (select 1 from quotes where text = 'Dois lixeiros, o mais baixo da escala do trabalho');
-- sikera-jr
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'A gente tá calado, engolindo, engolindo essa raça desgraçada', 'pt', '2021-06-25', 'No Alerta Nacional, da RedeTV!, reagindo a um comercial do Burger King sobre famílias LGBT. Cerca de 90 empresas deixaram de patrocinar o programa, e ele foi condenado por homofobia.', 'video', 'https://www.terra.com.br/nos/sikera-jr-e-condenado-a-prisao-por-chamar-gays-de-raca-degracada-na-tv,14b7f45eac53b1391295ee14139dac61kus0yuc2.html', null, 1, 'polemica', 'draft', 'Fonte: Terra · Por que: Ofensa a gays ao vivo que derrubou os patrocínios · Obs.: Texto pelo trecho da busca; as matérias trazem versões um pouco diferentes. Confira. Perda de patrocínio no Correio Braziliense e Poder360. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'sikera-jr'
  and not exists (select 1 from quotes where text = 'A gente tá calado, engolindo, engolindo essa raça desgraçada');
-- rachel-sheherazade
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Faça um favor ao Brasil, adote um bandido', 'pt', '2014-02-06', 'No SBT Brasil, sobre o adolescente amarrado nu a um poste por "justiceiros" no Rio, falando para quem defendia o garoto. O MPF processou o SBT, e ela foi proibida de opinar no telejornal.', 'video', 'https://exame.com/brasil/mp-pede-retratacao-do-sbt-por-comentario-de-rachel-sheherazade/', null, 1, 'polemica', 'draft', 'Fonte: Exame · Por que: Defesa dos justiceiros no telejornal · Obs.: Texto pelo trecho da busca; confira na matéria. Data no Correio Braziliense (06/02/2014). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'rachel-sheherazade'
  and not exists (select 1 from quotes where text = 'Faça um favor ao Brasil, adote um bandido');
-- ratinho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Tinha que eliminar esses loucos. Não dá para pegar uma metralhadora, não?', 'pt', '2021-12-15', 'No rádio, sobre a deputada Natália Bonavides (PT-RN), autora de projeto que tirava "marido e mulher" do Código Civil. Também a chamou de "feia do capeta". Virou réu por violência política de gênero.', 'video', 'https://www.metropoles.com/sao-paulo/ratinho-vira-reu-eleitoral-por-fala-sobre-metralhar-deputada-do-rn', null, 1, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Apresentador sugerindo metralhar deputada · Obs.: Texto pelo trecho da busca; confira na matéria. Dito no programa de rádio dele. Foi absolvido no TRF-5 na ação civil (Metrópoles). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'ratinho'
  and not exists (select 1 from quotes where text = 'Tinha que eliminar esses loucos. Não dá para pegar uma metralhadora, não?');
-- xuxa
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Serviriam para alguma coisa antes de morrer', 'pt', '2021-03-26', 'Em live da Alerj sobre direitos dos animais, defendendo que presos condenados fossem cobaias de remédios e vacinas no lugar dos animais. Foi acusada de racismo e pediu desculpas em vídeo horas depois.', 'video', 'https://www.metropoles.com/brasil/xuxa-defende-que-presos-sejam-cobaias-em-testes-de-vacinas-e-remedios', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Rainha dos Baixinhos propondo presos como cobaias · Obs.: Trecho curto pelo resultado da busca; vale pegar a frase mais completa na matéria. Pedido de desculpas no Poder360 e Terra.'
from people where slug = 'xuxa'
  and not exists (select 1 from quotes where text = 'Serviriam para alguma coisa antes de morrer');
-- faustao
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Cabelo de vassoura de bruxa', 'pt', null, 'No Domingão do Faustão, sobre o cabelo black power da bailarina Arielle Macedo, durante a apresentação de Anitta. Foi acusado de racismo e chamou a polêmica de "palhaçada" ao vivo.', 'video', 'https://www.terra.com.br/diversao/tv/ao-vivo-faustao-rebate-acusacao-de-racismo-palhacada,5eed29c3825a5410VgnVCM3000009af154d0RCRD.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Comentário sobre cabelo de bailarina negra · Obs.: Data não encontrada (por volta de 2014). Texto pelo trecho da busca.'
from people where slug = 'faustao'
  and not exists (select 1 from quotes where text = 'Cabelo de vassoura de bruxa');
-- silvio-santos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu não sei o que é misógino, mas achei bem bonito.', 'pt', '2019-09-15', 'No Programa Silvio Santos, respondendo a uma reportagem da IstoÉ que o acusava de machismo e assédio no palco. Em seguida, ironizou e se declarou misógino.', 'video', 'https://www.metropoles.com/colunas/pipocando/silvio-santos-polemiza-nao-sei-o-que-e-misogino-mas-achei-bonito', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Resposta debochada à acusação de machismo · Obs.: Texto pelo trecho da busca (a manchete traz "achei bonito"; o corpo, "achei bem bonito"). A CNN Brasil traz outra versão: "Não sei o que quer dizer misógino, mas é um nome bonito. Eu sou misógino! Gostei".'
from people where slug = 'silvio-santos'
  and not exists (select 1 from quotes where text = 'Eu não sei o que é misógino, mas achei bem bonito.');
-- ana-maria-braga
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Morro de inveja, inveja boa, inveja branca de estar aí onde está', 'pt', '2021-09-22', 'No Mais Você, falando com um repórter que estava num campo de girassóis. A expressão "inveja branca" foi criticada como racista, e ela pediu desculpas no dia seguinte.', 'video', 'https://www.metropoles.com/entretenimento/televisao/ana-maria-usa-expressao-racista-no-mais-voce-inveja-boa-inveja-branca', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Expressão racista ao vivo na Globo · Obs.: Texto pelo trecho da busca ("algo como"); confira na matéria. Desculpas no Correio Braziliense (23/09/2021).'
from people where slug = 'ana-maria-braga'
  and not exists (select 1 from quotes where text = 'Morro de inveja, inveja boa, inveja branca de estar aí onde está');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'A gente fica com vontade de dar colo para esse menino gordo, né?', 'pt', '2024-04-01', 'No Mais Você, sobre Lucas Buda, do BBB 24. A fala foi considerada gordofóbica, e ela pediu desculpas ao vivo no dia seguinte.', 'video', 'https://www.metropoles.com/entretenimento/televisao/ana-maria-braga-chama-lucas-buda-de-menino-gordo-e-e-detonada', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Gordofobia com participante do BBB · Obs.: Texto pelo trecho da busca (Terra). Data aproximada (abril de 2024); confira.'
from people where slug = 'ana-maria-braga'
  and not exists (select 1 from quotes where text = 'A gente fica com vontade de dar colo para esse menino gordo, né?');
-- ratinho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Mulher para ser mulher tem que ter útero', 'pt', '2026-03-11', 'No Programa do Ratinho, sobre a eleição da deputada trans Erika Hilton para a Comissão da Mulher. Também disse "ela não é mulher, ela é trans". O MPF pediu R$ 10 milhões de indenização, e a Justiça mandou exibir direito de resposta.', 'video', 'https://www.correiobraziliense.com.br/brasil/2026/03/7374514-erika-hilton-aciona-mp-contra-ratinho-e-pede-rs-10-milhoes-de-indenizacao.html', null, 1, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: Transfobia contra deputada em rede nacional · Obs.: Texto pelo trecho da busca; confira. Ação do MPF na CNN Brasil e Metrópoles; direito de resposta no Poder360.'
from people where slug = 'ratinho'
  and not exists (select 1 from quotes where text = 'Mulher para ser mulher tem que ter útero');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Quando eu vejo dois homens se beijando, eu fico preocupado. Ele saiu do mercado e tirou mais um.', 'pt', '2026-05-06', 'No Programa do Ratinho, comentando um beijo entre dois homens. O SBT não comentou e, no mesmo dia, exibiu um casamento LGBT, o que aumentou a repercussão.', 'video', 'https://www.metropoles.com/entretenimento/televisao/ratinho-volta-a-causar-polemica-apos-fala-homofobica-em-programa-no-sbt', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Mais uma fala homofóbica no SBT · Obs.: Texto pelo trecho da busca (Correio Braziliense TV Prime); confira se o Metrópoles traz a mesma fala. Data aproximada (maio de 2026).'
from people where slug = 'ratinho'
  and not exists (select 1 from quotes where text = 'Quando eu vejo dois homens se beijando, eu fico preocupado. Ele saiu do mercado e tirou mais um.');
-- patricia-abravanel
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Mulher com mulher não é tão legal assim. Não tem aquele brinquedo que a gente gosta bastante.', 'pt', '2016-05-01', 'No Jogo dos Pontinhos, do Programa Silvio Santos, em que também disse não achar a homossexualidade "normal". Luana Piovani e o sobrinho Tiago Abravanel criticaram.', 'video', 'https://www.terra.com.br/diversao/tv/nao-e-normal-ha-quase-10-anos-fala-de-patricia-abravanel-na-tv-sobre-homossexualidade-revoltou-luana-piovani-e-tiago-abravanel,0fe03e79b4616cce1638deb46cbc97522dqmkun5.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Fala homofóbica que revoltou a própria família · Obs.: Texto pelo trecho da busca; confira. Data aproximada (maio de 2016). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'patricia-abravanel'
  and not exists (select 1 from quotes where text = 'Mulher com mulher não é tão legal assim. Não tem aquele brinquedo que a gente gosta bastante.');
-- danilo-gentili
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Quantas bananas você quer para deixar essa história pra lá?', 'pt', '2009-07-29', 'Resposta no Twitter a um seguidor negro que criticou uma piada dele comparando um jogador negro ao King Kong. O caso foi investigado pelo Ministério Público, e anos depois ele foi absolvido.', 'post', 'https://www.terra.com.br/diversao/gente/danilo-gentili-relembre-a-carreira-e-as-polemicas-do-humorista,019ef5b99da631b1f6d8c442deaf1369onoqvxnw.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Piada racista no Twitter · Obs.: Texto pelo trecho da busca ("Sério, vamos esquecer isso... Quantas bananas..."); confira. Data aproximada (julho de 2009, Correio Braziliense). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'danilo-gentili'
  and not exists (select 1 from quotes where text = 'Quantas bananas você quer para deixar essa história pra lá?');
-- galvao-bueno
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Sai que é sua, Taffarel!', 'pt', '1998-07-07', 'Narrando a semifinal da Copa de 1998 contra a Holanda, nos pênaltis. Taffarel defendeu e o Brasil foi à final.', 'video', 'https://www.terra.com.br/esportes/bordoes-em-copas-do-mundo-relembre-frases-marcantes-de-narradores,b806286d88c6e724a6c6c4f0c40388fepnqq5p7u.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão de Copa · Obs.: Texto pela busca ("sai, sai, sai que é sua, Taffarel").'
from people where slug = 'galvao-bueno'
  and not exists (select 1 from quotes where text = 'Sai que é sua, Taffarel!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Ayrton Senna do Brasil!', 'pt', null, 'O grito de Galvão a cada vitória de Senna na Fórmula 1, com o Tema da Vitória ao fundo.', 'video', 'https://www.terra.com.br/esportes/bordoes-em-copas-do-mundo-relembre-frases-marcantes-de-narradores,b806286d88c6e724a6c6c4f0c40388fepnqq5p7u.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão da Fórmula 1 · Obs.: Confira se esta matéria cita o bordão; a busca o trouxe numa lista de momentos de Galvão (CNN Brasil/Terra).'
from people where slug = 'galvao-bueno'
  and not exists (select 1 from quotes where text = 'Ayrton Senna do Brasil!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Virou passeio!', 'pt', '2014-07-08', 'Narrando o 7 a 1 da Alemanha sobre o Brasil, na semifinal da Copa de 2014.', 'video', 'https://www.terra.com.br/esportes/bordoes-em-copas-do-mundo-relembre-frases-marcantes-de-narradores,b806286d88c6e724a6c6c4f0c40388fepnqq5p7u.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Frase do 7 a 1 · Obs.: Texto pela busca. Confira na matéria.'
from people where slug = 'galvao-bueno'
  and not exists (select 1 from quotes where text = 'Virou passeio!');
-- silvio-santos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Vamos rodar o pião!', 'pt', null, 'Bordão do quadro Pião da Casa Própria, em que o pião decidia quem ganhava a casa.', 'video', 'https://www.metropoles.com/celebridades/quem-quer-dinheiro-e-mais-9-bordoes-marcantes-de-silvio-santos', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão clássico · Obs.: Texto pela busca (Terra e Metrópoles).'
from people where slug = 'silvio-santos'
  and not exists (select 1 from quotes where text = 'Vamos rodar o pião!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Está certo disso?', 'pt', null, 'Pergunta do Show do Milhão antes de o participante confirmar a resposta.', 'video', 'https://www.metropoles.com/celebridades/quem-quer-dinheiro-e-mais-9-bordoes-marcantes-de-silvio-santos', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão do Show do Milhão · Obs.: Texto pela busca (CNN Brasil cita junto "Quer pedir ajuda aos universitários?").'
from people where slug = 'silvio-santos'
  and not exists (select 1 from quotes where text = 'Está certo disso?');
-- jo-soares
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Beijo do gordo!', 'pt', null, 'A despedida de Jô Soares no fim de cada programa.', 'video', 'https://www.correiobraziliense.com.br/diversao-e-arte/2022/08/5027132-beijo-do-gordo-relembre-alguns-dos-famosos-bordoes-de-jo-soares.html', null, 1, 'iconica', 'draft', 'Fonte: Correio Braziliense · Por que: Despedida mais famosa da TV · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'jo-soares'
  and not exists (select 1 from quotes where text = 'Beijo do gordo!');
-- hebe-camargo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Que gracinha!', 'pt', null, 'Como Hebe tratava os convidados no sofá do programa.', 'video', 'https://www.terra.com.br/diversao/gente/hebe-comemora-80-anos-e-continua-uma-gracinha,f179e55c87a8a310VgnCLD200000bbcceb0aRCRD.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão da Rainha da TV · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'hebe-camargo'
  and not exists (select 1 from quotes where text = 'Que gracinha!');
-- chacrinha
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Quem não se comunica, se trumbica!', 'pt', null, 'Bordão do Velho Guerreiro nos programas de auditório, entre um bacalhau e outro jogado para a plateia.', 'video', 'https://www.correiobraziliense.com.br/app/noticia/diversao-e-arte/2017/09/30/interna_diversao_arte,630152/100-anos-de-chacrinha.shtml', null, 1, 'iconica', 'draft', 'Fonte: Correio Braziliense · Por que: Bordão que virou ditado · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'chacrinha'
  and not exists (select 1 from quotes where text = 'Quem não se comunica, se trumbica!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu vim para confundir, não para explicar!', 'pt', null, 'Outro bordão do Velho Guerreiro, repetido até hoje.', 'video', 'https://www.correiobraziliense.com.br/app/noticia/diversao-e-arte/2017/09/30/interna_diversao_arte,630152/100-anos-de-chacrinha.shtml', null, 2, 'iconica', 'draft', 'Fonte: Correio Braziliense · Por que: Bordão clássico · Obs.: Algumas matérias trazem "Eu não vim para explicar, eu vim para confundir".'
from people where slug = 'chacrinha'
  and not exists (select 1 from quotes where text = 'Eu vim para confundir, não para explicar!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Alô, Terezinha!', 'pt', null, 'O chamado de Chacrinha no Cassino do Chacrinha.', 'video', 'https://www.correiobraziliense.com.br/app/noticia/diversao-e-arte/2017/09/30/interna_diversao_arte,630152/100-anos-de-chacrinha.shtml', null, 2, 'iconica', 'draft', 'Fonte: Correio Braziliense · Por que: Bordão clássico'
from people where slug = 'chacrinha'
  and not exists (select 1 from quotes where text = 'Alô, Terezinha!');
-- osmar-santos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Ripa na chulipa e pimba na gorduchinha!', 'pt', null, 'Bordão do narrador na hora do chute a gol, nas transmissões de rádio e TV.', 'video', 'https://www.terra.com.br/esportes/bordoes-em-copas-do-mundo-relembre-frases-marcantes-de-narradores,b806286d88c6e724a6c6c4f0c40388fepnqq5p7u.html', null, 3, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão de narração · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'osmar-santos'
  and not exists (select 1 from quotes where text = 'Ripa na chulipa e pimba na gorduchinha!');
-- sergio-mallandro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Rá! Pegadinha do Mallandro!', 'pt', null, 'O grito que revelava a pegadinha para a vítima, no programa do Mallandro.', 'video', 'https://www.terra.com.br/diversao/gente/sergio-mallandro-passa-por-cirurgia-no-olho-veja-o-motivo,3fb4cb8be27898046efaebd3d4135c7fvcp0o4fm.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão clássico · Obs.: A matéria lista "pegadinha do mallandro" e "rá" como bordões, não a frase junta. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'sergio-mallandro'
  and not exists (select 1 from quotes where text = 'Rá! Pegadinha do Mallandro!');
-- marcelo-rezende
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Corta pra mim!', 'pt', null, 'Pedido à produção para mudar a imagem, no Cidade Alerta. Virou título da autobiografia dele.', 'video', 'https://www.metropoles.com/entretenimento/televisao/olha-o-sururu-relembre-os-principais-bordoes-de-marcelo-rezende', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão do Cidade Alerta · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'marcelo-rezende'
  and not exists (select 1 from quotes where text = 'Corta pra mim!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Olha o sururu!', 'pt', null, 'Usado para avisar de um flagrante nas transmissões ao vivo do Cidade Alerta.', 'video', 'https://www.metropoles.com/entretenimento/televisao/olha-o-sururu-relembre-os-principais-bordoes-de-marcelo-rezende', null, 2, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão do Cidade Alerta'
from people where slug = 'marcelo-rezende'
  and not exists (select 1 from quotes where text = 'Olha o sururu!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Põe exclusivo, minha filha!', 'pt', null, 'O grito para anunciar um furo de reportagem no Cidade Alerta.', 'video', 'https://www.metropoles.com/entretenimento/televisao/olha-o-sururu-relembre-os-principais-bordoes-de-marcelo-rezende', null, 2, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão do Cidade Alerta'
from people where slug = 'marcelo-rezende'
  and not exists (select 1 from quotes where text = 'Põe exclusivo, minha filha!');

commit;
