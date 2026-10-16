-- Carga 2: frases polêmicas e difíceis de adivinhar. Tudo entra como RASCUNHO:
-- nenhuma frase fica jogável até você aprovar em /admin → Frases, e as fotos em /admin → Fotos
-- (botão "Buscar fotos de todos"). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- 1) Remove os dados de exemplo inventados (e as partidas de teste que usaram essas frases).
delete from game_rounds where quote_id in (select id from quotes where is_demo);
delete from daily_challenges d where exists (select 1 from quotes q where q.is_demo and q.id = any (d.quote_ids));
delete from quotes where is_demo;
delete from people where is_demo;

-- 1b) Bordões óbvios da carga 1 saem da fila: viram "rejeitadas" (só se ainda forem rascunho;
--     o que você já aprovou não é tocado). Dá para reabrir qualquer uma pelo painel.
update quotes set status = 'rejected', review_note = 'Bordão óbvio: fora do estilo do jogo (polêmica ou difícil de adivinhar)'
where status = 'draft' and text in (
  'Quem quer dinheiro?', 'É namoro ou amizade?', 'Ô loco, meu!', 'Errou!',
  'Haja coração!', 'É tetra! É tetra!', 'Bem, amigos da Rede Globo', 'Acorda, menina!',
  'Se me atacar, eu vou atacar', 'Alô, alô, graças a Deus', 'Ai, que loucura!', 'Travou, Maitê!',
  'O Brasil tá lascado', 'Ai, Brasil!', 'Meteu essa?', 'Que papinho, hein?'
);

-- 2) Pessoas novas (sem foto; a foto vem pelo painel). Quem já existe fica como está.
insert into people (name, slug, category, country, bio_short) values
  ('Romário', 'romario', 'futebol', 'BR', 'Ex-atacante, herói do tetra em 1994'),
  ('Edmundo', 'edmundo', 'futebol', 'BR', 'O ''Animal'', ex-atacante de Vasco e Palmeiras'),
  ('Renato Gaúcho', 'renato-gaucho', 'futebol', 'BR', 'Ex-atacante e técnico, ídolo do Grêmio'),
  ('Felipe Melo', 'felipe-melo', 'futebol', 'BR', 'Volante ''Pitbull'', ex-Palmeiras e Seleção'),
  ('Neymar', 'neymar', 'futebol', 'BR', 'Atacante, maior artilheiro da Seleção'),
  ('Pelé', 'pele', 'futebol', 'BR', 'Rei do futebol, tricampeão mundial'),
  ('Ronaldo Fenômeno', 'ronaldo-fenomeno', 'futebol', 'BR', 'Bicampeão mundial, artilheiro do penta'),
  ('Neto', 'neto', 'futebol', 'BR', 'Ex-meia do Corinthians e apresentador da Band'),
  ('José Mourinho', 'jose-mourinho', 'gringos', 'PT', 'Técnico português, o ''Special One'''),
  ('Zlatan Ibrahimović', 'zlatan-ibrahimovic', 'gringos', 'SE', 'Atacante sueco, ex-PSG, Milan e United'),
  ('Cristiano Ronaldo', 'cristiano-ronaldo', 'gringos', 'PT', 'Atacante português, 5 vezes melhor do mundo'),
  ('Diego Maradona', 'diego-maradona', 'gringos', 'AR', 'Campeão mundial em 1986, ídolo argentino'),
  ('Lionel Messi', 'lionel-messi', 'gringos', 'AR', 'Oito Bolas de Ouro, campeão mundial 2022'),
  ('Virginia Fonseca', 'virginia-fonseca', 'internet', 'BR', 'Influenciadora e empresária, dona da WePink'),
  ('Felipe Neto', 'felipe-neto', 'internet', 'BR', 'Youtuber e empresário carioca'),
  ('Gil do Vigor', 'gil-do-vigor', 'internet', 'BR', 'Economista e ex-BBB 21'),
  ('Gretchen', 'gretchen', 'internet', 'BR', 'Cantora, ''Rainha do Bumbum'' e rainha dos memes'),
  ('Jojo Todynho', 'jojo-todynho', 'internet', 'BR', 'Cantora e influenciadora carioca'),
  ('Kéfera Buchmann', 'kefera-buchmann', 'internet', 'BR', 'Youtuber, atriz e escritora curitibana'),
  ('Karol Conká', 'karol-conka', 'internet', 'BR', 'Rapper curitibana, ex-BBB 21'),
  ('Whindersson Nunes', 'whindersson-nunes', 'internet', 'BR', 'Humorista e youtuber piauiense'),
  ('Carlinhos Maia', 'carlinhos-maia', 'internet', 'BR', 'Humorista e influenciador alagoano'),
  ('Casimiro', 'casimiro', 'internet', 'BR', 'Streamer e fundador da CazéTV'),
  ('Kanye West', 'kanye-west', 'gringos', 'US', 'Rapper, produtor e estilista americano'),
  ('Kim Kardashian', 'kim-kardashian', 'gringos', 'US', 'Empresária, reality star e dona da Skims'),
  ('Elon Musk', 'elon-musk', 'gringos', 'US', 'Bilionário dono da Tesla, SpaceX e X'),
  ('Madonna', 'madonna', 'gringos', 'US', 'Cantora americana, a ''Rainha do Pop'''),
  ('Silvio Santos', 'silvio-santos', 'tv', 'BR', 'Apresentador e dono do SBT'),
  ('Faustão', 'faustao', 'tv', 'BR', 'Fausto Silva, apresentador do Domingão'),
  ('Galvão Bueno', 'galvao-bueno', 'tv', 'BR', 'Narrador esportivo, voz das Copas'),
  ('Ana Maria Braga', 'ana-maria-braga', 'tv', 'BR', 'Apresentadora do Mais Você, na Globo'),
  ('Xuxa', 'xuxa', 'tv', 'BR', 'Rainha dos Baixinhos, apresentadora e cantora'),
  ('Luciana Gimenez', 'luciana-gimenez', 'tv', 'BR', 'Apresentadora da RedeTV! e ex-modelo'),
  ('Datena', 'datena', 'tv', 'BR', 'Apresentador e ex-candidato a prefeito de SP'),
  ('Tim Maia', 'tim-maia', 'musica', 'BR', 'Cantor e compositor, rei do soul brasileiro'),
  ('Rita Lee', 'rita-lee', 'musica', 'BR', 'Cantora e compositora, rainha do rock brasileiro'),
  ('Ney Matogrosso', 'ney-matogrosso', 'musica', 'BR', 'Cantor, ex-Secos & Molhados'),
  ('Lobão', 'lobao', 'musica', 'BR', 'Roqueiro carioca, polemista e crítico da MPB'),
  ('Caetano Veloso', 'caetano-veloso', 'musica', 'BR', 'Cantor e compositor baiano, ícone da Tropicália'),
  ('Anitta', 'anitta', 'musica', 'BR', 'Cantora pop carioca de carreira internacional'),
  ('Zeca Pagodinho', 'zeca-pagodinho', 'musica', 'BR', 'Sambista carioca de Xerém'),
  ('Roberto Carlos', 'roberto-carlos', 'musica', 'BR', 'O ''Rei'' da música romântica brasileira'),
  ('Fábio Jr.', 'fabio-jr', 'musica', 'BR', 'Cantor romântico e ator, casado sete vezes'),
  ('Gusttavo Lima', 'gusttavo-lima', 'musica', 'BR', 'Cantor sertanejo goiano, o ''Embaixador'''),
  ('Ivete Sangalo', 'ivete-sangalo', 'musica', 'BR', 'Cantora baiana, rainha do axé'),
  ('Gilberto Gil', 'gilberto-gil', 'musica', 'BR', 'Cantor baiano, tropicalista e ex-ministro'),
  ('Luan Santana', 'luan-santana', 'musica', 'BR', 'Cantor sertanejo sul-mato-grossense'),
  ('Pabllo Vittar', 'pabllo-vittar', 'musica', 'BR', 'Drag queen e cantora pop maranhense'),
  ('Jair Bolsonaro', 'jair-bolsonaro', 'politica', 'BR', 'Ex-presidente do Brasil (2019–2022)'),
  ('Lula', 'lula', 'politica', 'BR', 'Presidente do Brasil (2003–2010 e desde 2023)'),
  ('Dilma Rousseff', 'dilma-rousseff', 'politica', 'BR', 'Ex-presidente do Brasil (2011–2016)'),
  ('Donald Trump', 'donald-trump', 'politica', 'US', 'Presidente dos Estados Unidos'),
  ('Eduardo Bolsonaro', 'eduardo-bolsonaro', 'politica', 'BR', 'Deputado federal, filho de Jair Bolsonaro'),
  ('Damares Alves', 'damares-alves', 'politica', 'BR', 'Senadora e ex-ministra'),
  ('Michel Temer', 'michel-temer', 'politica', 'BR', 'Ex-presidente do Brasil (2016–2018)'),
  ('Janja', 'janja', 'politica', 'BR', 'Primeira-dama do Brasil desde 2023'),
  ('Ciro Gomes', 'ciro-gomes', 'politica', 'BR', 'Ex-ministro e ex-governador do Ceará')
on conflict (slug) do nothing;

-- 3) Frases (status draft).

