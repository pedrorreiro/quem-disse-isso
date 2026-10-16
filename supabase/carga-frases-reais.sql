-- Carga de pessoas e frases REAIS (pesquisa com fonte). Tudo entra como RASCUNHO:
-- nenhuma frase fica jogável até você aprovar em /admin → Frases, e as fotos em /admin → Fotos
-- (botão "Buscar fotos de todos"). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- 1) Remove os dados de exemplo inventados (e as partidas de teste que usaram essas frases).
delete from game_rounds where quote_id in (select id from quotes where is_demo);
delete from daily_challenges d where exists (select 1 from quotes q where q.is_demo and q.id = any (d.quote_ids));
delete from quotes where is_demo;
delete from people where is_demo;

-- 2) Pessoas (sem foto; a foto vem pelo painel).
insert into people (name, slug, category, country, bio_short) values
  ('Romário', 'romario', 'futebol', 'BR', 'Ex-atacante, herói do tetra em 1994'),
  ('Renato Gaúcho', 'renato-gaucho', 'futebol', 'BR', 'Ex-atacante e técnico, ídolo do Grêmio'),
  ('Joel Santana', 'joel-santana', 'futebol', 'BR', 'Técnico, o ''Papai Joel'''),
  ('Vampeta', 'vampeta', 'futebol', 'BR', 'Ex-volante, pentacampeão mundial em 2002'),
  ('Neymar', 'neymar', 'futebol', 'BR', 'Atacante, maior artilheiro da Seleção'),
  ('José Mourinho', 'jose-mourinho', 'gringos', 'PT', 'Técnico português, o ''Special One'''),
  ('Cristiano Ronaldo', 'cristiano-ronaldo', 'gringos', 'PT', 'Atacante português, 5 vezes melhor do mundo'),
  ('Inês Brasil', 'ines-brasil', 'internet', 'BR', 'Cantora e ícone dos memes brasileiros'),
  ('Narcisa Tamborindeguy', 'narcisa-tamborindeguy', 'internet', 'BR', 'Socialite carioca'),
  ('Gil do Vigor', 'gil-do-vigor', 'internet', 'BR', 'Economista e ex-BBB21'),
  ('Gretchen', 'gretchen', 'internet', 'BR', 'Cantora e rainha dos memes'),
  ('Casimiro', 'casimiro', 'internet', 'BR', 'Streamer, dono da CazéTV'),
  ('Whindersson Nunes', 'whindersson-nunes', 'internet', 'BR', 'Humorista e youtuber piauiense'),
  ('Kéfera Buchmann', 'kefera-buchmann', 'internet', 'BR', 'Youtuber do 5incominutos e atriz'),
  ('Felipe Castanhari', 'felipe-castanhari', 'internet', 'BR', 'Youtuber do Canal Nostalgia'),
  ('Felipe Neto', 'felipe-neto', 'internet', 'BR', 'Youtuber e empresário carioca'),
  ('MrBeast', 'mrbeast', 'gringos', 'US', 'Jimmy Donaldson, maior youtuber do mundo'),
  ('Silvio Santos', 'silvio-santos', 'tv', 'BR', 'Apresentador e dono do SBT'),
  ('Faustão', 'faustao', 'tv', 'BR', 'Fausto Silva, apresentador do Domingão'),
  ('Galvão Bueno', 'galvao-bueno', 'tv', 'BR', 'Narrador esportivo, voz das Copas na Globo'),
  ('Ana Maria Braga', 'ana-maria-braga', 'tv', 'BR', 'Apresentadora do Mais Você, na TV Globo'),
  ('Anitta', 'anitta', 'musica', 'BR', 'Cantora pop de sucesso internacional'),
  ('Zeca Pagodinho', 'zeca-pagodinho', 'musica', 'BR', 'Sambista carioca'),
  ('Tim Maia', 'tim-maia', 'musica', 'BR', 'Cantor e compositor, rei do soul brasileiro'),
  ('Rita Lee', 'rita-lee', 'musica', 'BR', 'Cantora e compositora, rainha do rock brasileiro'),
  ('Dilma Rousseff', 'dilma-rousseff', 'politica', 'BR', 'Ex-presidente do Brasil (2011–2016)'),
  ('Lula', 'lula', 'politica', 'BR', 'Presidente do Brasil (2003–2010 e desde 2023)'),
  ('Jair Bolsonaro', 'jair-bolsonaro', 'politica', 'BR', 'Ex-presidente do Brasil (2019–2022)'),
  ('Donald Trump', 'donald-trump', 'politica', 'US', 'Presidente dos Estados Unidos'),
  ('Kanye West', 'kanye-west', 'gringos', 'US', 'Rapper e produtor americano (Ye)')
on conflict (slug) do nothing;

-- 3) Frases (status draft).

