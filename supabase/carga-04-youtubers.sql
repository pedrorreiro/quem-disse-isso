-- Carga 4: categoria Youtubers (22 frases). Só falas que deram polêmica de verdade, conferidas em veículos grandes
-- (CNN Brasil, Terra, Metrópoles, Correio Braziliense, Aos Fatos). Tudo entra como RASCUNHO: nada fica jogável até você aprovar
-- em /admin → Fila de revisão. Pessoas novas entram sem foto (aprove em /admin → Fotos).
-- Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Youtubers que já estavam em "internet" passam para a categoria nova. A área continua "internet",
-- então as alternativas erradas seguem misturando youtubers e influenciadores.
update people set category = 'youtubers', area = coalesce(area, 'internet')
 where slug in ('felipe-neto', 'whindersson-nunes', 'kefera-buchmann', 'felipe-castanhari', 'casimiro');

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Monark', 'monark', 'youtubers', 'internet', 'm', 'BR', 'Youtuber e ex-apresentador do Flow Podcast'),
  ('Júlio Cocielo', 'julio-cocielo', 'youtubers', 'internet', 'm', 'BR', 'Youtuber do canal Canal Canalha'),
  ('Arthur do Val', 'arthur-do-val', 'youtubers', 'internet', 'm', 'BR', 'Youtuber do Mamãe Falei e ex-deputado estadual por SP'),
  ('Italo Marsili', 'italo-marsili', 'youtubers', 'internet', 'm', 'BR', 'Youtuber conservador, cotado para ministro da Saúde em 2020'),
  ('Nando Moura', 'nando-moura', 'youtubers', 'internet', 'm', 'BR', 'Youtuber e músico, ex-apoiador de Bolsonaro'),
  ('Viih Tube', 'viih-tube', 'youtubers', 'internet', 'f', 'BR', 'Youtuber e ex-BBB 21'),
  ('Rica Perrone', 'rica-perrone', 'youtubers', 'internet', 'm', 'BR', 'Jornalista esportivo e youtuber'),
  ('Toguro', 'toguro', 'youtubers', 'internet', 'm', 'BR', 'Youtuber fitness, dono da Mansão Maromba'),
  ('Thiago Nigro', 'thiago-nigro', 'youtubers', 'internet', 'm', 'BR', 'Youtuber de finanças, o Primo Rico'),
  ('Mítico', 'mitico', 'youtubers', 'internet', 'm', 'BR', 'Youtuber, coapresentador do Podpah'),
  ('Igão', 'igao', 'youtubers', 'internet', 'm', 'BR', 'Youtuber, coapresentador do Podpah'),
  ('Léo Lins', 'leo-lins', 'youtubers', 'internet', 'm', 'BR', 'Humorista de stand-up com especiais no YouTube'),
  ('Paulo Figueiredo', 'paulo-figueiredo', 'youtubers', 'internet', 'm', 'BR', 'Influenciador bolsonarista com programa semanal em vídeo'),
  ('Nath Finanças', 'nath-financas', 'youtubers', 'internet', 'f', 'BR', 'Youtuber de educação financeira')
on conflict (slug) do nothing;

-- monark
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu acho que tinha que ter um partido nazista reconhecido pela lei', 'pt', '2022-02-07', 'No Flow Podcast, entrevistando os deputados Tabata Amaral e Kim Kataguiri. Foi desligado do Flow no dia seguinte, patrocinadores romperam com o programa e a PGR abriu investigação por apologia ao nazismo. Pediu desculpas dizendo que estava bêbado.', 'video', 'https://www.cnnbrasil.com.br/nacional/monark-e-desligado-do-flow-podcast-apos-defender-existencia-de-partido-nazista/', null, 1, 'draft', 'Fonte: CNN Brasil · Por que: A fala que derrubou o maior podcast do país · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'monark'
  and not exists (select 1 from quotes where text = 'Eu acho que tinha que ter um partido nazista reconhecido pela lei');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se o cara quiser ser um antijudeu, eu acho que ele tinha direito de ser', 'pt', '2022-02-07', 'No mesmo episódio do Flow Podcast em que defendeu um partido nazista legalizado, com Tabata Amaral e Kim Kataguiri no estúdio. A Conib condenou a fala.', 'video', 'https://www.cnnbrasil.com.br/nacional/monark-e-desligado-do-flow-podcast-apos-defender-existencia-de-partido-nazista/', null, 2, 'draft', 'Fonte: CNN Brasil · Por que: Defesa aberta do antissemitismo como direito · Obs.: Texto conferido na matéria.'