-- Romário
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Agora a corte está toda feliz: o rei, o príncipe e o bobo.', 'pt', '2000-03-29', 'Após Vasco 4x1 Olaria, respondendo a Edmundo, que o chamara de ''príncipe'', 2000', 'entrevista', 'https://www.netvasco.com.br/n/247776/ha-20-anos-romario-alfinetava-edmundo-agora-a-corte-esta-toda-feliz-o-rei-o-principe-e-o-bobo-relembre', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: NetVasco · Por que: Chamou o colega de ataque Edmundo de ''bobo'' da corte · Obs.: Algumas fontes trocam a ordem dos títulos'
from people where slug = 'romario'
  and not exists (select 1 from quotes where text = 'Agora a corte está toda feliz: o rei, o príncipe e o bobo.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Infelizmente, ele continua com esse ciúme bobo. Isso é babaquice.', 'pt', null, 'À colunista Marluci Martins (UOL), depois de Edmundo chamá-lo de vaidoso, 2021', 'entrevista', 'https://www.netvasco.com.br/n/279005/romario-responde-edmundo-infelizmente-ele-continua-com-esse-ciume-bobo.-isso-e-babaquice', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: NetVasco (reproduzindo UOL) · Por que: Briga pública entre ídolos do Vasco'
from people where slug = 'romario'
  and not exists (select 1 from quotes where text = 'Infelizmente, ele continua com esse ciúme bobo. Isso é babaquice.');

-- Edmundo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Pedrinho me traiu, ele é traidor. E eu não tolero, porque eu nunca traí ninguém', 'pt', null, 'Live no canal Mundo Ed, sobre o presidente do Vasco, 2025', 'video', 'https://www.netvasco.com.br/n/361728/edmundo-pedrinho-me-traiu-ele-e-traidor-e-eu-nao-tolero-porque-eu-nunca-trai-ninguem-veja-video', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: NetVasco · Por que: Ataque ao presidente do clube do coração'
from people where slug = 'edmundo'
  and not exists (select 1 from quotes where text = 'Pedrinho me traiu, ele é traidor. E eu não tolero, porque eu nunca traí ninguém');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A minha mulher eu já traí, verdade', 'pt', null, 'Na mesma live em que dizia nunca ter traído ninguém, 2025', 'video', 'https://www.correio24horas.com.br/esportes/edmundo-confessa-traicao-em-video-criticando-presidente-do-vasco-posso-ser-todo-errado-0525', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio (BA) · Por que: Confissão ao vivo que virou meme'
from people where slug = 'edmundo'
  and not exists (select 1 from quotes where text = 'A minha mulher eu já traí, verdade');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Tenho raiva das pessoas', 'pt', null, 'No podcast Flow Sport Club, sobre a passagem pelo Flamengo', 'entrevista', 'https://www.lance.com.br/fora-de-campo/edmundo-relembra-passado-e-nega-ressentimento-com-flamengo-mas-diz-tenho-raiva-das-pessoas.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Lance! · Por que: Mágoa com pessoas do Flamengo'
from people where slug = 'edmundo'
  and not exists (select 1 from quotes where text = 'Tenho raiva das pessoas');

-- Renato Gaúcho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quem precisa aprender tem que estudar, ir para a Europa.', 'pt', null, 'Ao voltar ao Grêmio, respondendo a críticas de que não estudava, 2016', 'entrevista', 'https://www.gazetaesportiva.com/gremio/renato-nao-se-ve-desatualizado-futebol-e-como-andar-de-bicicleta/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Gazeta Esportiva · Por que: Ironizou os técnicos que vão estudar na Europa'
from people where slug = 'renato-gaucho'
  and not exists (select 1 from quotes where text = 'Quem precisa aprender tem que estudar, ir para a Europa.');

-- Felipe Melo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se tiver de dar porrada, eu darei porrada. Se tiver de dar tapa na cara de uruguaio, eu darei.', 'pt', null, 'Apresentação no Palmeiras, antes de enfrentar o Peñarol na Libertadores, 2017', 'entrevista', 'https://www.palmeiras.com.br/noticias/adaptado-melo-promete-luta-pelo-palmeiras-e-avisa-queremos-fazer-historia', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Site oficial do Palmeiras · Por que: Provocação que antecedeu a briga em Montevidéu'
from people where slug = 'felipe-melo'
  and not exists (select 1 from quotes where text = 'Se tiver de dar porrada, eu darei porrada. Se tiver de dar tapa na cara de uruguaio, eu darei.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Muita gente imagina que não gosto de uruguaio, mas não é verdade', 'pt', null, 'Na chegada do uruguaio Matías Viña ao Palmeiras, 2020', 'entrevista', 'https://www.gazetaesportiva.com/?p=2833954', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Gazeta Esportiva · Por que: Inesperada de quem prometeu tapa em uruguaio'
from people where slug = 'felipe-melo'
  and not exists (select 1 from quotes where text = 'Muita gente imagina que não gosto de uruguaio, mas não é verdade');

-- Neymar
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Nós vivemos um inferno, tanto ele quanto eu', 'pt', '2023-09-03', 'Ao Esporte Espetacular, sobre ele e Messi no PSG, 2023', 'entrevista', 'https://www.correiobraziliense.com.br/esportes/2023/09/5122553-neymar-diz-que-viveu-um-inferno-no-psg-assim-como-messi.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio Braziliense (AFP) · Por que: Detonou o ex-clube logo após sair'
from people where slug = 'neymar'
  and not exists (select 1 from quotes where text = 'Nós vivemos um inferno, tanto ele quanto eu');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Falaram demais e foram para casa', 'pt', '2018-07-02', 'Após Brasil 2x0 México nas oitavas da Copa, sobre os mexicanos, 2018', 'entrevista', 'https://jornaldebrasilia.com.br/torcida/neymar-diz-que-mexicanos-falaram-demais-e-foram-para-casa/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Jornal de Brasília · Por que: Provocação aos eliminados'
from people where slug = 'neymar'
  and not exists (select 1 from quotes where text = 'Falaram demais e foram para casa');

-- Pelé
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O brasileiro não sabe votar', 'pt', null, 'Entrevista durante a ditadura militar, anos 1970', 'entrevista', 'https://www.correiobraziliense.com.br/esportes/2022/12/5062514-pele-relembre-frases-marcantes-e-polemicas-do-rei-do-futebol.html', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio Braziliense · Por que: Frase política que o perseguiu por décadas · Obs.: A fala original pode ter sido mais longa'
from people where slug = 'pele'
  and not exists (select 1 from quotes where text = 'O brasileiro não sabe votar');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Antes de falar do Pelé, Maradona precisa pedir autorização para Zico, Sócrates, Romário, Tostão, Rivelino', 'pt', null, 'Respondendo a Maradona, que se dizia o melhor do mundo, 2000', 'entrevista', 'https://www.correiobraziliense.com.br/esportes/2022/12/5062514-pele-relembre-frases-marcantes-e-polemicas-do-rei-do-futebol.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio Braziliense · Por que: Provocação ao maior rival'
from people where slug = 'pele'
  and not exists (select 1 from quotes where text = 'Antes de falar do Pelé, Maradona precisa pedir autorização para Zico, Sócrates, Romário, Tostão, Rivelino');

-- Ronaldo Fenômeno
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não se faz Copa do Mundo com hospital', 'pt', null, 'Como membro do Comitê Organizador da Copa de 2014, 2011', 'video', 'https://rollingstone.com.br/noticia/depois-de-video-ressurgir-na-internet-ronaldo-explica-declaracao-sobre-copa-do-mundo-ser-feita-com-estadio-nao-com-hospi/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil · Por que: Virou símbolo dos protestos contra os gastos da Copa · Obs.: Variante: ''Copa do Mundo se faz com estádio, não com hospital'''
from people where slug = 'ronaldo-fenomeno'
  and not exists (select 1 from quotes where text = 'Não se faz Copa do Mundo com hospital');

-- Neto
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O que falei, 95% do Brasil também falou', 'pt', null, 'Sobre a queixa-crime de Tite por injúria após a eliminação na Copa, 2022', 'video', 'https://www.lance.com.br/fora-de-campo/neto-fala-sobre-queixa-crime-de-tite-o-que-falei-95-do-brasil-tambem-falou.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Lance! · Por que: Não recuou após ser processado por Tite'
from people where slug = 'neto'
  and not exists (select 1 from quotes where text = 'O que falei, 95% do Brasil também falou');

-- José Mourinho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ele é um especialista em fracasso.', 'pt', '2014-02-14', 'No Chelsea, sobre Arsène Wenger e o jejum do Arsenal, 2014', 'entrevista', 'https://www.si.com/si-wire/2014/02/14/jose-mourinho-arsene-wenger-specialist-failure', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): He is a specialist in failure. · Fonte: Sports Illustrated (Reuters) · Por que: Humilhou um técnico rival'
from people where slug = 'jose-mourinho'
  and not exists (select 1 from quotes where text = 'Ele é um especialista em fracasso.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Acho que ele é uma dessas pessoas que são voyeurs.', 'pt', null, 'Sobre Wenger falar demais do Chelsea, 2005', 'entrevista', 'https://tds-images.thedailystar.net/2005/11/01/d51101040834.htm', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I think he is one of these people who is a voyeur. · Fonte: The Daily Star · Por que: Chamou Wenger de voyeur e depois se desculpou'
from people where slug = 'jose-mourinho'
  and not exists (select 1 from quotes where text = 'Acho que ele é uma dessas pessoas que são voyeurs.');

-- Zlatan Ibrahimović
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Uma Copa do Mundo sem mim não vale a pena assistir.', 'pt', null, 'Após a Suécia perder a repescagem para Portugal, 2013', 'post', 'https://www.thelocal.com/20141029/top-ten-quotes-from-zlatan-ibrahimovic', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): A World Cup without me isn''t worth watching. · Fonte: The Local (Suécia) · Por que: Ego acima da própria Copa'
from people where slug = 'zlatan-ibrahimovic'
  and not exists (select 1 from quotes where text = 'Uma Copa do Mundo sem mim não vale a pena assistir.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não consigo deixar de rir de como eu sou perfeito.', 'pt', null, 'Frase listada pela ESPN entre as marcantes da carreira', 'materia', 'https://global.espn.com/football/story/_/id/37457165/zlatan-ibrahimovic-best-quotes-retires', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I can''t help but laugh at how perfect I am · Fonte: ESPN · Por que: Arrogância pura'
from people where slug = 'zlatan-ibrahimovic'
  and not exists (select 1 from quotes where text = 'Não consigo deixar de rir de como eu sou perfeito.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Zlatan não faz testes.', 'pt', null, 'Relembrando quando recusou um teste no Arsenal, 2012', 'entrevista', 'https://www.thelocal.se/20120305/39486', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): Zlatan doesn''t do auditions · Fonte: The Local (Suécia) · Por que: Recusou teste num gigante inglês'
from people where slug = 'zlatan-ibrahimovic'
  and not exists (select 1 from quotes where text = 'Zlatan não faz testes.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quando você me compra, está comprando uma Ferrari.', 'pt', null, 'Na autobiografia ''Eu sou Zlatan'', criticando Guardiola, 2011', 'materia', 'https://africa.espn.com/football/story/_/id/37560525/zlatan-ibrahimovic-did-not-problem-pep-guardiola-had-one-me', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): When you buy me, you are buying a Ferrari. · Fonte: ESPN · Por que: Disse que Guardiola o pilotou como um Fiat'
from people where slug = 'zlatan-ibrahimovic'
  and not exists (select 1 from quotes where text = 'Quando você me compra, está comprando uma Ferrari.');

-- Cristiano Ronaldo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Sou o melhor jogador da história, nos bons e nos maus momentos.', 'pt', null, 'À France Football, após a quinta Bola de Ouro, 2017', 'entrevista', 'https://africa.espn.com/football/real-madrid/story/3301942/cristiano-ronaldo-says-i-am-the-best-player-in-history-upon-fifth-ballon-dor', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I am the best player in history, in both good and bad times. · Fonte: ESPN · Por que: Colocou-se acima de Pelé, Maradona e Messi'
from people where slug = 'cristiano-ronaldo'
  and not exists (select 1 from quotes where text = 'Sou o melhor jogador da história, nos bons e nos maus momentos.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A liga saudita é melhor que a MLS.', 'pt', '2023-07-17', 'Após amistoso do Al Nassr, dias depois de Messi ir para o Inter Miami, 2023', 'entrevista', 'https://gulfnews.com/sport/football/ronaldo-says-saudi-pro-league-now-better-than-mls-after-messis-move-to-inter-miami-1.1689671730920', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): The Saudi league is better than MLS · Fonte: Gulf News · Por que: Alfinetada indireta em Messi'
from people where slug = 'cristiano-ronaldo'
  and not exists (select 1 from quotes where text = 'A liga saudita é melhor que a MLS.');

-- Diego Maradona
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Um pouco com a cabeça de Maradona e outro pouco com a mão de Deus', 'pt', '1986-06-22', 'Após o gol de mão contra a Inglaterra na Copa do México, 1986', 'entrevista', 'https://www.tvazteca.com/aztecadeportes/que-es-mano-de-dios-diego-maradona-partido-inglaterra/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (es): un poco con la cabeza de Maradona y otro poco con la mano de Dios · Fonte: TV Azteca · Por que: Justificou um gol ilegal invocando Deus'
from people where slug = 'diego-maradona'
  and not exists (select 1 from quotes where text = 'Um pouco com a cabeça de Maradona e outro pouco com a mão de Deus');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Para quem não acreditava, para os que não acreditaram, com o perdão das damas, que chupem e que continuem chupando.', 'pt', '2009-10-14', 'Como técnico da Argentina, após a classificação para a Copa, 2009', 'entrevista', 'https://www.eluniverso.com/2009/10/15/1/1372/prensa-argentina-condena-exabruptos-maradona.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (es): Al que no creía, a los que no creyeron, con perdón de las damas, que la chupen y que la sigan chupando. · Fonte: El Universo · Por que: Ofensa à imprensa que rendeu punição da FIFA'
from people where slug = 'diego-maradona'
  and not exists (select 1 from quotes where text = 'Para quem não acreditava, para os que não acreditaram, com o perdão das damas, que chupem e que continuem chupando.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não me surpreende, que volte para o museu', 'pt', null, 'Na Copa de 2010, respondendo a críticas de Pelé, 2010', 'entrevista', 'https://cooperativa.cl/noticias/deportes/mundiales-de-futebol/sudafrica-2010/diego-armando-maradona-que-pele-vuelva-al-museo-qu/2010-06-16/092958.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (es): No me sorprende, que vuelva al museo · Fonte: Cooperativa (EFE) · Por que: Mandou Pelé ''para o museu'''
from people where slug = 'diego-maradona'
  and not exists (select 1 from quotes where text = 'Não me surpreende, que volte para o museu');

-- Lionel Messi
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O que está olhando, bobo? Vai pra lá', 'pt', '2022-12-09', 'Na Copa de 2022, a Weghorst durante entrevista após Argentina x Holanda', 'video', 'https://elgrafico.com.ar/articulo/mundial-qatar-2022/72440/la-increible-afirmacion-de-anda-pa-alla-bobo-a-un-anio-del-mundial', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (es): ¿Qué mirás, bobo? Andá pa'' allá · Fonte: El Gráfico · Por que: Lado agressivo raro do Messi'
from people where slug = 'lionel-messi'
  and not exists (select 1 from quotes where text = 'O que está olhando, bobo? Vai pra lá');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Van Gaal vende que joga bem futebol e hoje meteu chutão.', 'pt', '2022-12-09', 'Na zona mista após eliminar a Holanda, Copa de 2022', 'entrevista', 'https://espndeportes.espn.com/futbol/mundial/nota/_/id/12547490/louis-van-gaal-lionel-messi-paises-bajos-argentina-campeon-premeditado', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (es): Van Gaal vende que juega bien al fútbol y hoy metió pelotazos · Fonte: ESPN Deportes · Por que: Atacou o técnico adversário'
from people where slug = 'lionel-messi'
  and not exists (select 1 from quotes where text = 'Van Gaal vende que joga bem futebol e hoje meteu chutão.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não temos que ser parte desta corrupção', 'pt', '2019-07-06', 'Após a disputa de 3º lugar da Copa América contra o Chile, 2019', 'entrevista', 'https://www.biobiochile.cl/especial/copa-america/notas/2019/07/06/lionel-messi-exploto-contra-la-conmebol-nosotros-no-tenemos-que-ser-parte-de-esta-corrupcion.shtml', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (es): No tenemos que ser parte de esta corrupción · Fonte: BioBioChile · Por que: Acusou a Conmebol e foi suspenso'
from people where slug = 'lionel-messi'
  and not exists (select 1 from quotes where text = 'Não temos que ser parte desta corrupção');

-- Virginia Fonseca
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Deus abençoe nossa audiência, bora para cima', 'pt', '2025-05-13', 'Abertura do depoimento de Virginia à CPI das Bets no Senado, em maio de 2025.', 'materia', 'https://www.metropoles.com/brasil/virginia-provoca-risos-em-abertura-de-cpi-deus-abencoe-a-audiencia', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Saudação de stories usada numa CPI do Senado · Obs.: A manchete do Metrópoles traz ''Deus abençoe a audiência''; a versão completa ''nossa audiência, bora para cima'' apareceu no resumo da busca. Confira no texto.'
from people where slug = 'virginia-fonseca'
  and not exists (select 1 from quotes where text = 'Deus abençoe nossa audiência, bora para cima');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ganhar dinheiro é mais divertido', 'pt', '2025-05-13', 'Na CPI das Bets em 2025, ao responder se apostar e correr o risco de perder era divertido.', 'materia', 'https://www.terra.com.br/economia/tietada-confusao-bronca-saiba-como-foi-o-depoimento-de-virginia-a-cpi-das-bets,30421c66f98b0da702a8c4a1ccca9d88z17bbseo.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Sinceridade inesperada num depoimento sobre bets'
from people where slug = 'virginia-fonseca'
  and not exists (select 1 from quotes where text = 'Ganhar dinheiro é mais divertido');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Mas eu não vou mentir que quando eu vou para Las Vegas eu amo cassino', 'pt', '2025-05-13', 'Na CPI das Bets em 2025, ao comentar se jogava em cassinos.', 'materia', 'https://www.terra.com.br/economia/tietada-confusao-bronca-saiba-como-foi-o-depoimento-de-virginia-a-cpi-das-bets,30421c66f98b0da702a8c4a1ccca9d88z17bbseo.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Confissão de quem divulgava apostas, dita na CPI'
from people where slug = 'virginia-fonseca'
  and not exists (select 1 from quotes where text = 'Mas eu não vou mentir que quando eu vou para Las Vegas eu amo cassino');

-- Felipe Neto
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ninguém mandou ser burro e ganancioso', 'pt', null, 'Post no X em 2026, após a medida provisória que proibiu bets, comentando que já tinha divulgado casas de apostas.', 'post', 'https://www.metropoles.com/celebridades/felipe-neto-lamenta-ter-divulgado-bets-burro-e-ganancioso', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Autocrítica pesada de um dos maiores youtubers do país · Obs.: A manchete traz ''Burro e ganancioso''. A frase completa veio do resumo da busca. A matéria cita a sexta (25/9).'
from people where slug = 'felipe-neto'
  and not exists (select 1 from quotes where text = 'Ninguém mandou ser burro e ganancioso');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Pior ano, mas foi o que mais ganhei dinheiro', 'pt', null, 'Post de Natal de 2022 no Twitter em que fez um balanço do ano e criticou mudanças no YouTube.', 'post', 'https://www.terra.com.br/diversao/gente/pior-ano-mas-foi-o-que-mais-ganhei-dinheiro-diz-felipe-neto,a954184f078f84eea8b6efcc416f03e341w9li2q.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Reclamar do ano e ostentar o lucro na mesma frase · Obs.: Visto como manchete entre aspas; o texto original do tuíte pode ser diferente.'
from people where slug = 'felipe-neto'
  and not exists (select 1 from quotes where text = 'Pior ano, mas foi o que mais ganhei dinheiro');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Perdão por ter propagado o antipetismo', 'pt', null, 'Encontro com a ex-presidente Dilma Rousseff, quando pediu desculpas por críticas passadas ao PT.', 'materia', 'https://www.terra.com.br/noticias/eleicoes/felipe-neto-encontra-dilma-e-pede-desculpas-perdao-por-ter-propagado-o-antipetismo,cd3908ba862f86a5e21c55f4c6b1ca148tdhy7si.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Ex-crítico do PT pedindo perdão a Dilma em pessoa · Obs.: Visto só na manchete. A data não aparece nos resultados (provavelmente 2022); confira antes de publicar.'
from people where slug = 'felipe-neto'
  and not exists (select 1 from quotes where text = 'Perdão por ter propagado o antipetismo');

-- Gil do Vigor
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Vou subir a rampa de terno rosa', 'pt', null, 'No podcast Podpah em 2023, ao dizer que quer ser presidente do Brasil.', 'entrevista', 'https://www.cnnbrasil.com.br/entretenimento/gil-do-vigor-diz-em-podcast-que-quer-ser-presidente-do-brasil-vou-subir-a-rampa-de-terno-rosa/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CNN Brasil · Por que: Ex-BBB já escolhendo o look da posse presidencial · Obs.: Frase da manchete da CNN Brasil. Outra versão relatada: ''Amigo, eu vou subir de terno rosa porque ele faz a subida de terno rosa dele''.'
from people where slug = 'gil-do-vigor'
  and not exists (select 1 from quotes where text = 'Vou subir a rampa de terno rosa');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Nunca foi um objetivo de vida, mas hoje em dia eu penso que trabalhar e presidir o Banco Central seria um sonho, que nunca foi palpável', 'pt', null, 'Entrevista à #RedeBBB após sair do BBB 21, em 2021; o próprio Banco Central respondeu nas redes.', 'entrevista', 'https://www.terra.com.br/diversao/gente/gil-do-bbb-diz-que-quer-ser-presidente-do-banco-central,dec897cecead96d6d650dd0278e39d6dd7nqtuju.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Participante de reality querendo comandar o Banco Central · Obs.: A redação exata foi vista no resumo da busca (Terra e Diário do Nordeste). Também há matéria no Metrópoles: https://www.metropoles.com/colunas/pipocando/salvacao-para-a-economia-gil-revela-desejo-de-presidir-banco-central'
from people where slug = 'gil-do-vigor'
  and not exists (select 1 from quotes where text = 'Nunca foi um objetivo de vida, mas hoje em dia eu penso que trabalhar e presidir o Banco Central seria um sonho, que nunca foi palpável');

-- Gretchen
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu garanto pelo menos cinco que não se encaixam nisso', 'pt', null, 'Resposta a Luana Piovani, que tinha dito que homens não se apaixonam; Gretchen já teve mais de 15 casamentos.', 'post', 'https://www.terra.com.br/diversao/gretchen-responde-criticas-de-luana-piovani-sobre-homens-e-amor,ac6031be9291502207bef1b101bf79430lx3nobm.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Garantia de quem tem experiência de sobra no assunto · Obs.: Data não confirmada.'
from people where slug = 'gretchen'
  and not exists (select 1 from quotes where text = 'Eu garanto pelo menos cinco que não se encaixam nisso');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu tenho um ódio mortal de quando as pessoas falam disso', 'pt', null, 'No De Frente com Blogueirinha, em 2024, sobre o episódio com Van Damme no Domingo Legal de 2001.', 'entrevista', 'https://www.terra.com.br/diversao/tv/pouca-gente-lembra-mas-gretchen-admitiu-odio-mortal-de-situacao-conturbada-na-tv-envolvendo-um-icone-de-hollywood,a486d402c9e8bb50d6f8f814214b0cc6ajtpf4xm.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Rancor de mais de 20 anos de um astro de Hollywood · Obs.: A redação exata foi vista no resumo da busca.'
from people where slug = 'gretchen'
  and not exists (select 1 from quotes where text = 'Eu tenho um ódio mortal de quando as pessoas falam disso');

-- Jojo Todynho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Sou uma mulher preta de direita', 'pt', '2024-09-15', 'Live no Instagram em 2024, após críticas por posar com Michelle Bolsonaro.', 'video', 'https://www.terra.com.br/diversao/jojo-todynho-se-declara-mulher-preta-de-direita,642642f6a9a26355cae54d55fb49bc7emuidzssi.html', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Virada política que surpreendeu os fãs · Obs.: Os veículos variam na redação (''Sou preta, sim, e sou de direita''). A manchete traz ''mulher preta de direita''.'
from people where slug = 'jojo-todynho'
  and not exists (select 1 from quotes where text = 'Sou uma mulher preta de direita');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Em 2026, estou vindo', 'pt', '2024-09-15', 'Na mesma live de 2024, ao anunciar que pretendia se candidatar nas eleições de 2026.', 'video', 'https://www.terra.com.br/diversao/gente/jojo-todynho-choca-com-seu-posicionamento-politico-e-afirma-em-2026-estou-vindo,efddcd175b008b56f412254d816db578vqp4fwea.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Promessa de candidatura que depois ela abandonou · Obs.: Visto só na manchete. Outra versão relatada: ''estou vindo aí''.'
from people where slug = 'jojo-todynho'
  and not exists (select 1 from quotes where text = 'Em 2026, estou vindo');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Virei bandida', 'pt', null, 'Entrevista ao portal Leo Dias em 2024, ao desistir da política depois das críticas.', 'entrevista', 'https://www.terra.com.br/diversao/gente/jojo-todynho-desiste-da-politica-apos-criticas-virei-bandida,ecaa68db012635c186b813703b968ce83y05nlmj.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Desabafo exagerado sobre ser criticada · Obs.: Visto só na manchete. Data aproximada.'
from people where slug = 'jojo-todynho'
  and not exists (select 1 from quotes where text = 'Virei bandida');

-- Kéfera Buchmann
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Foi em Punta Cana, eu fiquei com um traficante, mas eu não sabia', 'pt', null, 'No programa Dellamake, de Bianca DellaFancy, em 2025, contando uma viagem.', 'video', 'https://www.terra.com.br/diversao/gente/famosos-em-redes-sociais/eu-fiquei-com-um-traficante-revela-kefera-sobre-viagem-a-punta-cana,06a21dcf8e12e3c8d585c514b875ee124x3p654g.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Confissão inusitada contada enquanto era maquiada · Obs.: Também no Metrópoles: https://www.metropoles.com/celebridades/kefera-choca-ao-revelar-que-ficou-com-traficante-durante-viagem. Data aproximada.'
from people where slug = 'kefera-buchmann'
  and not exists (select 1 from quotes where text = 'Foi em Punta Cana, eu fiquei com um traficante, mas eu não sabia');

-- Karol Conká
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Me ''descancelem'', por favor', 'pt', '2021-02-23', 'Logo após ser eliminada do BBB 21 com 99,17% de rejeição, recorde do programa, em 2021.', 'entrevista', 'https://www.terra.com.br/diversao/tv/bbb21-logo-apos-a-eliminacao-karol-pediu-desculpa-pelos-seus-erros,16ec1964e72dbd00489a122cd82a0488tbuv0wcm.html', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Pedido histórico depois da maior rejeição do BBB · Obs.: Metrópoles usa a manchete ''Me descancelem'': https://www.metropoles.com/entretenimento/bbb/me-descancelem-pede-karol-conka-apos-eliminacao-e-rejeicao-no-bbb21'
from people where slug = 'karol-conka'
  and not exists (select 1 from quotes where text = 'Me ''descancelem'', por favor');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Sou grata pelo hate que sofri', 'pt', null, 'Entrevista ao Na Palma da Mari (CNN Brasil) em 2025, relembrando o BBB 21.', 'entrevista', 'https://www.cnnbrasil.com.br/blogs/mari-palma/entretenimento/karol-conka-sobre-bbb-sou-grata-pelo-hate-que-sofri/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CNN Brasil · Por que: Agradecer pelo ódio é uma reviravolta inesperada · Obs.: Visto só na manchete.'
from people where slug = 'karol-conka'
  and not exists (select 1 from quotes where text = 'Sou grata pelo hate que sofri');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não sabia o que era humildade', 'pt', null, 'Reflexão sobre o pós-BBB 21.', 'entrevista', 'https://www.metropoles.com/celebridades/karol-conka-reflete-sobre-o-pos-bbb-nao-sabia-o-que-era-humildade', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Autocrítica sincera de uma ''vilã'' de reality · Obs.: Visto só na manchete; data não confirmada.'
from people where slug = 'karol-conka'
  and not exists (select 1 from quotes where text = 'Não sabia o que era humildade');

-- Whindersson Nunes
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Te jogaria do penhasco de novo', 'pt', null, 'Resposta no X a um post de Haaland após a Noruega eliminar o Brasil na Copa de 2026, em referência à música ''Penhasco'', de Luísa Sonza.', 'post', 'https://www.terra.com.br/diversao/musica/whindersson-cita-penhasco-em-meme-de-luisa-sonza-com-haaland-te-jogaria-de-novo,7d9eb8f042561d6dee5e22b38e6f09e9k00trzuy.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Piada com a ex que viralizou e rendeu pedido de desculpas · Obs.: A manchete do Terra resume como ''Te jogaria de novo''; a frase completa aparece nas reportagens. O post foi apagado depois.'
from people where slug = 'whindersson-nunes'
  and not exists (select 1 from quotes where text = 'Te jogaria do penhasco de novo');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Era piada, ela zangou', 'pt', null, 'Comentário de 2026 depois que Luísa Sonza deixou de segui-lo por causa da piada.', 'post', 'https://www.terra.com.br/diversao/musica/whindersson-comenta-unfollow-de-luisa-sonza-era-piada-ela-zangou,d51e9193c9266fcb837c024c81110b45vnn56kks.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Explicação em nordestinês para um unfollow · Obs.: Visto como manchete entre aspas.'
from people where slug = 'whindersson-nunes'
  and not exists (select 1 from quotes where text = 'Era piada, ela zangou');

-- Carlinhos Maia
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Sim gente, peguei rancinho de vocês, sim', 'pt', '2025-04-25', 'Stories no Instagram em 2025, durante a briga com influenciadoras por causa do Rancho do Maia.', 'post', 'https://www.metropoles.com/colunas/fabia-oliveira/carlinhos-maia-diz-que-pegou-ranco-de-seguidores-e-manda-recado', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Influenciador admitindo ranço dos próprios seguidores · Obs.: Também no Terra, com a mesma frase.'
from people where slug = 'carlinhos-maia'
  and not exists (select 1 from quotes where text = 'Sim gente, peguei rancinho de vocês, sim');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Que história chata de humildade', 'pt', '2025-04-27', 'Resposta de 2025 a uma seguidora que disse que ele era mais humilde quando era pobre.', 'post', 'https://www.metropoles.com/colunas/fabia-oliveira/carlinhos-maia-se-irrita-apos-seguidora-expor-falta-de-humildade', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Desdém sincero pela cobrança de humildade · Obs.: A redação veio do resumo da busca (Metrópoles e Terra).'
from people where slug = 'carlinhos-maia'
  and not exists (select 1 from quotes where text = 'Que história chata de humildade');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Achei 100% que o Brasil me amava', 'pt', null, 'Entrevista ao Blog do Leo Dias em que admitiu que se achava unanimidade na web.', 'entrevista', 'https://www.metropoles.com/colunas/pipocando/em-entrevista-carlinhos-maia-revela-ter-se-achado-unanime-na-web', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Confissão de autoestima nas alturas · Obs.: O ano foi estimado pela idade da matéria (cerca de 2019); confira.'
from people where slug = 'carlinhos-maia'
  and not exists (select 1 from quotes where text = 'Achei 100% que o Brasil me amava');

-- Casimiro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Largou a audiência, né?', 'pt', null, 'Na transmissão da Copa de 2026, zoando a Globo por exibir a Tela Quente no horário de um jogo de mata-mata.', 'video', 'https://www.terra.com.br/esportes/futebol/copa-2026/casimiro-zoa-globo-por-passar-tela-quente-no-horario-de-partida-de-mata-mata-na-copa-largou-a-audiencia-ne,aa3e595c2dd696d7f84c451d1740dc33y0tgnb0g.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Provocação direta à maior emissora do país · Obs.: Data aproximada (Copa 2026).'
from people where slug = 'casimiro'
  and not exists (select 1 from quotes where text = 'Largou a audiência, né?');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'CazéTV servindo carne para a Globo?', 'pt', null, 'Reclamação em live sobre um churrasco para a imprensa em que a CazéTV servia profissionais da Globo.', 'video', 'https://www.terra.com.br/diversao/tv/cazetv-servindo-carne-para-a-globo-reclama-casimiro-sobre-churrasco-de-imprensa,ee546979f0c36fa4d617ddd2ebd93304b0yw97ed.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Rivalidade com a Globo levada até o churrasco · Obs.: Visto só na manchete; data não confirmada.'
from people where slug = 'casimiro'
  and not exists (select 1 from quotes where text = 'CazéTV servindo carne para a Globo?');

-- Kanye West
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Cara, eu sou o astro do rock número um vivo e respirando.', 'pt', '2013-06-24', 'Perfil na revista W em 2013, explicando a música ''I Am a God''; também se comparou a Axl Rose, Jim Morrison e Jimi Hendrix.', 'entrevista', 'https://www.rollingstone.com/music/music-news/kanye-west-im-the-number-one-living-and-breathing-rock-star-246107/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): Man, I''m the Number One living and breathing rock star. · Fonte: Rolling Stone · Por que: Ego monumental de um rapper se dizendo maior astro do rock · Obs.: A data é a da publicação da Rolling Stone. Versão em PT da Rolling Stone Brasil: https://rollingstone.com.br/?p=39002'
from people where slug = 'kanye-west'
  and not exists (select 1 from quotes where text = 'Cara, eu sou o astro do rock número um vivo e respirando.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O maior artista que Deus já criou agora está trabalhando para Ele.', 'pt', '2019-11-17', 'Fala na Lakewood Church, igreja de Joel Osteen em Houston, na fase gospel do álbum Jesus Is King, em 2019.', 'discurso', 'https://rollingstone.com.br/noticia/kanye-west-se-declara-o-maior-artista-que-deus-ja-criou-em-culto-no-texas/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil · Por que: Humildade cristã, versão Kanye · Obs.: A Rolling Stone (EUA) diz que ele ''reportedly'' falou isto; não vi o texto original em inglês confirmado, por isso text_original ficou null. A data é de memória (domingo, 17); confira.'
from people where slug = 'kanye-west'
  and not exists (select 1 from quotes where text = 'O maior artista que Deus já criou agora está trabalhando para Ele.');

-- Kim Kardashian
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Tenho o melhor conselho para mulheres nos negócios. Levantem a porra da bunda e trabalhem. Parece que ninguém quer trabalhar hoje em dia.', 'pt', '2022-03-09', 'Entrevista de capa à Variety em 2022, na estreia de The Kardashians no Hulu.', 'entrevista', 'https://www.cnn.com/2022/03/10/entertainment/kim-kardashian-work-backlash', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I have the best advice for women in business. Get your fucking ass up and work. It seems like nobody wants to work these days. · Fonte: CNN · Por que: Conselho de bilionária que nasceu rica gerou forte reação · Obs.: A Variety publicou com o palavrão censurado (''f---ing''). A redação foi montada a partir de resumos da Variety e da NBC; confira o texto exato. Data aproximada da publicação. Ela depois disse que foi tirada de contexto.'
from people where slug = 'kim-kardashian'
  and not exists (select 1 from quotes where text = 'Tenho o melhor conselho para mulheres nos negócios. Levantem a porra da bunda e trabalhem. Parece que ninguém quer trabalhar hoje em dia.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Acho que não fomos. Acho que foi falso.', 'pt', null, 'Episódio de The Kardashians em 2025, tentando convencer Sarah Paulson de que a ida à Lua em 1969 foi encenada; a NASA respondeu.', 'video', 'https://variety.com/2025/tv/news/kim-kardashian-nasa-moon-landing-fake-conspiracy-1236566260/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I don''t think we did. I think it was fake. · Fonte: Variety · Por que: Teoria da conspiração que fez a NASA responder'
from people where slug = 'kim-kardashian'
  and not exists (select 1 from quotes where text = 'Acho que não fomos. Acho que foi falso.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quando eu me divorciar dele, vocês têm que saber que foi por uma coisa só: a personalidade dele.', 'pt', '2021-10-09', 'Monólogo de abertura no Saturday Night Live em 2021, sobre Kanye West.', 'video', 'https://variety.com/2022/tv/news/kim-kardashian-kanye-west-walked-out-snl-monologue-jokes-1235259468/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): When I divorce him you have to know it came down to one thing: his personality. · Fonte: Variety · Por que: Piada sobre o ex ao vivo, que fez Kanye sair do estúdio · Obs.: A redação varia: a CNN transcreveu ''when I divorced him you had to know it came down to one thing – his personality''. Escolha uma versão e confira.'
from people where slug = 'kim-kardashian'
  and not exists (select 1 from quotes where text = 'Quando eu me divorciar dele, vocês têm que saber que foi por uma coisa só: a personalidade dele.');

-- Elon Musk
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu reinventei os carros elétricos e estou mandando pessoas para Marte num foguete. Achavam que eu também seria um cara tranquilo e normal?', 'pt', '2021-05-08', 'Monólogo como apresentador do Saturday Night Live em 2021, falando dos próprios tuítes.', 'video', 'https://variety.com/2021/tv/news/elon-musk-saturday-night-live-monologue-aspergers-mom-1234969445/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I reinvented electric cars and I''m sending people to Mars in a rocket ship, did you think I was also going to be a chill, normal dude? · Fonte: Variety · Por que: Pedido de desculpas que na verdade é uma ostentação · Obs.: Começa com ''To anyone I''ve offended, I just want to say,''.'
from people where slug = 'elon-musk'
  and not exists (select 1 from quotes where text = 'Eu reinventei os carros elétricos e estou mandando pessoas para Marte num foguete. Achavam que eu também seria um cara tranquilo e normal?');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu gostaria de morrer em Marte. Só não no impacto.', 'pt', null, 'Frase registrada na biografia ''Elon Musk'', de Ashlee Vance, em 2015.', 'materia', 'https://www.cnn.com/2015/05/14/news/elon-musk-biography', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I would like to die on Mars. Just not on impact. · Fonte: CNN · Por que: Plano de aposentadoria interplanetário com humor ácido · Obs.: O resumo da CNN mostrou ''Elon Musk wants to die on Mars …"just not on impact."''. A frase completa entre aspas não foi vista; confira.'
from people where slug = 'elon-musk'
  and not exists (select 1 from quotes where text = 'Eu gostaria de morrer em Marte. Só não no impacto.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Vá se f***r.', 'pt', '2023-11-29', 'No DealBook Summit, do New York Times, em 2023, dirigido aos anunciantes que tiraram verba do X.', 'entrevista', 'https://variety.com/2023/digital/news/elon-musk-x-twitter-advertisers-antisemitic-post-spending-go-f-yourself-1235813657/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): Go fuck yourself. · Fonte: Variety · Por que: Dono de rede social xingando os próprios anunciantes ao vivo · Obs.: OPCIONAL, é vulgar. Visto como ''Go F--- Yourself'' na manchete da Variety. A fala completa inclui ''blackmail me with money'' e ''Is that clear?'', mas a ordem exata não foi confirmada.'
from people where slug = 'elon-musk'
  and not exists (select 1 from quotes where text = 'Vá se f***r.');

-- Madonna
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu não estou no Brasil ainda, então parem de falar português comigo', 'pt', null, 'Show da Celebration Tour nos EUA em 2024, falando com fãs brasileiros antes do show em Copacabana.', 'video', 'https://www.cnnbrasil.com.br/entretenimento/madonna-pede-para-fas-brasileiros-pararem-de-falar-portugues-em-show-nos-eua/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CNN Brasil · Por que: Bronca bem-humorada nos fãs brasileiros · Obs.: A CNN Brasil só publicou a tradução para o português; não vi a fala original em inglês.'
from people where slug = 'madonna'
  and not exists (select 1 from quotes where text = 'Eu não estou no Brasil ainda, então parem de falar português comigo');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Safada está indo para o Rio', 'pt', null, 'Post no Instagram em 2024 anunciando o show gratuito em Copacabana.', 'post', 'https://www.cnnbrasil.com.br/entretenimento/em-publicacao-madonna-fala-sobre-show-no-brasil-safada-esta-indo-para-o-rio/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): Safada is coming to Rio · Fonte: CNN Brasil · Por que: Rainha do Pop usando gíria brasileira · Obs.: Data aproximada (cerca de um mês antes do show de 4/5/2024).'
from people where slug = 'madonna'
  and not exists (select 1 from quotes where text = 'Safada está indo para o Rio');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Estou diante de vocês como um capacho. Ah, quer dizer, como uma artista mulher.', 'pt', '2016-12-09', 'Discurso ao receber o prêmio de Mulher do Ano no Billboard Women in Music, em 2016.', 'discurso', 'https://www.rollingstone.com/music/music-news/watch-madonna-talk-sexism-misogyny-in-powerful-women-in-music-speech-111275/', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I stand before you as a doormat. Oh, I mean, as a female entertainer. · Fonte: Rolling Stone · Por que: Ironia ácida sobre machismo na música · Obs.: Data de memória; confira.'
from people where slug = 'madonna'
  and not exists (select 1 from quotes where text = 'Estou diante de vocês como um capacho. Ah, quer dizer, como uma artista mulher.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Sim, eu pensei muito em explodir a Casa Branca', 'pt', '2017-01-21', 'Discurso na Marcha das Mulheres em Washington em 2017; depois ela disse que a frase foi tirada de contexto e era uma metáfora.', 'discurso', 'https://www.cnn.com/2017/01/21/politics/madonna-speech-march', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I have thought an awful lot about blowing up the White House · Fonte: CNN · Por que: Frase que virou escândalo político · Obs.: OPCIONAL, envolve violência (ela completou dizendo que isso não mudaria nada). A redação varia: alguns veículos publicam ''I have thought about blowing up the White House''. O ''Sim'' da tradução vem de ''Yes, I''m angry...'', que não foi confirmado.'
from people where slug = 'madonna'
  and not exists (select 1 from quotes where text = 'Sim, eu pensei muito em explodir a Casa Branca');

-- Silvio Santos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Me deixa excitado', 'pt', null, 'Ao recusar um abraço de Claudia Leitte no Teleton do SBT, 2018', 'video', 'https://www.metropoles.com/entretenimento/televisao/silvio-santos-rejeita-abraco-de-claudia-leitte-me-deixa-excitado', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Foi visto como assédio ao vivo e gerou a hashtag #ChegaDeAssédio · Obs.: Outra fonte: https://istoe.com.br/silvio-santos-nega-abraco-para-claudia-leitte-alegando-que-fica-excitado/'
from people where slug = 'silvio-santos'
  and not exists (select 1 from quotes where text = 'Me deixa excitado');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Faz show e enche o saco', 'pt', null, 'Comentário no ar sobre Claudia Leitte, 2019', 'video', 'https://www.metropoles.com/celebridades/faz-show-e-enche-o-saco-diz-silvio-santos-sobre-claudia-leitte', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Nova alfinetada na cantora meses depois do Teleton'
from people where slug = 'silvio-santos'
  and not exists (select 1 from quotes where text = 'Faz show e enche o saco');

-- Faustão
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eles não iam me deixar na vitrine', 'pt', null, 'No podcast Rap 77, sobre a Globo tê-lo tirado do ar antes do fim do contrato', 'entrevista', 'https://istoe.com.br/eles-nao-iam-me-deixar-na-vitrine-diz-faustao-sobre-decisao-polemica-da-globo', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: IstoÉ · Por que: Alfinetada rara na Globo depois de décadas na emissora'
from people where slug = 'faustao'
  and not exists (select 1 from quotes where text = 'Eles não iam me deixar na vitrine');

-- Galvão Bueno
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Aposentar é dar boa noite à morte.', 'pt', null, 'Ao negar boatos de aposentadoria, aos 74 anos', 'entrevista', 'https://www.terra.com.br/diversao/gente/galvao-bueno-rompe-o-silencio-sobre-boatos-de-aposentadoria-e-dar-boa-noite-a-morte,977a02e0eb9f5f5772f46f0b96a08260bxrftumt.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Frase mórbida e dramática sobre parar de trabalhar · Obs.: Manchete traz ''É dar boa noite à morte''; a frase completa só apareceu no resumo da busca'
from people where slug = 'galvao-bueno'
  and not exists (select 1 from quotes where text = 'Aposentar é dar boa noite à morte.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ele não pode falar isso', 'pt', null, 'No Galvão F.C. (SBT), criticando um post de Neymar após derrota do Santos, 2026', 'video', 'https://www.metropoles.com/esportes/galvao-bueno-detona-post-de-neymar-ele-nao-pode-falar-isso', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Galvão detonando o maior craque da Seleção'
from people where slug = 'galvao-bueno'
  and not exists (select 1 from quotes where text = 'Ele não pode falar isso');

-- Ana Maria Braga
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Me acho gostosa', 'pt', '2026-06-28', 'No Fantástico, aos 77 anos, sobre o casamento com um homem 30 anos mais novo, 2026', 'entrevista', 'https://www.cnnbrasil.com.br/pop/celebridades/me-acho-gostosa-ana-maria-braga-exalta-uniao-com-homem-30-anos-mais-novo/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CNN Brasil · Por que: Dá para confundir com uma cantora pop'
from people where slug = 'ana-maria-braga'
  and not exists (select 1 from quotes where text = 'Me acho gostosa');

-- Xuxa
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Do Ney Matogrosso ninguém fala nada, porque ele é homem', 'pt', '2026-08-16', 'No Domingão com Huck, sobre críticas aos figurinos da turnê, 2026', 'video', 'https://www.terra.com.br/diversao/gente/do-ney-matogrosso-ninguem-fala-nada-porque-ele-e-homem-diz-xuxa-sobre-criticas-por-figurino,d150536ca505c13dee540a9f0e9eb767mujnpvtf.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Começou uma briga pública com Ney Matogrosso'
from people where slug = 'xuxa'
  and not exists (select 1 from quotes where text = 'Do Ney Matogrosso ninguém fala nada, porque ele é homem');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu só deixo de falar com Paquita se é homofóbica.', 'pt', null, 'Entrevista ao canal de Hugo Gloss, sobre o afastamento de uma ex-Paquita', 'entrevista', 'https://www.terra.com.br/diversao/gente/xuxa-abre-o-jogo-sobre-afastamento-de-ex-paquita-e-faz-declaracao-contundente,3a843b36d211f69d7d6a25a515464984da4h7edp.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Indireta ligada pela imprensa a uma ex-Paquita'
from people where slug = 'xuxa'
  and not exists (select 1 from quotes where text = 'Eu só deixo de falar com Paquita se é homofóbica.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não quer acreditar que eu sou uma preferida do cara lá de cima, tudo bem', 'pt', null, 'No podcast de Thais Fersoza, sobre o boato de que teria feito pacto com o diabo', 'entrevista', 'https://www.terra.com.br/diversao/gente/xuxa-quebra-o-silencio-e-fala-sobre-pacto-com-o-diabo,16807db9e7f8d5f9fc03a1fdbdbb8db2ytqqj99u.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Responde à lenda do pacto com o diabo'
from people where slug = 'xuxa'
  and not exists (select 1 from quotes where text = 'Não quer acreditar que eu sou uma preferida do cara lá de cima, tudo bem');

-- Luciana Gimenez
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Nunca precisei de dinheiro de homem', 'pt', null, 'No podcast MaterniDelas, sobre a relação com Mick Jagger', 'entrevista', 'https://www.terra.com.br/diversao/gente/luciana-gimenez-revela-detalhes-da-relacao-com-mick-jagger-nunca-precisei-de-dinheiro-de-homem,6d63eee4995c839c0d2f11043962ce351566brj8.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Rebate a fama de ''golpe da barriga'''
from people where slug = 'luciana-gimenez'
  and not exists (select 1 from quotes where text = 'Nunca precisei de dinheiro de homem');

-- Datena
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Espero ter lavado a alma de milhões de pessoas', 'pt', '2024-09-16', 'Em nota, no dia seguinte à cadeirada em Pablo Marçal no debate da TV Cultura, 2024', 'post', 'https://istoe.com.br/espero-ter-lavado-a-alma-de-milhoes-de-pessoas-diz-datena-apos-cadeirada-em-marcal/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: IstoÉ · Por que: Justificou a cadeirada como se fosse um serviço público'
from people where slug = 'datena'
  and not exists (select 1 from quotes where text = 'Espero ter lavado a alma de milhões de pessoas');

-- Tim Maia
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Cacete, mas como tem gordo em São Paulo', 'pt', null, 'Numa coletiva em São Paulo, olhando a fila de jornalistas, início dos anos 1990', 'materia', 'https://rollingstone.com.br/musica/nos-80-anos-de-tim-maia-relembre-confusoes-em-que-ele-se-meteu-e-heranca-musical-que-deixou/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil · Por que: Provocação gratuita à imprensa · Obs.: Relato de Paulo Cavalcanti, não gravação'
from people where slug = 'tim-maia'
  and not exists (select 1 from quotes where text = 'Cacete, mas como tem gordo em São Paulo');

-- Rita Lee
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu não estou drogada, eu sou a droga', 'pt', null, 'Post no Twitter', 'post', 'https://istoe.com.br/rainha-do-rock-e-do-sarcasmo-relembre-os-tweets-mais-acidos-de-rita-lee/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: IstoÉ · Por que: Ironia sobre a própria fama'
from people where slug = 'rita-lee'
  and not exists (select 1 from quotes where text = 'Eu não estou drogada, eu sou a droga');

-- Ney Matogrosso
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Achei que ela não tinha que falar o meu nome', 'pt', null, 'À Folha de S.Paulo, depois de ser citado por Xuxa no Domingão, 2026', 'entrevista', 'https://www.cnnbrasil.com.br/pop/celebridades/ney-matogrosso-rebate-ser-citado-por-xuxa-nao-tinha-que-falar-meu-nome/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CNN Brasil · Por que: Ney e Xuxa trocando farpas em público'
from people where slug = 'ney-matogrosso'
  and not exists (select 1 from quotes where text = 'Achei que ela não tinha que falar o meu nome');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Comigo não rola isso. Nunca rolou', 'pt', null, 'Mesma entrevista, dizendo que nunca o criticaram por idade ou figurino, 2026', 'entrevista', 'https://www.terra.com.br/diversao/tv/ney-matogrosso-detona-xuxa-apos-declaracao-na-globo-comigo-nao-rola,e6edf6b26e54db6d395b2719306288cbeif6t8ar.html', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Terra · Por que: Rebate a tese de etarismo da Xuxa'
from people where slug = 'ney-matogrosso'
  and not exists (select 1 from quotes where text = 'Comigo não rola isso. Nunca rolou');

-- Lobão
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Do fundo do coração, eu seria incapaz de matar uma mosca.', 'pt', null, 'Entrevista de capa à Rolling Stone Brasil em 2013, no lançamento do livro ''Manifesto do Nada na Terra do Nunca''.', 'entrevista', 'https://rollingstone.com.br/?p=37441', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil · Por que: Frase mansa vinda do maior briguento do rock nacional · Obs.: Frase é o título da matéria.'
from people where slug = 'lobao'
  and not exists (select 1 from quotes where text = 'Do fundo do coração, eu seria incapaz de matar uma mosca.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Está vampirizando a juventude dos outros, que dá uma ''mudérnidade'' no som. Nem se ele tivesse o Black Sabbath com ele ia convencer, ele toca com nojinho.', 'pt', null, 'Lobão sobre Caetano Veloso, em entrevista à Rolling Stone Brasil em 2013.', 'entrevista', 'https://rollingstone.com.br/?p=37441', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil · Por que: Ataque famoso a Caetano, rixa histórica · Obs.: Texto visto no trecho do resultado de busca atribuído a essa matéria. Vale conferir a grafia exata (''mudérnidade'') na página.'
from people where slug = 'lobao'
  and not exists (select 1 from quotes where text = 'Está vampirizando a juventude dos outros, que dá uma ''mudérnidade'' no som. Nem se ele tivesse o Black Sabbath com ele ia convencer, ele toca com nojinho.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Cazuza seria um grande antídoto contra a atual caretice da MPB.', 'pt', null, 'Lobão em matéria da Rolling Stone Brasil sobre Cazuza e a MPB (data não confirmada).', 'entrevista', 'https://rollingstone.com.br/?p=13587', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil · Por que: Alfinetada típica na MPB · Obs.: Vista só no título do resultado de busca. Data não confirmada.'
from people where slug = 'lobao'
  and not exists (select 1 from quotes where text = 'Cazuza seria um grande antídoto contra a atual caretice da MPB.');

-- Caetano Veloso
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Mas censurar por razões religiosas, não: não estamos no Irã.', 'pt', null, 'Em entrevista por e-mail ao Estadão, Caetano disse que riu do especial de Natal do Porta dos Fundos e condenou a censura ao programa (2019/2020).', 'entrevista', 'https://rollingstone.com.br/noticia/caetano-veloso-riu-do-especial-de-natal-do-porta-dos-fundos-e-condena-censura-nao-estamos-no-ira/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil (reproduzindo Estadão) · Por que: Comparação provocadora com o Irã · Obs.: A data é aproximada: a polêmica do especial vai de dez/2019 a jan/2020. Não vi a matéria original do Estadão.'
from people where slug = 'caetano-veloso'
  and not exists (select 1 from quotes where text = 'Mas censurar por razões religiosas, não: não estamos no Irã.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Mas hoje me parece que há um excesso de racialização, sexualização e ênfase nas questões de gênero.', 'pt', '2026-06-01', 'Entrevista de Caetano ao jornal espanhol El País em 2026, durante turnê pela Europa.', 'entrevista', 'https://www.correio24horas.com.br/em-alta/caetano-veloso-critica-excesso-de-debates-sobre-raca-sexualidade-e-genero-e-diz-que-tema-gera-muita-confusao-0626', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio (Salvador) · Por que: Crítica inesperada vinda de um ícone da esquerda · Obs.: As traduções variam (''me parece excessivo o nível de...'' x ''há um excesso de...''). O original foi dado em espanhol ao El País. Não sei com certeza qual versão está nesta URL.'
from people where slug = 'caetano-veloso'
  and not exists (select 1 from quotes where text = 'Mas hoje me parece que há um excesso de racialização, sexualização e ênfase nas questões de gênero.');

-- Anitta
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'É assim que vocês me veem? Eu sou tão gostosa!', 'pt', '2022-06-02', 'Anitta reagindo à revelação da sua estátua de cera no Madame Tussauds de Nova York, em 2022.', 'video', 'https://rollingstone.com.br/?p=139062', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Rolling Stone Brasil · Por que: Autoelogio bem-humorado · Obs.: Frase vista no título da matéria.'
from people where slug = 'anitta'
  and not exists (select 1 from quotes where text = 'É assim que vocês me veem? Eu sou tão gostosa!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ninguém precisa ter bilhões.', 'pt', null, 'Anitta defende um limite de riqueza depois da repercussão da sua fala no podcast de Jay Shetty, em 2024.', 'video', 'https://diariodopara.com.br/entretenimento/tdb/anitta-reforca-critica-a-bilionarios-e-defende-o-limite-de-riqueza/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Diário do Pará · Por que: Milionária pedindo teto de riqueza · Obs.: Frase vista só no título da matéria. Ela foi dita no vídeo de esclarecimento ou num desdobramento da fala original, que foi em inglês.'
from people where slug = 'anitta'
  and not exists (select 1 from quotes where text = 'Ninguém precisa ter bilhões.');

-- Zeca Pagodinho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Uma vacina em cada braço e uma em cada nádega.', 'pt', '2020-12-06', 'Zeca, ao Fantástico em 2020, dizendo quantas doses tomaria da vacina contra a Covid.', 'entrevista', 'https://www.folhape.com.br/cultura/zeca-pagodinho-quer-compor-sobre-vacina-contra-covid-e-diz-que-vai/164817/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Folha de Pernambuco · Por que: Resposta engraçada e inesperada · Obs.: A data foi deduzida de ''domingo (6)'' no texto. O Diário do Litoral traz a variante ''e cada nádega''.'
from people where slug = 'zeca-pagodinho'
  and not exists (select 1 from quotes where text = 'Uma vacina em cada braço e uma em cada nádega.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu não devo nada à internet.', 'pt', null, 'Zeca num painel do Rio2C em 2026, falando da sua aversão a internet e WhatsApp.', 'discurso', 'https://www.correiodamanha.com.br/cultura/musica/2026/06/290190-zeca-pagodinho-eu-nao-devo-nada-a-internet.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio da Manhã · Por que: Recusa curiosa do mundo digital · Obs.: Frase vista no título da matéria. A data é a da publicação.'
from people where slug = 'zeca-pagodinho'
  and not exists (select 1 from quotes where text = 'Eu não devo nada à internet.');

-- Roberto Carlos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Sou fã, assisto todos os dias, me divirto muito.', 'pt', '2021-04-13', 'Roberto Carlos sobre o BBB, em respostas a jornalistas às vésperas dos 80 anos, em 2021.', 'entrevista', 'https://www.correio24horas.com.br/noticia/nid/roberto-carlos-diz-ser-fa-do-bbb-e-defende-a-ciencia-todos-devem-se-vacinar', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio (Salvador) · Por que: Ninguém imagina o Rei maratonando o BBB · Obs.: Vi a citação atribuída à Folha Vitória e ao Correio. A data vem de ''terça-feira, 13'' antes do aniversário de 80 anos (19/04/2021).'
from people where slug = 'roberto-carlos'
  and not exists (select 1 from quotes where text = 'Sou fã, assisto todos os dias, me divirto muito.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Acho uma falta de ética de quem colocou isso no filme.', 'pt', null, 'Roberto Carlos nega a cena do filme ''Tim Maia'' em que Tim joga pão nele, em 2015.', 'entrevista', 'https://exame.com/casual/roberto-carlos-chama-de-mentira-cena-de-filme-sobre-tim-maia', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Exame · Por que: Rixa com a cinebiografia de Tim Maia'
from people where slug = 'roberto-carlos'
  and not exists (select 1 from quotes where text = 'Acho uma falta de ética de quem colocou isso no filme.');

-- Fábio Jr.
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Acho que sou o único homem que casou para fugir de casa.', 'pt', null, 'No Altas Horas em 2020, Fábio Jr. contou que se casou pela primeira vez para sair da casa dos pais.', 'entrevista', 'https://www.dci.com.br/dci-mais/celebridades/esposas-de-fabio-junior-cantor-foi-casado-7-vezes/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: DCI · Por que: Confissão inusitada de quem casou 7 vezes · Obs.: Também aparece no Diário do Pará.'
from people where slug = 'fabio-jr'
  and not exists (select 1 from quotes where text = 'Acho que sou o único homem que casou para fugir de casa.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Mas vocês sabem o que é que está acontecendo no Brasil, né? Desordem e roubalheira. É uma quadrilha.', 'pt', '2015-09-06', 'Discurso de Fábio Jr. no Brazilian Day em Nova York, em 2015, enrolado na bandeira, criticando o governo.', 'discurso', 'https://exame.com/brasil/fabio-jr-detona-roubalheira-no-brasil-e-ataca-dilma/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Exame · Por que: Discurso político que virou manchete · Obs.: A redação exata veio de um resumo de busca, e os veículos divergem um pouco. Confirmar na matéria ou no vídeo.'
from people where slug = 'fabio-jr'
  and not exists (select 1 from quotes where text = 'Mas vocês sabem o que é que está acontecendo no Brasil, né? Desordem e roubalheira. É uma quadrilha.');

-- Gusttavo Lima
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Música popular brasileira pra mim é sertanejo.', 'pt', null, 'Gusttavo no palco de um show-teste em Goiânia, em 2021. A fala gerou reação de artistas da MPB.', 'discurso', 'https://opopular.com.br/magazine/musica-popular-brasileira-pra-mim-e-sertanejo-diz-gusttavo-lima-em-show-em-goiania-1.2342149', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: O Popular · Por que: Provocação à MPB · Obs.: Frase vista no título. O Metrópoles traz ''para mim é o sertanejo''.'
from people where slug = 'gusttavo-lima'
  and not exists (select 1 from quotes where text = 'Música popular brasileira pra mim é sertanejo.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Chega dessa história de direita e de esquerda.', 'pt', '2025-01-02', 'Ao anunciar ao Metrópoles, em 2025, a intenção de disputar a Presidência em 2026.', 'entrevista', 'https://www.band.com.br/entretenimento/gusttavo-lima-revela-intencao-de-ser-candidato-a-presidencia-da-republica-em-2026-202501021727', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Band · Por que: Cantor anunciando pré-candidatura presidencial · Obs.: O Diário do Nordeste traz no título a ordem ''esquerda e direita''. Depois ele desistiu da candidatura.'
from people where slug = 'gusttavo-lima'
  and not exists (select 1 from quotes where text = 'Chega dessa história de direita e de esquerda.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu funciono na palavra, não preciso de contrato para ser homem.', 'pt', null, 'Gusttavo a Leo Dias em 2026, na briga com Wesley Safadão pela carreira de Natanzinho Lima.', 'entrevista', 'https://www.gazetasp.com.br/entretenimento/entenda-a-polemica-entre-gusttavo-lima-e-wesley-safadao-ele-nao/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Gazeta de S.Paulo · Por que: Treta com Safadão · Obs.: A fala original foi ao portal LeoDias. Vi a citação no resumo da busca.'
from people where slug = 'gusttavo-lima'
  and not exists (select 1 from quotes where text = 'Eu funciono na palavra, não preciso de contrato para ser homem.');

-- Ivete Sangalo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu não vou deixar acontecer, porque não tem apocalipse certo quando a gente maceta o apocalipse.', 'pt', null, 'No trio do Carnaval de Salvador em 2024, Ivete responde à pregação de Baby do Brasil sobre o fim do mundo.', 'video', 'https://billboard.com.br/ivete-sangalo-maceta-apocalipse-de-baby-do-brasil-no-carnaval/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Billboard Brasil · Por que: Momento viral do Carnaval · Obs.: As transcrições variam um pouco (com e sem ''certo''). Também há relembrança da Band: https://www.band.com.br/entretenimento/carnaval/band-folia/noticias/macetar-o-apocalipse-relembre-conversa-iconica-de-ivete-e-baby-do-brasil-que-marcou-band-folia-202502211850'
from people where slug = 'ivete-sangalo'
  and not exists (select 1 from quotes where text = 'Eu não vou deixar acontecer, porque não tem apocalipse certo quando a gente maceta o apocalipse.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Como é que vou dizer: ''minha gente, nunca transei com a Xuxa?''', 'pt', null, 'Ivete à revista Playboy em 2012, sobre os boatos de um caso com Xuxa.', 'entrevista', 'https://www.jb.com.br/heloisa-tolipan/noticias/2012/11/06/nunca-transei-com-xuxa-minha-gente-afirma-ivete-sangalo-em-entrevista.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Jornal do Brasil · Por que: Resposta franca a um boato famoso · Obs.: Redação vista no resumo da busca. O título do JB é ''Nunca transei com Xuxa, minha gente''.'
from people where slug = 'ivete-sangalo'
  and not exists (select 1 from quotes where text = 'Como é que vou dizer: ''minha gente, nunca transei com a Xuxa?''');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não ouvi. Tá baixinho.', 'pt', '2021-12-29', 'Ivete num show em Natal em 2021, quando o público puxou um coro contra o então presidente Bolsonaro.', 'video', 'https://www.correiobraziliense.com.br/diversao-e-arte/2021/12/4974290-publico-puxa-coro-contra-bolsonaro-em-show-de-ivete-sangalo-e-cantora-reage.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio Braziliense · Por que: Provocação política que viralizou · Obs.: Curta. A citação foi vista via A Gazeta/Folhapress.'
from people where slug = 'ivete-sangalo'
  and not exists (select 1 from quotes where text = 'Não ouvi. Tá baixinho.');

-- Gilberto Gil
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Porque somos todos filhos de um pai e de uma mãe, o resultado de uma junção de genes de um e de outro. Portanto, somos todos bissexuais.', 'pt', null, 'Gil em entrevista à Veja em 2023, aos 80 anos, falando de sexualidade.', 'entrevista', 'https://www.correio24horas.com.br/em-alta/gilberto-gil-revela-ja-ter-se-relacionado-com-homens-sexualidade-vibrante-0623', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio (Salvador), citando Veja · Por que: Teoria surpreendente de um ícone · Obs.: A redação varia entre os veículos. Não vi a Veja original.'
from people where slug = 'gilberto-gil'
  and not exists (select 1 from quotes where text = 'Porque somos todos filhos de um pai e de uma mãe, o resultado de uma junção de genes de um e de outro. Portanto, somos todos bissexuais.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Nunca tive tesão num homem, como se diz.', 'pt', null, 'Mesma entrevista à Veja em 2023, em que Gil contou ter tido relações com homens no passado.', 'entrevista', 'https://www.correio24horas.com.br/em-alta/gilberto-gil-revela-ja-ter-se-relacionado-com-homens-sexualidade-vibrante-0623', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Correio (Salvador), citando Veja · Por que: Confissão inesperada · Obs.: Também em O Liberal: https://www.oliberal.com/cultura/aos-80-anos-gilberto-gil-revela-que-ja-se-relacionou-sexualmente-com-homens-1.688942'
from people where slug = 'gilberto-gil'
  and not exists (select 1 from quotes where text = 'Nunca tive tesão num homem, como se diz.');

-- Luan Santana
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Para muitas pessoas, eu não falo palavrão, eu não bebo. Eu faço essas coisas.', 'pt', null, 'Luan no Flow Podcast em 2021, rejeitando a fama de bom moço.', 'entrevista', 'https://istoe.com.br/luan-santana-nega-fama-de-bom-moco-e-revela-sexo-com-prostitutas/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: IstoÉ · Por que: Quebra da imagem de bom moço · Obs.: A redação vem do resumo da busca. Conferir na matéria.'
from people where slug = 'luan-santana'
  and not exists (select 1 from quotes where text = 'Para muitas pessoas, eu não falo palavrão, eu não bebo. Eu faço essas coisas.');

-- Pabllo Vittar
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Meu Deus, fui abençoada!', 'pt', null, 'Pabllo contando, num podcast em 2025, que levou uma cusparada de Madonna nos ensaios do show de Copacabana (2024).', 'entrevista', 'https://atarde.com.br/entretenimento/pabllo-vittar-revela-ter-levado-cusparada-de-madonna-em-ensaio-1313481', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: A Tarde · Por que: Reação inusitada a uma cusparada de Madonna · Obs.: Curta. Precisa do contexto da cusparada para fazer sentido.'
from people where slug = 'pabllo-vittar'
  and not exists (select 1 from quotes where text = 'Meu Deus, fui abençoada!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Me ofereceram R$ 60 mil por uma noite.', 'pt', null, 'Pabllo em entrevista ao jornal Extra em 2018, falando de propostas que já recebeu.', 'entrevista', 'https://www.metropoles.com/vida-e-estilo/celebridades/me-ofereceram-r-60-mil-por-uma-noite-diz-pabllo-vittar', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Revelação chocante · Obs.: Frase vista só no título da matéria.'
from people where slug = 'pabllo-vittar'
  and not exists (select 1 from quotes where text = 'Me ofereceram R$ 60 mil por uma noite.');

-- Jair Bolsonaro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O que é golden shower?', 'pt', null, 'Post no Twitter durante o Carnaval de 2019, depois apagado', 'post', 'https://istoe.com.br/apos-video-polemico-bolsonaro-pergunta-no-twitter-o-que-e-golden-shower/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: IstoÉ · Por que: Presidente perguntando sobre um fetiche sexual na conta oficial'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'O que é golden shower?');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não sou coveiro.', 'pt', '2020-04-20', 'Resposta a jornalistas no Palácio da Alvorada sobre mortes por Covid-19, 2020', 'entrevista', 'https://www.nsctotal.com.br/?p=2705451', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: NSC Total · Por que: Desdém pelas mortes na pandemia'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'Não sou coveiro.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'E daí? Lamento. Quer que eu faça o quê? Sou Messias, mas não faço milagre.', 'pt', null, 'A jornalistas quando o Brasil passou de 5 mil mortes por Covid-19, 2020', 'entrevista', 'https://istoe.com.br/e-dai-lamento-quer-que-eu-faca-o-que-diz-bolsonaro-sobre-recorde-de-mortes-por-coronavirus/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: IstoÉ · Por que: Trocadilho com o próprio nome em meio a um recorde de mortes · Obs.: A manchete traz a primeira parte; ''Sou Messias...'' veio de um trecho do Aos Fatos'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'E daí? Lamento. Quer que eu faça o quê? Sou Messias, mas não faço milagre.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se você virar jacaré, é problema seu.', 'pt', '2020-12-17', 'Discurso em Porto Seguro (BA) sobre o contrato da vacina da Pfizer, 2020', 'discurso', 'https://www.dn.pt/mundo/bolsonaro-sobre-a-vacina-de-pfizer-se-voce-se-transformar-num-jacare-e-problema-e-seu-13155253.html', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Diário de Notícias (PT) · Por que: Insinuou efeitos absurdos da vacina'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'Se você virar jacaré, é problema seu.');

-- Lula
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Os usuários são responsáveis pelos traficantes, que são vítimas dos usuários também.', 'pt', '2025-10-24', 'Coletiva em Jacarta, Indonésia, 2025', 'entrevista', 'https://www.poder360.com.br/poder-governo/traficantes-sao-vitimas-dos-usuarios-de-drogas-diz-lula/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Poder360 · Por que: Chamou traficantes de ''vítimas''; se retratou no mesmo dia'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Os usuários são responsáveis pelos traficantes, que são vítimas dos usuários também.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Só vai estar tudo bem quando eu foder esse Moro.', 'pt', '2023-03-21', 'Entrevista ao Brasil 247, lembrando o período em que esteve preso, 2023', 'entrevista', 'https://www.metropoles.com/brasil/politica-brasil/lula-lembra-de-prisao-so-vai-estar-bem-quando-eu-foder-esse-moro', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Palavrão de um presidente contra um senador e ex-juiz · Obs.: O Brasil 247 transcreveu ''foder com o Moro'''
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Só vai estar tudo bem quando eu foder esse Moro.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Esse cara é tão responsável quanto o Putin pela guerra.', 'pt', '2022-05-04', 'Entrevista à revista Time sobre Zelensky e a guerra na Ucrânia, 2022', 'entrevista', 'https://www.cnnbrasil.com.br/politica/zelensky-e-tao-responsavel-quanto-putin-diz-lula-capa-da-time/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CNN Brasil · Por que: Culpou o presidente do país invadido tanto quanto o invasor'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Esse cara é tão responsável quanto o Putin pela guerra.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se o cara é corintiano, tudo bem.', 'pt', '2024-07-16', 'Reunião no Planalto, logo após citar estudo sobre violência contra a mulher depois de jogos de futebol, 2024', 'discurso', 'https://www.diariodepernambuco.com.br/noticia/politica/2024/07/lula-critica-a-violencia-domestica-mas-diz-tudo-bem-se-for-corinthian.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Diário de Pernambuco · Por que: Piada que relativizou agressão a mulheres'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Se o cara é corintiano, tudo bem.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Mão de homem não foi feita para bater em mulher. Quer bater em mulher? Vá bater em outro lugar, mas não dentro da sua casa ou no Brasil.', 'pt', null, 'Discurso de campanha em São Paulo, 2022', 'discurso', 'https://www.tribunadosertao.com.br/politica/2022/08/23/454089-frase-de-lula-sobre-bater-em-mulher-gera-polemica-e-vira-arma-na-campanha', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Tribuna do Sertão · Por que: Soou como se a violência fosse aceitável ''em outro lugar'' · Obs.: FONTE FRACA: confirme num veículo grande antes de aprovar'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Mão de homem não foi feita para bater em mulher. Quer bater em mulher? Vá bater em outro lugar, mas não dentro da sua casa ou no Brasil.');

-- Dilma Rousseff
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu não respeito delator.', 'pt', '2015-06-29', 'Coletiva em Nova York sobre a delação do dono da UTC na Lava Jato, 2015', 'entrevista', 'https://www.congressoemfoco.com.br/noticia/52810/%e2%80%98eu-nao-respeito-delator%e2%80%99-afirma-dilma-nos-eua', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Congresso em Foco · Por que: Presidente atacando o instrumento central da Lava Jato'
from people where slug = 'dilma-rousseff'
  and not exists (select 1 from quotes where text = 'Eu não respeito delator.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Podemos fazer o diabo quando é eleição.', 'pt', null, 'Fala a prefeitos em João Pessoa (PB), 2013', 'discurso', 'https://istoe.com.br/podemos-fazer-o-diabo-quando-e-eleicao-ja-avisava-dilma-em-2013', null, 3, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: IstoÉ · Por que: Admitiu que em eleição vale tudo'
from people where slug = 'dilma-rousseff'
  and not exists (select 1 from quotes where text = 'Podemos fazer o diabo quando é eleição.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não acho que quem ganhar ou quem perder, nem quem ganhar nem perder, vai ganhar ou perder. Vai todo mundo perder.', 'pt', null, 'Fala sobre disputa eleitoral durante o mandato', 'video', 'https://www.metropoles.com/brasil/bolsonaro-se-enrola-ao-falar-de-cloroquina-e-e-comparado-a-dilma-dilmou', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Metrópoles · Por que: Frase circular que vira meme a cada eleição · Obs.: Data não confirmada (2015 ou 2018)'
from people where slug = 'dilma-rousseff'
  and not exists (select 1 from quotes where text = 'Não acho que quem ganhar ou quem perder, nem quem ganhar nem perder, vai ganhar ou perder. Vai todo mundo perder.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quando nós criamos uma bola dessas, nós nos transformamos em homo sapiens, ou mulheres sapiens.', 'pt', '2015-06-23', 'Discurso nos I Jogos Mundiais dos Povos Indígenas, segurando uma bola de folha de bananeira, 2015', 'discurso', 'https://www.jornalopcao.com.br/ultimas-noticias/em-mais-um-discurso-confuso-dilma-sauda-a-mandioca-e-fala-em-mulher-sapiens-38918/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Jornal Opção · Por que: Gafe do mesmo discurso da ''mandioca'''
from people where slug = 'dilma-rousseff'
  and not exists (select 1 from quotes where text = 'Quando nós criamos uma bola dessas, nós nos transformamos em homo sapiens, ou mulheres sapiens.');

-- Donald Trump
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu poderia ficar no meio da Quinta Avenida e atirar em alguém, e não perderia nenhum eleitor.', 'pt', '2016-01-23', 'Comício em Sioux Center, Iowa, 2016', 'discurso', 'https://npr.org/sections/thetwo-way/2016/01/23/464129029/donald-trump-i-could-shoot-somebody-and-i-wouldnt-lose-any-voters', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): I could stand in the middle of Fifth Avenue and shoot somebody and I wouldn''t lose any voters · Fonte: NPR · Por que: Disse que sairia impune até de um crime hipotético'
from people where slug = 'donald-trump'
  and not exists (select 1 from quotes where text = 'Eu poderia ficar no meio da Quinta Avenida e atirar em alguém, e não perderia nenhum eleitor.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Em Springfield, eles estão comendo os cachorros, as pessoas que chegaram, estão comendo os gatos, estão comendo os animais de estimação das pessoas que moram lá.', 'pt', '2024-09-10', 'Debate presidencial contra Kamala Harris, repetindo boato negado pela cidade, 2024', 'video', 'https://www.wcpo.com/donald-trump-springfield-ohio-dogs-eaten-presidential-debate', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): In Springfield, they''re eating the dogs, the people that came in, they''re eating the cats, they''re eating the pets of the people that live there · Fonte: WCPO (ABC) · Por que: Boato sem provas dito em debate nacional'
from people where slug = 'donald-trump'
  and not exists (select 1 from quotes where text = 'Em Springfield, eles estão comendo os cachorros, as pessoas que chegaram, estão comendo os gatos, estão comendo os animais de estimação das pessoas que moram lá.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A forma como o Brasil tratou o ex-presidente Bolsonaro, um líder muito respeitado no mundo todo durante seu mandato, inclusive pelos Estados Unidos, é uma vergonha internacional. Esse julgamento não deveria estar acontecendo. É uma caça às bruxas que deve acabar IMEDIATAMENTE!', 'pt', '2025-07-09', 'Carta a Lula publicada no Truth Social anunciando tarifa de 50%, 2025', 'post', 'https://time.com/7301498/trump-brazil-lula-da-silva-us-tariffs-bolsonaro-witch-hunt/', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Original (en): The way Brazil has treated former President Bolsonaro, a Highly Respected Leader throughout the World during his Term, including by the United States, is an international disgrace. This Trial should not be taking place. It is a Witch Hunt that should end IMMEDIATELY! · Fonte: TIME · Por que: Dá para achar que foi um Bolsonaro'
from people where slug = 'donald-trump'
  and not exists (select 1 from quotes where text = 'A forma como o Brasil tratou o ex-presidente Bolsonaro, um líder muito respeitado no mundo todo durante seu mandato, inclusive pelos Estados Unidos, é uma vergonha internacional. Esse julgamento não deveria estar acontecendo. É uma caça às bruxas que deve acabar IMEDIATAMENTE!');

-- Eduardo Bolsonaro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se quiser fechar o STF, você não manda nem um jipe. Manda um soldado e um cabo.', 'pt', '2018-07-09', 'Palestra num cursinho em Cascavel (PR), 2018', 'video', 'https://congressoemfoco.com.br/video/filho-de-bolsonaro-diz-em-video-se-quiser-fechar-o-stf-voce-nao-manda-nem-um-jipe', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Congresso em Foco · Por que: Chamada de golpista por ministro do STF; ele pediu desculpas · Obs.: Montada a partir de dois trechos de manchete; o original é um pouco mais longo'
from people where slug = 'eduardo-bolsonaro'
  and not exists (select 1 from quotes where text = 'Se quiser fechar o STF, você não manda nem um jipe. Manda um soldado e um cabo.');

-- Damares Alves
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Menino veste azul e menina veste rosa.', 'pt', '2019-01-02', 'Vídeo gravado com apoiadores logo após a posse como ministra, 2019', 'video', 'https://exame.com/brasil/menino-veste-azul-e-menina-veste-rosa-diz-damares-em-video/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Exame · Por que: Virou símbolo do debate sobre gênero'
from people where slug = 'damares-alves'
  and not exists (select 1 from quotes where text = 'Menino veste azul e menina veste rosa.');

-- Michel Temer
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Ninguém mais é capaz de indicar os desajustes, por exemplo, de preços em supermercados do que a mulher.', 'pt', '2017-03-08', 'Discurso no Planalto pelo Dia Internacional da Mulher, 2017', 'discurso', 'https://www.em.com.br/app/noticia/nacional/2017/03/08/interna_nacional,852714/temer-ninguem-melhor-do-que-a-mulher-para-indicar-desajustes-de-preco.shtml', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: Estado de Minas (Agência Estado) · Por que: Homenagem reduziu o papel feminino ao supermercado'
from people where slug = 'michel-temer'
  and not exists (select 1 from quotes where text = 'Ninguém mais é capaz de indicar os desajustes, por exemplo, de preços em supermercados do que a mulher.');

-- Janja
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Fuck you, Elon Musk.', 'pt', '2024-11-16', 'Painel sobre desinformação em evento paralelo do G20 no Rio, 2024', 'discurso', 'https://www.cnnbrasil.com.br/politica/fuck-you-elon-musk-diz-janja-em-evento-do-g20/', null, 1, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: CNN Brasil · Por que: Primeira-dama xingando o homem mais rico do mundo num evento oficial'
from people where slug = 'janja'
  and not exists (select 1 from quotes where text = 'Fuck you, Elon Musk.');

-- Ciro Gomes
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'A minha companheira tem um dos papéis mais importantes, que é dormir comigo. Dormir comigo é um papel fundamental.', 'pt', null, 'Entrevista na campanha presidencial, sobre o papel de Patrícia Pillar, 2002', 'entrevista', 'https://www.opovo.com.br/noticias/politica/2024/04/09/relembre-as-frases-machistas-de-ciro-gomes-ao-longo-dos-ultimos-anos.html', null, 2, 'draft', 'Conferida pelo trecho citado na busca; abra a fonte antes de aprovar · Fonte: O Povo · Por que: Ajudou a derrubar sua candidatura'
from people where slug = 'ciro-gomes'
  and not exists (select 1 from quotes where text = 'A minha companheira tem um dos papéis mais importantes, que é dormir comigo. Dormir comigo é um papel fundamental.');

commit;