-- Romário
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Pelé calado é um poeta.', 'pt', null, 'Respondendo a Pelé, que tinha sugerido que ele se aposentasse, 2005', 'materia', 'https://www.cmjornal.pt/desporto/detalhe/pele-calado-e-um-poeta', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Vídeo: https://www.youtube.com/watch?v=Po3wM6oE_rk · Fonte: Correio da Manhã'
from people where slug = 'romario'
  and not exists (select 1 from quotes where text = 'Pelé calado é um poeta.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quando eu nasci, papai do céu apontou o dedo e disse: esse é o cara.', 'pt', null, 'Depois de marcar pelo Fluminense contra o Corinthians, 2003', 'materia', 'https://www.metropoles.com/colunas/futebol_etc/romario-o-nosso-heroi-do-tetra-surtou', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles'
from people where slug = 'romario'
  and not exists (select 1 from quotes where text = 'Quando eu nasci, papai do céu apontou o dedo e disse: esse é o cara.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Sou um cara de pau. De assumir toda aquela responsabilidade na Copa de 1994, mas deu certo.', 'pt', null, 'Entrevista ao GNT, lembrando a promessa do título em 1994', 'entrevista', 'https://www.folhavitoria.com.br/esportes/romario-elogia-selecao-e-trabalho-de-felipao-para-copa/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Folha Vitória'
from people where slug = 'romario'
  and not exists (select 1 from quotes where text = 'Sou um cara de pau. De assumir toda aquela responsabilidade na Copa de 1994, mas deu certo.');

-- Renato Gaúcho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Com certeza. Eu acho que joguei mais do que ele.', 'pt', null, 'No programa Bola da Vez (ESPN), sobre Cristiano Ronaldo, antes da final do Mundial de 2017', 'entrevista', 'https://blogs.correiobraziliense.com.br/dribledecorpo/renato-gaucho-cristiano-ronaldo-final-mundial-clubes/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio Braziliense (blog Drible de Corpo)'
from people where slug = 'renato-gaucho'
  and not exists (select 1 from quotes where text = 'Com certeza. Eu acho que joguei mais do que ele.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Futebol é como andar de bicicleta.', 'pt', null, 'Respondendo a quem o chamava de técnico desatualizado, 2016', 'materia', 'https://www.gazetaesportiva.com/gremio/renato-nao-se-ve-desatualizado-futebol-e-como-andar-de-bicicleta/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Gazeta Esportiva'
from people where slug = 'renato-gaucho'
  and not exists (select 1 from quotes where text = 'Futebol é como andar de bicicleta.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu sei que vai virar manchete, mas pode colocar aí: daqui a pouco o Grêmio vai decolar.', 'pt', null, 'Entrevista depois de um Gre-Nal', 'entrevista', 'https://www.goal.com/br/not%C3%ADcias/renato-escreve-a-manchete-apos-gre-nal-e-repete-frase-de/rnb31ca8ce901818f1sg0w42t', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Goal'
from people where slug = 'renato-gaucho'
  and not exists (select 1 from quotes where text = 'Eu sei que vai virar manchete, mas pode colocar aí: daqui a pouco o Grêmio vai decolar.');

-- Joel Santana
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'One player experienced, Katlego Mashego, and another player que have experience, que play, play very good, Steven Piennar.', 'pt', '2009-06-14', 'Entrevista em inglês após África do Sul x Iraque, Copa das Confederações de 2009', 'video', 'https://www.blogs.unicamp.br/linguistica/2017/01/05/o-ingles-de-joel-santana-muito-mais-que-um-sotaque/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Blogs de Ciência da Unicamp (transcrição)'
from people where slug = 'joel-santana'
  and not exists (select 1 from quotes where text = 'One player experienced, Katlego Mashego, and another player que have experience, que play, play very good, Steven Piennar.');

-- Vampeta
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eles fingem que pagam e eu finjo que jogo.', 'pt', null, 'Sobre os salários atrasados no Flamengo, 2001', 'materia', 'https://www.acessa.com/cultura/2024/03/209667-vampeta-faz-50-anos-contando-causos-e-divertindo-o-brasil.html', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Acessa.com (Folhapress)'
from people where slug = 'vampeta'
  and not exists (select 1 from quotes where text = 'Eles fingem que pagam e eu finjo que jogo.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu já bebo sem ganhar nada, imagina campeão do mundo.', 'pt', null, 'No Esporte em Debate, explicando as cambalhotas na rampa do Planalto em 2002', 'entrevista', 'https://www.folhavitoria.com.br/esportes/ousadia-vampeta-sugere-que-neymar-de-um-selinho-em-dilma/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Folha Vitória'
from people where slug = 'vampeta'
  and not exists (select 1 from quotes where text = 'Eu já bebo sem ganhar nada, imagina campeão do mundo.');

-- Neymar
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Dei uma pedalada no psicólogo.', 'pt', null, 'Coletiva no CT Rei Pelé, no Santos, sobre faltar às sessões com o psicólogo, 2010', 'materia', 'https://dol.com.br/esporte/esporte-brasil/noticia-114234-dei-uma-pedalada-no-psicologo-diz-neymar.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Diário Online (via Terra)'
from people where slug = 'neymar'
  and not exists (select 1 from quotes where text = 'Dei uma pedalada no psicólogo.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O muro do Santos está baixinho, é só descer a serra. Qualquer coisa eu mando o batmóvel.', 'pt', null, 'Live com Vitor Roque na Kings League, brincando com a ideia de levá-lo ao Santos', 'video', 'https://www.goal.com/br/listas/neymar-dirigente-camisa-10-pede-vitor-roque-santos-atacante-palmeiras-responde/bltab8c6d5c51584056', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Goal'
from people where slug = 'neymar'
  and not exists (select 1 from quotes where text = 'O muro do Santos está baixinho, é só descer a serra. Qualquer coisa eu mando o batmóvel.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Em nenhum momento eu fiz teatro.', 'pt', null, 'Respondendo à fama de ''cai-cai'' depois da Copa de 2018', 'materia', 'https://www.gazetaesportiva.com/futebol/neymar-ve-criticas-injustas-e-condena-fama-de-cai-cai-na-copa-nao-fiz-teatro/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Gazeta Esportiva'
from people where slug = 'neymar'
  and not exists (select 1 from quotes where text = 'Em nenhum momento eu fiz teatro.');

-- José Mourinho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Por favor, não me chamem de arrogante, porque o que estou dizendo é verdade. Sou campeão europeu e acho que sou um especial.', 'pt', '2004-07-02', 'Primeira coletiva como técnico do Chelsea, 2004', 'materia', 'https://premierleague.com/pl30/the-special-one', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): Please don''t call me arrogant, because what I''m saying is true. I''m European champion and I think I am a special one. · Fonte: Premier League'
from people where slug = 'jose-mourinho'
  and not exists (select 1 from quotes where text = 'Por favor, não me chamem de arrogante, porque o que estou dizendo é verdade. Sou campeão europeu e acho que sou um especial.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se eu tiver que escolher um apelido para este momento, eu escolheria ''o Feliz''.', 'pt', '2013-06-10', 'Apresentação na volta ao Chelsea, 2013', 'materia', 'https://www.arabnews.com/news/454598', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): If I have to choose a nickname for this period, I would choose ''the Happy One''. · Fonte: Arab News (AFP)'
from people where slug = 'jose-mourinho'
  and not exists (select 1 from quotes where text = 'Se eu tiver que escolher um apelido para este momento, eu escolheria ''o Feliz''.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se eu falar, vou me meter em grande encrenca, e eu não quero me meter em grande encrenca.', 'pt', '2014-03-15', 'Evitando comentar a arbitragem depois de Aston Villa 1x0 Chelsea, 2014', 'materia', 'https://english.ahram.org.eg/News/96788.aspx', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): If I speak I am in big trouble and I don''t want to be in big trouble. · Fonte: Ahram Online (Reuters)'
from people where slug = 'jose-mourinho'
  and not exists (select 1 from quotes where text = 'Se eu falar, vou me meter em grande encrenca, e eu não quero me meter em grande encrenca.');

-- Cristiano Ronaldo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Acho que, por eu ser rico, bonito e um grande jogador, as pessoas têm inveja de mim. Não tenho outra explicação.', 'pt', '2011-09-14', 'Sobre as vaias em Dinamo Zagreb x Real Madrid, Liga dos Campeões 2011', 'materia', 'https://english.ahram.org.eg/News/21304.aspx', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en (tradução da Reuters; original em espanhol)): I think that because I am rich, handsome and a great player people are envious of me. I don''t have any other explanation. · Fonte: Ahram Online (Reuters)'
from people where slug = 'cristiano-ronaldo'
  and not exists (select 1 from quotes where text = 'Acho que, por eu ser rico, bonito e um grande jogador, as pessoas têm inveja de mim. Não tenho outra explicação.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Para mim, não é o fim da minha carreira vir para a África do Sul.', 'pt', '2023-01-03', 'Apresentação no Al-Nassr, em Riad, confundindo a Arábia Saudita com a África do Sul, 2023', 'discurso', 'https://www.africanews.com/amp/2023/01/05/ronaldo-arrives-in-saudi-says-hes-come-to-south-africa/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): For me, it is not the end of my career to come to South Africa. · Fonte: Africanews (AP)'
from people where slug = 'cristiano-ronaldo'
  and not exists (select 1 from quotes where text = 'Para mim, não é o fim da minha carreira vir para a África do Sul.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se for para Portugal ganhar sem eu jogar, eu assino por baixo.', 'pt', null, 'Coletiva antes de Portugal x Dinamarca, Liga das Nações, 2025', 'entrevista', 'https://pt.soccerway.com/noticias/futebol-liga-das-nacoes-ronaldo-defende-martinez-e-atira-se-for-para-portugal-ganhar-sem-eu-jogar-eu-assino-por-baixo/GYDlbQnI', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Soccerway'
from people where slug = 'cristiano-ronaldo'
  and not exists (select 1 from quotes where text = 'Se for para Portugal ganhar sem eu jogar, eu assino por baixo.');

-- Inês Brasil
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se me atacar, eu vou atacar', 'pt', null, 'Bordão que virou meme na internet', 'materia', 'https://www.metropoles.com/colunas/pipocando/se-me-atacar-eu-vou-atacar-perfil-de-ines-brasil-some-da-pagina-do-grammy', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Vídeo: https://www.youtube.com/watch?v=vCzVGBUqYWk · Fonte: Metrópoles'
from people where slug = 'ines-brasil'
  and not exists (select 1 from quotes where text = 'Se me atacar, eu vou atacar');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Alô, alô, graças a Deus', 'pt', null, 'Bordão de abertura que ficou famoso com o vídeo de inscrição para o BBB', 'materia', 'https://www.correiobraziliense.com.br/politica/2026/08/7475401-alo-alo-gracas-a-deus-ines-brasil-lanca-candidatura-a-alerj-pelo-psb.html', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio Braziliense'
from people where slug = 'ines-brasil'
  and not exists (select 1 from quotes where text = 'Alô, alô, graças a Deus');

-- Narcisa Tamborindeguy
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ai, que loucura!', 'pt', null, 'Seu bordão mais famoso, que dá nome ao canal dela no YouTube', 'materia', 'https://www.correiobraziliense.com.br/webstories/2025/06/7184352-narcisa-tamborindeguy-13-fatos-sobre-a-badalada-socialite.html', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Vídeo: https://www.youtube.com/watch?v=lpB0cz_fcxc · Fonte: Correio Braziliense'
from people where slug = 'narcisa-tamborindeguy'
  and not exists (select 1 from quotes where text = 'Ai, que loucura!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Travou, Maitê!', 'pt', null, 'Live com Maitê Proença em que a conexão caiu, 2021', 'materia', 'https://portalpopline.com.br/narcisa-tamborindeguy-live/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: POPLine'
from people where slug = 'narcisa-tamborindeguy'
  and not exists (select 1 from quotes where text = 'Travou, Maitê!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Só participaria se pudesse ter alguém para cuidar dos meus cabelos', 'pt', null, 'Entrevista ao jornal Extra sobre um possível convite para o BBB, 2022', 'entrevista', 'https://www.bnews.com.br/noticias/bbb22/ex-mulher-de-boninho-narcisa-afirma-sobre-o-bbb-so-participaria-se-pudesse-ter-alguem-para-cuidar-dos-meus-cabelos.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: BNews (repercutindo o Extra)'
from people where slug = 'narcisa-tamborindeguy'
  and not exists (select 1 from quotes where text = 'Só participaria se pudesse ter alguém para cuidar dos meus cabelos');

-- Gil do Vigor
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O Brasil tá lascado', 'pt', null, 'Fala no BBB21 ao comentar a economia do país, que virou bordão', 'materia', 'https://www.folhape.com.br/cultura/gil-do-vigor-estreia-quadro-o-brasil-ta-lascado-no-instagram/187630/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Vídeo: https://www.youtube.com/watch?v=B5-JVDmx4Ck · Fonte: Folha de Pernambuco'
from people where slug = 'gil-do-vigor'
  and not exists (select 1 from quotes where text = 'O Brasil tá lascado');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ai, Brasil!', 'pt', null, 'Grito nos momentos de descontração no BBB21', 'materia', 'https://diariodonordeste.verdesmares.com.br/entretenimento/zoeira/quais-os-melhores-bordoes-do-bbb-relembre-e-vote-na-enquete-1.3182104', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Diário do Nordeste'
from people where slug = 'gil-do-vigor'
  and not exists (select 1 from quotes where text = 'Ai, Brasil!');

-- Gretchen
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ganho um público mais jovem sendo ''memeira''', 'pt', null, 'Entrevista sobre virar meme na internet', 'materia', 'https://www.cnnbrasil.com.br/entretenimento/gretchen-faz-65-anos-relembre-os-melhores-memes-da-artista/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CNN Brasil'
from people where slug = 'gretchen'
  and not exists (select 1 from quotes where text = 'Ganho um público mais jovem sendo ''memeira''');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu sou uma fênix', 'pt', null, 'Participação no talk show ''Viralizou, e agora?''', 'materia', 'https://heloisatolipan.com.br/gente/viralizou-e-agora-gretchen-abre-o-coracao-em-talk-show-e-dispara-eu-sou-uma-fenix/', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Heloisa Tolipan'
from people where slug = 'gretchen'
  and not exists (select 1 from quotes where text = 'Eu sou uma fênix');

-- Casimiro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Meteu essa?', 'pt', null, 'Bordão das lives na Twitch que foi parar na dublagem de ''Lightyear''', 'materia', 'https://www.metropoles.com/entretenimento/cinema/meteu-essa-saiba-como-bordao-de-casimiro-foi-parar-em-lightyear', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles'
from people where slug = 'casimiro'
  and not exists (select 1 from quotes where text = 'Meteu essa?');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Que papinho, hein?', 'pt', null, 'Bordão que viralizou nas lives do streamer', 'materia', 'https://www.metropoles.com/historia-em-fotos/saiba-quem-e-casimiro-considerado-o-maior-streamer-do-brasil', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles'
from people where slug = 'casimiro'
  and not exists (select 1 from quotes where text = 'Que papinho, hein?');

-- Whindersson Nunes
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A única coisa que não gostei da luta com Popó é que ele passou conjuntivite', 'pt', null, 'Vídeo no Instagram depois da luta-exibição contra Popó, 2022', 'materia', 'https://www.terra.com.br/esportes/lutas/whindersson-mostra-olhos-feridos-apos-luta-com-popo-e-brinca,1d92e1107bb45038ee6d1bea61d285136oq9gowd.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra'
from people where slug = 'whindersson-nunes'
  and not exists (select 1 from quotes where text = 'A única coisa que não gostei da luta com Popó é que ele passou conjuntivite');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Tenho que parar de arrumar confusão', 'pt', null, 'Post com o rosto machucado depois da luta-exibição contra Popó, 2022', 'materia', 'https://www.lance.com.br/fora-de-campo/apos-luta-com-popo-whindersson-nunes-brinca-na-web-tenho-que-parar-de-arrumar-confusao.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Lance!'
from people where slug = 'whindersson-nunes'
  and not exists (select 1 from quotes where text = 'Tenho que parar de arrumar confusão');

-- Kéfera Buchmann
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Passei vergonha em rede nacional', 'pt', null, 'Vídeo no 5incominutos relembrando uma polêmica no Encontro, 2023', 'video', 'https://www.uai.com.br/app/entretenimento/famosos/2023/10/06/not-famosos,331209/cinco-anos-apos-polemica-kefera-se-pronuncia-sobre-o-caso-mansplaining.shtml', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Vídeo: https://www.youtube.com/watch?v=3ML-KtJJosg · Fonte: Estado de Minas / UAI'
from people where slug = 'kefera-buchmann'
  and not exists (select 1 from quotes where text = 'Passei vergonha em rede nacional');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Nunca imaginei ter que me explicar', 'pt', null, 'Desmentindo uma suposta ''bolsada'' de Vera Fischer numa festa, 2024', 'materia', 'https://www.terra.com.br/diversao/gente/nunca-imaginei-ter-que-me-explicar-diz-kefera-sobre-suposta-briga-com-vera-fisher,0413645963fdf7bbc3f9a1362cf1708cwm0s8aeu.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra'
from people where slug = 'kefera-buchmann'
  and not exists (select 1 from quotes where text = 'Nunca imaginei ter que me explicar');

-- Felipe Castanhari
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Recusei educadamente', 'pt', '2019-11-25', 'Tweet contando que recusou o convite para o BBB20, 2019', 'post', 'https://caras.com.br/tv/youtuber-castanhari-revela-ter-sido-convidado-para-bbb20-e-nega-convite-recusei-educadamente.phtml', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Caras'
from people where slug = 'felipe-castanhari'
  and not exists (select 1 from quotes where text = 'Recusei educadamente');

-- MrBeast
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu estou com dinheiro negativo agora', 'pt', null, 'Entrevista ao Wall Street Journal sobre a fortuna presa na empresa, 2026', 'entrevista', 'https://www.eonline.com/news/1427319/mrbeast-on-negative-bank-account-amid-s2-6-billion-net-worth', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I have negative money right now · Fonte: E! Online (repercutindo o WSJ)'
from people where slug = 'mrbeast'
  and not exists (select 1 from quotes where text = 'Eu estou com dinheiro negativo agora');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Mano, se você não viaja o tempo todo, a vida é muito mais fácil', 'pt', null, 'Podcast The Diary of a CEO, 2025', 'entrevista', 'https://www.benzinga.com/personal-finance/25/04/44968223/now-millions-hate-me-mrbeast-says-article-twisted-his-words-falsely-quoted-him-as-saying-lifes-easier-when-youre-broke', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): Bro, if you don''t travel constantly, life is so much easier. · Fonte: Benzinga'
from people where slug = 'mrbeast'
  and not exists (select 1 from quotes where text = 'Mano, se você não viaja o tempo todo, a vida é muito mais fácil');

-- Silvio Santos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quem quer dinheiro?', 'pt', null, 'Bordão dito ao jogar aviõezinhos de dinheiro para a plateia no SBT', 'materia', 'https://www.folhape.com.br/cultura/silvio-santos-relembre-os-10-bordoes-mais-marcantes-do-apresentador/355258/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Folha de Pernambuco'
from people where slug = 'silvio-santos'
  and not exists (select 1 from quotes where text = 'Quem quer dinheiro?');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'É namoro ou amizade?', 'pt', null, 'Bordão dos quadros de namoro de seus programas no SBT', 'materia', 'https://www.folhape.com.br/cultura/silvio-santos-relembre-os-10-bordoes-mais-marcantes-do-apresentador/355258/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Folha de Pernambuco'
from people where slug = 'silvio-santos'
  and not exists (select 1 from quotes where text = 'É namoro ou amizade?');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se ganha dinheiro com 10% de inspiração e 90% de transpiração.', 'pt', null, 'Resposta a Nelson Rubens sobre como se ganha dinheiro, 1988', 'materia', 'https://www.oliberal.com/cultura/10-frases-lendarias-de-silvio-santos-no-dia-em-que-ele-faria-95-anos-1.1061205', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: O Liberal (Estadão Conteúdo)'
from people where slug = 'silvio-santos'
  and not exists (select 1 from quotes where text = 'Se ganha dinheiro com 10% de inspiração e 90% de transpiração.');

-- Faustão
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ô loco, meu!', 'pt', null, 'Bordão do apresentador no Domingão do Faustão (TV Globo)', 'materia', 'https://www.tnh1.com.br/noticia/nid/faustao-troca-visual-formal-por-descolado-e-conquista-publico-da-web/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: TNH1 (Folhapress)'
from people where slug = 'faustao'
  and not exists (select 1 from quotes where text = 'Ô loco, meu!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Errou!', 'pt', null, 'Bordão do Domingão do Faustão, quando alguém errava uma resposta', 'materia', 'https://rollingstone.com.br/noticia/10-momentos-do-domingao-do-faustao-que-marcaram-tv-brasileira/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil'
from people where slug = 'faustao'
  and not exists (select 1 from quotes where text = 'Errou!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu deixo a vida não me levar, eu deixo a vida me atropelar.', 'pt', null, 'Entrevista ao Altas Horas sobre sua carreira não planejada', 'entrevista', 'https://www.tribunapr.com.br/mais-pop/eu-deixo-a-vida-nao-me-levar-eu-deixo-a-vida-me-atropelar-diz-faustao/', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Tribuna PR'
from people where slug = 'faustao'
  and not exists (select 1 from quotes where text = 'Eu deixo a vida não me levar, eu deixo a vida me atropelar.');

-- Galvão Bueno
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Haja coração!', 'pt', null, 'Bordão de narração em lances de tensão nos jogos da Seleção', 'materia', 'https://grandesnomesdapropaganda.com.br/danca-das-cadeiras/galvao-bueno-e-o-novo-contratado-da-band/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Grandes Nomes da Propaganda'
from people where slug = 'galvao-bueno'
  and not exists (select 1 from quotes where text = 'Haja coração!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'É tetra! É tetra!', 'pt', '1994-07-17', 'Narração da final da Copa de 1994, Brasil x Itália, na TV Globo', 'materia', 'https://www.gazetadopovo.com.br/esportes/galvao-frases-copa-do-mundo-1994/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Gazeta do Povo'
from people where slug = 'galvao-bueno'
  and not exists (select 1 from quotes where text = 'É tetra! É tetra!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Bem, amigos da Rede Globo', 'pt', null, 'Saudação de abertura das transmissões na TV Globo', 'materia', 'https://www.jornalopcao.com.br/copa-do-mundo-2022/copa-do-catar-marca-despedida-de-galvao-bueno-na-narracao-esportiva-444251/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Jornal Opção'
from people where slug = 'galvao-bueno'
  and not exists (select 1 from quotes where text = 'Bem, amigos da Rede Globo');

-- Ana Maria Braga
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Acorda, menina!', 'pt', null, 'Bordão de abertura do programa Mais Você (TV Globo)', 'materia', 'https://www.opovo.com.br/vidaearte/2022/06/28/acorda-menina-ana-maria-segue-com-bordao-apesar-de-novo-horario.html', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: O Povo'
from people where slug = 'ana-maria-braga'
  and not exists (select 1 from quotes where text = 'Acorda, menina!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se ex fosse bom, Deus não mandaria amar o próximo', 'pt', '2019-07-04', 'Pensamento do Dia no Mais Você, 2019', 'materia', 'https://www.metropoles.com/celebridades/ana-maria-braga-tira-onda-com-ex-namorados-em-pensamento-do-dia', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles'
from people where slug = 'ana-maria-braga'
  and not exists (select 1 from quotes where text = 'Se ex fosse bom, Deus não mandaria amar o próximo');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O mundo dá voltas, e isso explica por que tem tanta gente tonta por aí.', 'pt', '2026-08-17', 'Pensamento do Dia no Mais Você, 2026', 'materia', 'https://www.diariodolitoral.com.br/entretenimento/o-mundo-da-voltas-ana-maria-braga/', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Diário do Litoral'
from people where slug = 'ana-maria-braga'
  and not exists (select 1 from quotes where text = 'O mundo dá voltas, e isso explica por que tem tanta gente tonta por aí.');

-- Anitta
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu pratico idiomas flertando com as pessoas.', 'pt', null, 'Entrevista à Rolling Stone EUA, 2019', 'entrevista', 'https://www.tnh1.com.br/noticia/nid/anitta-diz-que-pratica-idiomas-flertando-com-homens-e-mulheres-e-relembra-otima-decada/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: TNH1 (Folhapress)'
from people where slug = 'anitta'
  and not exists (select 1 from quotes where text = 'Eu pratico idiomas flertando com as pessoas.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ninguém merece minha moral', 'pt', null, 'Entrevista ao De Frente com a Blogueirinha, ao dizer que não faria música para namorado, 2023', 'entrevista', 'https://www.opovo.com.br/divirtase/2023/10/12/anitta-diz-que-nao-faria-musica-para-namorado-ninguem-merece-minha-moral.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: O Povo'
from people where slug = 'anitta'
  and not exists (select 1 from quotes where text = 'Ninguém merece minha moral');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Os Bengals vão ganhar, com certeza.', 'pt', '2022-01-31', 'Palpite para o Super Bowl no The Tonight Show, de Jimmy Fallon, 2022', 'entrevista', 'https://www.hola.com/us/celebrities/20220201309118/anitta-knows-who-will-win-super-bowl', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): The Bengals going to win for sure. · Fonte: Hola! USA'
from people where slug = 'anitta'
  and not exists (select 1 from quotes where text = 'Os Bengals vão ganhar, com certeza.');

-- Zeca Pagodinho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Psicóloga pra quê? Tenho a Eliene, minha manicure', 'pt', null, 'Entrevista à Folha de S.Paulo, 2022', 'entrevista', 'https://www.agazeta.com.br/hz/tv-e-famosos/psicologa-pra-que-tenho-a-eliene-minha-manicure-diz-zeca-pagodinho-0422', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: A Gazeta (Folhapress)'
from people where slug = 'zeca-pagodinho'
  and not exists (select 1 from quotes where text = 'Psicóloga pra quê? Tenho a Eliene, minha manicure');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Álcool só na mão', 'pt', '2021-08-23', 'Vídeo nas redes após se recuperar da Covid-19, 2021', 'post', 'https://www.metropoles.com/celebridades/zeca-pagodinho-diz-que-mudou-apos-covid-19-alcool-so-na-mao', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles'
from people where slug = 'zeca-pagodinho'
  and not exists (select 1 from quotes where text = 'Álcool só na mão');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Vacina boa é a que vai no braço', 'pt', null, 'Post no Instagram, 2021', 'post', 'https://rollingstone.com.br/?p=119992', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil'
from people where slug = 'zeca-pagodinho'
  and not exists (select 1 from quotes where text = 'Vacina boa é a que vai no braço');

-- Rita Lee
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A vida é curta, e eu grossa', 'pt', null, 'Post no Twitter, entre 2010 e 2013', 'post', 'https://istoe.com.br/rainha-do-rock-e-do-sarcasmo-relembre-os-tweets-mais-acidos-de-rita-lee/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: IstoÉ'
from people where slug = 'rita-lee'
  and not exists (select 1 from quotes where text = 'A vida é curta, e eu grossa');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Sou minha única amiga e sou falsa', 'pt', null, 'Post no Twitter, entre 2010 e 2013', 'post', 'https://istoe.com.br/rainha-do-rock-e-do-sarcasmo-relembre-os-tweets-mais-acidos-de-rita-lee/', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: IstoÉ'
from people where slug = 'rita-lee'
  and not exists (select 1 from quotes where text = 'Sou minha única amiga e sou falsa');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Gosto das minhas rugas, são cicatrizes da vida. Eu respeito as minhas pelancas.', 'pt', null, 'Entrevista ao Fantástico (TV Globo) sobre envelhecer', 'entrevista', 'https://rollingstone.com.br/noticia/rita-lee-altera-data-de-aniversario-e-assume-que-esta-mais-velha-respeito-minhas-pelancas/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil'
from people where slug = 'rita-lee'
  and not exists (select 1 from quotes where text = 'Gosto das minhas rugas, são cicatrizes da vida. Eu respeito as minhas pelancas.');

-- Dilma Rousseff
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não vamos colocar meta. Vamos deixar a meta aberta, mas quando atingirmos a meta, vamos dobrar a meta.', 'pt', '2015-07-28', 'Lançamento do Pronatec Jovem Aprendiz, Palácio do Planalto, 2015', 'materia', 'https://www.folhavitoria.com.br/politica/noticia/08/2015/nao-vamos-colocar-meta-video-com-frase-dita-pela-presidente-dilma-vira-sucesso-nas-redes-sociais', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Folha Vitória'
from people where slug = 'dilma-rousseff'
  and not exists (select 1 from quotes where text = 'Não vamos colocar meta. Vamos deixar a meta aberta, mas quando atingirmos a meta, vamos dobrar a meta.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu estou saudando a mandioca, uma das maiores conquistas do Brasil.', 'pt', '2015-06-23', 'Discurso no lançamento dos I Jogos Mundiais dos Povos Indígenas, Brasília, 2015', 'discurso', 'https://acervo.socioambiental.org/acervo/noticias/mandioca-da-dilma-rir-de-quem', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Vídeo: https://www.youtube.com/watch?v=6R8p1H47eSY · Fonte: Instituto Socioambiental'
from people where slug = 'dilma-rousseff'
  and not exists (select 1 from quotes where text = 'Eu estou saudando a mandioca, uma das maiores conquistas do Brasil.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Vamos supor que vente mais à noite. Como é que eu faria para estocar isso?', 'pt', null, 'Entrevista coletiva na ONU, em Nova York, sobre energia eólica, 2015', 'entrevista', 'https://aredacao.com.br/em-discurso-na-onu-dilma-sugere-tecnologia-para-estocar-vento/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: A Redação'
from people where slug = 'dilma-rousseff'
  and not exists (select 1 from quotes where text = 'Vamos supor que vente mais à noite. Como é que eu faria para estocar isso?');

-- Lula
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O povo tem que voltar a comer um churrasquinho, a comer uma picanha e tomar uma cervejinha.', 'pt', null, 'Entrevista ao Jornal Nacional como candidato à Presidência, 2022', 'entrevista', 'https://www.correiobraziliense.com.br/politica/2022/08/5032120-lula-no-jn-o-povo-tem-que-voltar-a-comer-churrasquinho-e-picanha.html', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio Braziliense'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'O povo tem que voltar a comer um churrasquinho, a comer uma picanha e tomar uma cervejinha.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Lá, ela é um tsunami; aqui, se ela chegar, vai chegar uma marolinha que não dá nem para esquiar.', 'pt', '2008-10-04', 'Comentário sobre a crise financeira mundial, em São Bernardo do Campo (SP), 2008', 'materia', 'https://ndmais.com.br/politica/frases-de-lula-em-crises-de-marolinha-a-partida-de-truco/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: ND+'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Lá, ela é um tsunami; aqui, se ela chegar, vai chegar uma marolinha que não dá nem para esquiar.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Jesus teria que chamar Judas para uma coalizão.', 'pt', null, 'Entrevista à Folha de S.Paulo sobre como é governar o Brasil, 2009', 'entrevista', 'https://correiodoestado.com.br/cidades/jesus-teria-que-chamar-judas-para-uma-coalizacao-diz-lula-sobre-o-p/7512/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio do Estado'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Jesus teria que chamar Judas para uma coalizão.');

-- Jair Bolsonaro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'É só fazer cocô dia sim, dia não.', 'pt', null, 'Resposta a jornalista no Palácio da Alvorada sobre crescimento e meio ambiente, 2019', 'materia', 'https://www.cartacapital.com.br/politica/e-so-fazer-coco-dia-sim-dia-nao-diz-bolsonaro-sobre-poluicao/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CartaCapital'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'É só fazer cocô dia sim, dia não.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Imbrochável, imbrochável, imbrochável!', 'pt', '2022-09-07', 'Discurso a apoiadores no Bicentenário da Independência, em Brasília, 2022', 'discurso', 'https://www.cnnbrasil.com.br/politica/bolsonaro-puxa-coro-de-imbrochavel-em-discurso-no-dia-da-independencia/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CNN Brasil'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'Imbrochável, imbrochável, imbrochável!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O Paulo Guedes continua sendo o meu posto Ipiranga.', 'pt', null, 'Conversa com a imprensa no Palácio da Alvorada sobre o ministro da Economia', 'materia', 'https://www.moneytimes.com.br/bolsonaro-reforca-condicao-de-posto-ipiranga-de-paulo-guedes/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Money Times'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'O Paulo Guedes continua sendo o meu posto Ipiranga.');

-- Donald Trump
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Apesar da constante imprensa negativa covfefe', 'pt', '2017-05-31', 'Post no Twitter publicado logo após a meia-noite e apagado horas depois, 2017', 'post', 'https://edition.cnn.com/2017/05/31/politics/covfefe-trump-coverage', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): Despite the constant negative press covfefe · Fonte: CNN'
from people where slug = 'donald-trump'
  and not exists (select 1 from quotes where text = 'Apesar da constante imprensa negativa covfefe');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ninguém sabia que a saúde poderia ser tão complicada.', 'pt', '2017-02-27', 'Reunião com governadores na Casa Branca sobre a reforma da saúde, 2017', 'discurso', 'https://www.cnn.com/2017/02/27/politics/trump-health-care-complicated', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): Nobody knew health care could be so complicated. · Vídeo: https://www.youtube.com/watch?v=9rSLoNZv2ng · Fonte: CNN'
from people where slug = 'donald-trump'
  and not exists (select 1 from quotes where text = 'Ninguém sabia que a saúde poderia ser tão complicada.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Acho que isso seria considerado não inteligente, mas genial... e um gênio muito estável, aliás!', 'pt', '2018-01-06', 'Post no Twitter em resposta a um livro sobre os bastidores da Casa Branca, 2018', 'post', 'https://x.com/realDonaldTrump/status/949619270631256064', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I think that would qualify as not smart, but genius....and a very stable genius at that! · Fonte: X (@realDonaldTrump)'
from people where slug = 'donald-trump'
  and not exists (select 1 from quotes where text = 'Acho que isso seria considerado não inteligente, mas genial... e um gênio muito estável, aliás!');

-- Kanye West
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ei, Taylor, estou muito feliz por você, vou deixar você terminar, mas a Beyoncé teve um dos melhores clipes de todos os tempos.', 'pt', '2009-09-13', 'Interrompeu o discurso de Taylor Swift no MTV Video Music Awards, 2009', 'video', 'https://www.vice.com/en/article/on-this-day-in-2009-kanye-west-grabbed-the-mic-from-taylor-swift-at-the-mtv-vmas/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): Yo, Taylor, I''m really happy for you, I''ma let you finish, but Beyoncé had one of the best videos of all time. · Fonte: VICE'
from people where slug = 'kanye-west'
  and not exists (select 1 from quotes where text = 'Ei, Taylor, estou muito feliz por você, vou deixar você terminar, mas a Beyoncé teve um dos melhores clipes de todos os tempos.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu decidi que em 2020 vou concorrer à Presidência.', 'pt', '2015-08-30', 'Discurso ao receber o prêmio Video Vanguard no MTV VMAs, 2015', 'discurso', 'https://time.com/4016623/vmas-2015-kanye-west-speech-president-2020/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I have decided in 2020 to run for president. · Fonte: TIME'
from people where slug = 'kanye-west'
  and not exists (select 1 from quotes where text = 'Eu decidi que em 2020 vou concorrer à Presidência.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu sou Warhol. Eu sou o artista número um mais impactante da nossa geração.', 'pt', null, 'Entrevista ao radialista Sway Calloway, na SiriusXM, 2013', 'entrevista', 'https://www.spinmagazine.com/2013/11/kanye-west-sway-interview-screaming-fashion-shakespeare-warhol/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I am Warhol. I am the number one most impactful artist of our generation. · Fonte: SPIN'
from people where slug = 'kanye-west'
  and not exists (select 1 from quotes where text = 'Eu sou Warhol. Eu sou o artista número um mais impactante da nossa geração.');

commit;