from people where slug = 'monark'
  and not exists (select 1 from quotes where text = 'Se o cara quiser ser um antijudeu, eu acho que ele tinha direito de ser');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O Pelé ficou com a Xuxa, que é trans', 'pt', '2026-07-13', 'Em vídeo no YouTube com Tiago Carvalho e Igor Caçamba. Em outros vídeos da mesma leva disse, sem nenhuma prova, que Luísa Sonza e Michelle Bolsonaro também seriam mulheres trans.', 'video', 'https://www.metropoles.com/colunas/fabia-oliveira/monark-polemiza-e-afirma-que-luisa-sonza-e-xuxa-sao-mulheres-trans', null, 2, 'draft', 'Fonte: Metrópoles · Por que: Teoria da conspiração sobre a Rainha dos Baixinhos · Obs.: Texto conferido na matéria. Data da publicação; o vídeo é de dias antes.'
from people where slug = 'monark'
  and not exists (select 1 from quotes where text = 'O Pelé ficou com a Xuxa, que é trans');

-- julio-cocielo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Mbappé conseguiria fazer uns arrastão top na praia hein', 'pt', '2018-06-30', 'Tuíte durante França x Argentina, na Copa de 2018. Apagou minutos depois, mas perdeu patrocínios como o da Adidas, apagou 50 mil tuítes antigos e acabou processado por racismo.', 'post', 'https://www.terra.com.br/esportes/futebol/copa-2018/youtuber-causa-polemica-com-piada-sobre-jogador-negro-da-franca,87e7d7b18074af13e1cfb9f4c20549dd3n04duo6.html', null, 1, 'draft', 'Fonte: Terra · Por que: Piada racista sobre o craque da França que custou contratos milionários · Obs.: Texto conferido na matéria (o erro de concordância é do original). Pessoa nova: aprove a foto em /admin → Fotos. Processo: https://www.metropoles.com/esportes/mpf-pede-condenacao-de-julio-cocielo-por-racismo-contra-mbappe'
from people where slug = 'julio-cocielo'
  and not exists (select 1 from quotes where text = 'Mbappé conseguiria fazer uns arrastão top na praia hein');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Existe um infinito entre ser racista e fazer uma piadinha de cunho racista, principalmente quando ela foi feita em 2012', 'pt', '2021-01-20', 'No podcast Mais que 8 Minutos, de Rafinha Bastos, sobre o processo por racismo movido pelos tuítes antigos. Também reclamou do pedido de indenização de R$ 7 milhões.', 'entrevista', 'https://www.terra.com.br/diversao/gente/cocielo-ha-um-infinito-entre-ser-racista-e-fazer-uma-piada,63d51e64405772171925f51b912099c9zx5uf5kq.html', null, 2, 'draft', 'Fonte: Terra · Por que: Tentativa de separar ''ser racista'' de ''fazer piada racista'' · Obs.: Texto conferido na matéria. O ano 2012 na frase ajuda pouco a adivinhar.'
from people where slug = 'julio-cocielo'
  and not exists (select 1 from quotes where text = 'Existe um infinito entre ser racista e fazer uma piadinha de cunho racista, principalmente quando ela foi feita em 2012');

-- arthur-do-val
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'São fáceis, porque elas são pobres', 'pt', '2022-03-04', 'Em áudios vazados para um grupo de amigos do MBL, sobre refugiadas ucranianas que conheceu na fronteira, dias depois da invasão russa. Era deputado estadual; a namorada terminou com ele e o Podemos abriu processo disciplinar. Disse que foi ''um erro num momento de empolgação''.', 'post', 'https://www.cnnbrasil.com.br/politica/audios-atribuidos-a-arthur-do-val-dizem-que-ucranianas-sao-faceis-porque-sao-pobres/', null, 1, 'draft', 'Fonte: CNN Brasil · Por que: Comentário sexual sobre refugiadas de guerra que acabou com a carreira política dele · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos. Desculpas: https://www.poder360.com.br/europa-em-guerra/fala-sobre-ucranianas-foi-um-erro-diz-mamae-falei/'
from people where slug = 'arthur-do-val'
  and not exists (select 1 from quotes where text = 'São fáceis, porque elas são pobres');

-- felipe-neto
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Cadeia nesse corrupto chamado Lula, nesse safado, nesse ladrão, nesse delinquente desgraçado que afundou o nosso país.', 'pt', '2016-03-11', 'Em vídeo chamando jovens para os protestos pelo impeachment de Dilma, um dia depois de Lula ser nomeado para a Casa Civil. Anos depois virou um dos maiores apoiadores de Lula, apagou o vídeo e disse se arrepender.', 'video', 'https://www.aosfatos.org/noticias/video-felipe-neto-lula-ladrao-2016-nao-atual/', null, 3, 'draft', 'Fonte: Aos Fatos · Por que: Quem hoje faz campanha para Lula já pediu a prisão dele aos gritos · Obs.: Texto conferido na checagem. Também no Terra: https://www.terra.com.br/noticias/video-em-que-felipe-neto-chama-lula-de-ladrao-e-de-2016-nao-atual,d5db1561fdf110dbd6ff70bd2c9c9441ph344tqv.html'
from people where slug = 'felipe-neto'
  and not exists (select 1 from quotes where text = 'Cadeia nesse corrupto chamado Lula, nesse safado, nesse ladrão, nesse delinquente desgraçado que afundou o nosso país.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Perdão por ter propagado o antipetismo, o discurso golpista e o ódio à esquerda.', 'pt', '2022-09-26', 'Nas redes, contando que encontrou Dilma Rousseff e pediu desculpas olhando nos olhos dela, uma semana antes do primeiro turno de 2022. Em 2016 tinha feito campanha pelo impeachment dela.', 'post', 'https://www.terra.com.br/noticias/eleicoes/felipe-neto-encontra-dilma-e-pede-desculpas-perdao-por-ter-propagado-o-antipetismo,cd3908ba862f86a5e21c55f4c6b1ca148tdhy7si.html', null, 2, 'draft', 'Fonte: Terra · Por que: A virada política mais famosa da internet brasileira, em uma frase · Obs.: Texto conferido na matéria.'
from people where slug = 'felipe-neto'
  and not exists (select 1 from quotes where text = 'Perdão por ter propagado o antipetismo, o discurso golpista e o ódio à esquerda.');

-- whindersson-nunes
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Te jogaria no penhasco de novo', 'pt', '2026-07-05', 'Respondendo no X a uma provocação de Haaland logo depois de a Noruega eliminar o Brasil da Copa de 2026. Era uma referência a ''Penhasco'', música que a ex-mulher, Luísa Sonza, fez sobre o fim do casamento. Ela o chamou de ''homem medíocre'' e deixou de segui-lo; ele pediu desculpas uma semana depois.', 'post', 'https://www.cnnbrasil.com.br/pop/celebridades/luisa-sonza-e-whindersson-entenda-treta-do-ex-casal-envolvendo-haaland/', null, 2, 'draft', 'Fonte: CNN Brasil · Por que: Piada com a ex-mulher no meio da eliminação da Seleção · Obs.: Texto conferido na matéria (o Terra traz a variante ''do penhasco'').'
from people where slug = 'whindersson-nunes'
  and not exists (select 1 from quotes where text = 'Te jogaria no penhasco de novo');

-- italo-marsili
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'É muito fácil você convencer uma mulher de votar. É só você seduzi-la', 'pt', '2020-05-02', 'Em transmissão no YouTube, culpando o voto feminino pela crise das democracias. O vídeo viralizou quando ele era cotado para o Ministério da Saúde; CFM e ABP disseram que ele não tem registro de psiquiatra.', 'video', 'https://www.metropoles.com/brasil/nome-olavista-para-a-saude-e-armamentista-anti-isolamento-e-pro-cloroquina', null, 3, 'draft', 'Fonte: Metrópoles · Por que: Ataque ao direito de voto das mulheres por um cotado a ministro · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'italo-marsili'
  and not exists (select 1 from quotes where text = 'É muito fácil você convencer uma mulher de votar. É só você seduzi-la');

-- nando-moura
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu mesmo já doei pra esse vigarista intelectual, pedi para as pessoas doarem.', 'pt', '2021-04-28', 'Em vídeo no YouTube em que queimou todos os livros de Olavo de Carvalho, de quem foi aluno e divulgador. Chamou o ex-guru de ''reacionário, cretino, fanático''.', 'video', 'https://www.metropoles.com/brasil/nando-moura-queima-livros-de-olavo-de-carvalho-um-lixo-uma-merda', null, 3, 'draft', 'Fonte: Metrópoles · Por que: Ex-discípulo queimando os livros do guru da direita · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'nando-moura'
  and not exists (select 1 from quotes where text = 'Eu mesmo já doei pra esse vigarista intelectual, pedi para as pessoas doarem.');

-- kefera-buchmann
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Foi em Punta Cana, eu fiquei com um traficante, mas eu não sabia.', 'pt', '2025-06-19', 'No programa Dellamake, de Bianca DellaFancy. Contou que só percebeu quando ele perguntou se ela queria alguma coisa e mostrou ''muita droga''.', 'entrevista', 'https://www.terra.com.br/diversao/gente/a-declaracao-de-kefera-sobre-ter-dormido-com-um-traficante,9974d77080e3dc256cac4eba3416755cx4u66il5.html', null, 2, 'draft', 'Fonte: Terra · Por que: Confissão inesperada contada como se fosse nada · Obs.: Texto conferido na matéria. Data da publicação.'
from people where slug = 'kefera-buchmann'
  and not exists (select 1 from quotes where text = 'Foi em Punta Cana, eu fiquei com um traficante, mas eu não sabia.');

-- viih-tube
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A intenção foi causar para chamar atenção para um assunto que é importante', 'pt', '2026-07-02', 'Defendendo ''As Patroas'', reality nas redes em que as funcionárias da casa dela disputavam prêmios em dinheiro; numa prova, tinham de pegar moedas dentro de um vaso sanitário. O MPT abriu investigação e o TST falou em possível assédio moral.', 'post', 'https://www.cnnbrasil.com.br/pop/celebridades/viih-tube-se-manifesta-apos-polemica-com-reality-show-foi-para-causar/', null, 2, 'draft', 'Fonte: CNN Brasil · Por que: Patroa transformando as próprias funcionárias em reality show · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'viih-tube'
  and not exists (select 1 from quotes where text = 'A intenção foi causar para chamar atenção para um assunto que é importante');

-- rica-perrone
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quem você acha que é para vir na porta da minha casa e falar assim comigo?', 'pt', '2023-07-01', 'No podcast O Poder nos Bastidores, contando que jogou o pedido em um entregador do iFood depois de uma discussão sobre subir até o apartamento. O corte viralizou em setembro de 2023 e o entregador disse ter sido ''duplamente agredido''.', 'video', 'https://www.terra.com.br/diversao/gente/video-de-rica-perrone-sobre-discussao-com-entregador-e-alvo-de-criticas-joguei-pacote-nele-veja,7cdbf063a9de40014e941fbef425a6ffpvfu8oy2.html', null, 3, 'draft', 'Fonte: Terra · Por que: Contou com orgulho que jogou a comida no entregador · Obs.: Texto conferido na matéria. Só o mês (julho de 2023) é certo. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'rica-perrone'
  and not exists (select 1 from quotes where text = 'Quem você acha que é para vir na porta da minha casa e falar assim comigo?');

-- toguro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A minha bebida não é energético. Não tem cafeína, é sabor energético', 'pt', '2026-01-28', 'Em podcast com Leo Stronda, que questionou o lançamento de uma bebida alcoólica da Mansão Maromba já misturada com ''energético''. A explicação virou meme nacional.', 'video', 'https://www.terra.com.br/diversao/sabor-energetico-entenda-o-meme-que-parou-a-internet,f7a9881a63dff573d08e4d635cc0fe4fnkx5uanc.html', null, 2, 'draft', 'Fonte: Terra · Por que: A desculpa mais criativa para driblar a Anvisa · Obs.: Texto conferido na matéria. Data da publicação. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'toguro'
  and not exists (select 1 from quotes where text = 'A minha bebida não é energético. Não tem cafeína, é sabor energético');

-- thiago-nigro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Alguns influenciam os outros a fumarem maconha o dia inteiro e xingam uns aos outros', 'pt', '2023-08-12', 'Respondendo a Marcelo D2, que debochou dele no Podpah depois da polêmica do post ''Não tem pobreza que resista a 14 horas de trabalho''. Completou dizendo que outros ''incentivam pessoas a trabalharem e irem atrás de seus sonhos''.', 'post', 'https://www.terra.com.br/diversao/gente/primo-rico-troca-farpas-com-marcelo-d2-apos-deboche-de-rapper-maconha-o-dia-inteiro,9302759f7bc8fcb7c5fe65e0bf984a683erh9dvy.html', null, 3, 'draft', 'Fonte: Terra · Por que: Briga pública entre o coach do dinheiro e o rapper da maconha · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'thiago-nigro'
  and not exists (select 1 from quotes where text = 'Alguns influenciam os outros a fumarem maconha o dia inteiro e xingam uns aos outros');

-- felipe-castanhari
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quando descobrirem quem é de verdade, acabou tudo isso', 'pt', '2022-10-11', 'No podcast Groselha Talk, sobre a influenciadora Gkay. Chamou-a de ''insuportável, insuportável'' e disse que não admite ''quem maltrata pessoas que trabalham com ela''.', 'entrevista', 'https://www.correiobraziliense.com.br/diversao-e-arte/2022/10/5043562-felipe-castanhari-detona-gkay-nao-admito-quem-maltrata-as-pessoas.html', null, 3, 'draft', 'Fonte: Correio Braziliense · Por que: Youtuber famoso ameaçando expor a rainha da Farofa · Obs.: Texto conferido na matéria. Data da publicação.'
from people where slug = 'felipe-castanhari'
  and not exists (select 1 from quotes where text = 'Quando descobrirem quem é de verdade, acabou tudo isso');

-- mitico
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Fútil é o c*ralho, eu elogiei o boy que você estava', 'pt', '2024-06-26', 'Lembrando a entrevista em que Anitta o chamou de ''fútil'' no Podpah, depois de ele elogiar o namorado dela. Disse que na hora ficou quieto, mas que hoje responderia assim.', 'entrevista', 'https://www.metropoles.com/celebridades/mitico-revela-por-que-foi-chamado-de-futil-por-anitta-e-detona-cantora', null, 2, 'draft', 'Fonte: Metrópoles · Por que: Resposta atrasada e malcriada para a maior cantora do país · Obs.: Texto conferido na matéria, com o palavrão censurado como no original. Era o que ele diria hoje, não o que disse a ela. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'mitico'
  and not exists (select 1 from quotes where text = 'Fútil é o c*ralho, eu elogiei o boy que você estava');

-- igao
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ela pensava assim até eu endireitar a vida dela', 'pt', '2023-12-19', 'No Podpah, com Mítico, Diogo Defante e Menina Veneno, sobre a namorada, Carolyna Borges, que é bissexual. A fala foi vista como bifóbica e ele foi ''cancelado'' nas redes; parte do público defendeu que era brincadeira.', 'video', 'https://tvprime.correiobraziliense.com.br/noticia/212525/celebridades/igao-do-podpah-e-cancelado-na-internet-por-dizer-que-endireitou-a-namorada-que-era-bissexual-19122023', null, 2, 'draft', 'Fonte: Correio Braziliense (TV Prime) · Por que: Disse no maior podcast do país que ''consertou'' a namorada bissexual · Obs.: Texto conferido na matéria. Data da publicação; a gravação é de dias antes. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'igao'
  and not exists (select 1 from quotes where text = 'Ela pensava assim até eu endireitar a vida dela');

-- leo-lins
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Um rapaz disse que testemunharia ao meu favor porque salvei a vida dele', 'pt', '2025-06-05', 'Em live no YouTube depois de ser condenado a mais de 8 anos de prisão por piadas preconceituosas no especial ''Perturbador''. Disse que recebe mensagens de quem superou a depressão com as piadas dele e não pediu desculpas.', 'video', 'https://www.metropoles.com/colunas/fabia-oliveira/apos-ser-condenado-leo-lins-diz-que-suas-piadas-salvaram-vidas', null, 2, 'draft', 'Fonte: Metrópoles · Por que: Condenado por preconceito, diz que as piadas salvam vidas · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'leo-lins'
  and not exists (select 1 from quotes where text = 'Um rapaz disse que testemunharia ao meu favor porque salvei a vida dele');

-- paulo-figueiredo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A mulher vota estatisticamente muito mal, principalmente mulheres solteiras.', 'pt', '2026-06-25', 'No programa semanal em vídeo, criticando Michelle Bolsonaro e o PL Mulher porque Flávio Bolsonaro ia mal nas pesquisas entre as eleitoras. Completou: ''Mulheres casadas, em geral, tendem a acompanhar o voto do marido.''', 'video', 'https://www.metropoles.com/brasil/paulo-figueiredo-volta-a-criticar-michelle-e-diz-mulher-vota-mal', null, 2, 'draft', 'Fonte: Metrópoles · Por que: Ataque ao voto feminino em ano de eleição · Obs.: Texto conferido na matéria. Data do vídeo. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'paulo-figueiredo'
  and not exists (select 1 from quotes where text = 'A mulher vota estatisticamente muito mal, principalmente mulheres solteiras.');

-- nath-financas
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não adianta tentar usar minha marca registrada e atrapalhar meu corre', 'pt', '2024-01-16', 'Em vídeo contra Nathalia Arcuri, do Me Poupe!, cuja empresa pediu oposição ao registro da marca Nath Play no INPI. Abriu com: ''Não adianta usar Nath Finanças pra vender seus cursos.'' Arcuri disse que foi um mal-entendido e retirou o pedido.', 'video', 'https://www.correiobraziliense.com.br/diversao-e-arte/2024/01/6789011-nathalia-x-nath-entenda-treta-entre-influenciadoras-de-financas.html', null, 3, 'draft', 'Fonte: Correio Braziliense · Por que: Treta pública entre as duas maiores youtubers de finanças · Obs.: Texto conferido na matéria. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'nath-financas'
  and not exists (select 1 from quotes where text = 'Não adianta tentar usar minha marca registrada e atrapalhar meu corre');

commit;
