-- Carga 3: frases polêmicas com contexto, no estilo das que você já aprovou. Tudo entra como RASCUNHO:
-- nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove a foto em /admin → Fotos). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, country, bio_short) values
  ('Abel Ferreira', 'abel-ferreira', 'futebol', 'PT', 'Técnico português do Palmeiras, bicampeão da Libertadores'),
  ('Paulo Guedes', 'paulo-guedes', 'politica', 'BR', 'Economista, ministro da Economia do governo Bolsonaro (2019–2022)')
on conflict (slug) do nothing;

-- neto
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu fico feliz quando sou processado por um treinador que ganhou cem milhões em seis anos, duas Copa do Mundo não ganhou nada.', 'pt', '2023-03-01', 'Na Rádio Bandeirantes, depois de Tite apresentar queixa-crime por injúria pelos xingamentos após a eliminação na Copa do Catar. Também o chamou de ''pipoqueiro''; em setembro de 2023 fez acordo e pediu desculpas públicas.', 'materia', 'https://www.bahianoticias.com.br/folha/noticia/215829-neto-diz-que-tite-tem-direito-de-processa-lo-nao-tenho-medo', null, 2, 'draft', 'Fonte: Bahia Notícias (Folhapress) · Por que: Processado, dobra a aposta e debocha do salário e dos fracassos do técnico da Seleção · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Final cortado: ''..., deixou um legado horrível para a Seleção Brasileira.'' Só o mês é certo. Também na Jovem Pan: https://jovempan.com.br/esportes/futebol/futebol-internacional/neto-diz-nao-temer-processo-de-tite-e-volta-a-criticar-ex-treinador-da-selecao-foi-pipoqueiro/'
from people where slug = 'neto'
  and not exists (select 1 from quotes where text = 'Eu fico feliz quando sou processado por um treinador que ganhou cem milhões em seis anos, duas Copa do Mundo não ganhou nada.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Otário é quem acreditou em você', 'pt', '2026-07-24', 'No Os Donos da Bola (Band), respondendo a Neymar, que o chamou de ''otário'' nas redes depois de Neto criticar sua ida a um torneio de pôquer numa folga do Santos. Disse que otário era quem acreditou que Neymar levaria o Brasil longe na Copa de 2026.', 'materia', 'https://abcdoabc.com.br/neto-rebate-neymar-otario-e-quem/', null, 2, 'draft', 'Fonte: ABC do ABC · Por que: Troca de xingamentos ao vivo entre um apresentador e o maior craque do país · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Variante ''acredita'' na Tribuna de Jundiaí. Data aproximada.'
from people where slug = 'neto'
  and not exists (select 1 from quotes where text = 'Otário é quem acreditou em você');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Esse país é de vagabundo, safado', 'pt', '2021-11-08', 'No Os Donos da Bola, comovido com o caso de Bruninho, menino santista de 9 anos hostilizado na Vila Belmiro por ter ganhado a camisa do goleiro do Palmeiras no clássico de 7/11/2021. O menino chegou a gravar vídeo pedindo desculpas.', 'materia', 'https://www.lance.com.br/fora-de-campo/neto-comove-com-pequeno-torcedor-santos-hostilizado-esse-pais-vagabundo-safado.html', null, 3, 'draft', 'Fonte: Lance! · Por que: Desabafo generalizando o país inteiro em TV aberta · Obs.: Conferida pelo trecho da busca (título do Lance!); abra a fonte antes de aprovar. Data deduzida.'
from people where slug = 'neto'
  and not exists (select 1 from quotes where text = 'Esse país é de vagabundo, safado');

-- pele
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se eu fosse parar o jogo cada vez que me chamassem de macaco ou crioulo, toda partida teria que parar.', 'pt', '2014-09-10', 'Comentando o caso do goleiro Aranha, do Santos, chamado de ''macaco'' por torcedores do Grêmio na Copa do Brasil de 2014. Disse que Aranha ''se precipitou''; a fala foi vista como minimização do racismo.', 'materia', 'https://istoe.com.br/pele-fala-sobre-racismo-no-fim-dos-jogos-todos-vinham-me-pedir-desculpas/', null, 2, 'draft', 'Fonte: IstoÉ · Por que: O maior ídolo negro do futebol relativizando o racismo sofrido por outro jogador · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Variante: ''todo jogo teria que parar''. Data aproximada.'
from people where slug = 'pele'
  and not exists (select 1 from quotes where text = 'Se eu fosse parar o jogo cada vez que me chamassem de macaco ou crioulo, toda partida teria que parar.');

-- vampeta
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu seco a Seleção Brasileira mesmo. Não quero que ganhe a Copa de 2026.', 'pt', '2026-04-01', 'Na Rádio Jovem Pan, antes da Copa de 2026. O pentacampeão disse torcer contra o Brasil para não perder os contratos de publicidade da geração de 2002 e não ser esquecido.', 'materia', 'https://tribunadejundiai.com.br/mais/esportes/vampeta-faz-revelacao-sobre-selecao-eu-seco-mesmo/', null, 2, 'draft', 'Fonte: Tribuna de Jundiaí · Por que: Campeão do mundo admitindo secar a própria Seleção por dinheiro · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. As duas frases vieram de um resumo; os títulos trazem ''eu seco mesmo'' e ''Não quero que ganhe''. Também em A Tarde: https://atarde.com.br/esportes/pentacampeao-mundial-seca-brasil-na-copa-nao-quero-que-ganhe-1387079 . Data aproximada (abril de 2026).'
from people where slug = 'vampeta'
  and not exists (select 1 from quotes where text = 'Eu seco a Seleção Brasileira mesmo. Não quero que ganhe a Copa de 2026.');

-- felipe-melo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Minhas genitais derrubaram ele', 'pt', '2019-03-13', 'Depois de Palmeiras 3x0 Melgar, pela Libertadores de 2019, explicando a entrada por trás em Alexis Arias que rendeu só cartão amarelo. Os peruanos pediam a expulsão.', 'materia', 'https://www.goal.com/br/not%C3%ADcias/palmeiras-minhas-genitais-derrubaram-ele---felipe-melo-explica-lance-polemico/10109gq332mwt1e8gtyo6q33hj', null, 2, 'draft', 'Fonte: Goal · Por que: Desculpa absurda para uma entrada violenta · Obs.: Conferida pelo trecho da busca (título da Goal); abra a fonte antes de aprovar.'
from people where slug = 'felipe-melo'
  and not exists (select 1 from quotes where text = 'Minhas genitais derrubaram ele');

-- renato-gaucho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Trabalho maravilhoso e nunca escutei o nome dele', 'pt', '2019-10-01', 'Técnico do Grêmio na época da semifinal da Libertadores de 2019 contra o Flamengo, sobre Jorge Jesus. Também estranhou que, aos 65 anos, Jesus nunca tivesse treinado um grande clube europeu fora de Portugal.', 'materia', 'https://www.lance.com.br/fora-de-campo/renato-gaucho-volta-falar-sobre-jorge-jesus-trabalho-maravilhoso-nunca-escutei-nome-dele.html', null, 2, 'draft', 'Fonte: Lance! · Por que: Alfinetada no técnico estrangeiro que dominava o futebol brasileiro · Obs.: Conferida pelo trecho da busca (título do Lance!); abra a fonte antes de aprovar. Só o ano é certo.'
from people where slug = 'renato-gaucho'
  and not exists (select 1 from quotes where text = 'Trabalho maravilhoso e nunca escutei o nome dele');

-- joel-santana
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Era para eu ter um busto lá na Gávea', 'pt', '2012-06-29', 'Técnico do Flamengo em 2012, respondendo às críticas da torcida e aos boatos de saída, lembrando o que já tinha conquistado no clube. Foi demitido semanas depois.', 'materia', 'https://www.bahianoticias.com.br/esportes/noticia/21297-039era-para-eu-ter-um-busto-la-na-gavea039-diz-joel-santana', null, 3, 'draft', 'Fonte: Bahia Notícias · Por que: Técnico pressionado pedindo estátua em vez de se defender · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. ''Gávea'' pode dar pista do clube. Data deduzida.'
from people where slug = 'joel-santana'
  and not exists (select 1 from quotes where text = 'Era para eu ter um busto lá na Gávea');

-- edmundo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Fui muito amigo dele, mas Romário é muito vaidoso e egocêntrico.', 'pt', '2021-10-06', 'No podcast Inteligência Ltda., explicando por que deixou de ser amigo do ex-companheiro de Vasco. Romário respondeu: ''ciúme bobo, babaquice''. Em 2022 admitiu: ''Eu também sou egocêntrico e vaidoso''.', 'materia', 'https://www.netvasco.com.br/n/279004/edmundo-revela-que-nao-e-amigo-de-romario-e-muito-vaidoso-e-egocentrico', null, 2, 'draft', 'Fonte: NetVasco · Por que: Mais um capítulo da rixa entre os dois ídolos do Vasco · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Data da publicação.'
from people where slug = 'edmundo'
  and not exists (select 1 from quotes where text = 'Fui muito amigo dele, mas Romário é muito vaidoso e egocêntrico.');

-- abel-ferreira
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Devo satisfação a três mulheres', 'pt', '2024-08-24', 'Na coletiva após Palmeiras 5x0 Cuiabá, respondendo a repórter Alinne Fanelli sobre a lesão de Mayke. As três seriam a mãe, a esposa e a presidente Leila Pereira. Acusado de machismo, pediu desculpas no dia seguinte: ''fui infeliz''.', 'materia', 'https://www.band.com.br/esportes/abel-ferreira-reage-a-pergunta-sobre-mayke-devo-satisfacao-a-tres-mulheres-202408251051', null, 2, 'draft', 'Fonte: Band · Por que: Resposta grosseira a uma repórter, vista como machista · Obs.: Conferida pelo trecho da busca (título da Band); abra a fonte antes de aprovar. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'abel-ferreira'
  and not exists (select 1 from quotes where text = 'Devo satisfação a três mulheres');

-- neymar
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Sávio é assim, acho que ele acordou meio de chico e veio assim pro jogo.', 'pt', '2026-04-02', 'Ao SporTV, depois de Santos 2x0 Remo pelo Brasileirão, sobre o árbitro que lhe deu o terceiro amarelo. A expressão, ligada a menstruação, foi chamada de machista, houve risco de denúncia no STJD e ele se explicou no YouTube dias depois.', 'entrevista', 'https://www.oliberal.com/esportes/amp/apos-vitoria-sobre-o-remo-neymar-diz-que-arbitragem-estava-de-chico-e-gera-polemica-1.1105520', null, 2, 'draft', 'Fonte: O Liberal · Por que: Fala considerada machista contra um árbitro, com repercussão internacional · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Variantes ''acordou de chico''/''está de chico''.'
from people where slug = 'neymar'
  and not exists (select 1 from quotes where text = 'Sávio é assim, acho que ele acordou meio de chico e veio assim pro jogo.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Auge por auge? Acho que eu jogaria no lugar do Rivaldo', 'pt', '2025-01-15', 'No programa De Cara com o Cara, da Romário TV, perguntado em que posição jogaria na Seleção do penta de 2002. Rivaldo respondeu nas redes que, ''100% de certeza'', isso não aconteceria.', 'video', 'https://www.correiobraziliense.com.br/esportes/2025/01/amp/7038611-guerra-de-farpas-neymar-x-rivaldo-esta-dando-o-que-falar.html', null, 2, 'draft', 'Fonte: Correio Braziliense · Por que: Neymar se colocando no lugar do melhor jogador da Copa de 2002 · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Data: janeiro de 2025, dia não confirmado. Outra fonte: https://www.lance.com.br/fora-de-campo/neymar-e-rivaldo-batem-boca-nas-redes-apos-declaracao-polemica.html'
from people where slug = 'neymar'
  and not exists (select 1 from quotes where text = 'Auge por auge? Acho que eu jogaria no lugar do Rivaldo');

-- eduardo-bolsonaro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Já fiz intercâmbio, já fritei hambúrguer lá nos Estados Unidos, no frio do Maine.', 'pt', '2019-07-11', 'Respondendo a jornalistas sobre sua qualificação para ser embaixador em Washington, logo depois de o pai anunciar que queria indicá-lo. A frase virou meme e a indicação nunca chegou ao Senado.', 'materia', 'https://jornaldebrasilia.com.br/noticias/politica-e-poder/eduardo-bolsonaro-diz-ter-qualificacao-para-ser-embaixador-ja-fritei-hamburguer-la-nos-eua/', null, 2, 'draft', 'Fonte: Jornal de Brasília · Por que: Usou emprego de intercambista como credencial para a embaixada mais importante do país · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Data: 11 ou 12/07/2019.'
from people where slug = 'eduardo-bolsonaro'
  and not exists (select 1 from quotes where text = 'Já fiz intercâmbio, já fritei hambúrguer lá nos Estados Unidos, no frio do Maine.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se a esquerda radicalizar a esse ponto, vamos precisar dar uma resposta. E essa resposta pode ser via um novo AI-5.', 'pt', '2019-10-28', 'Entrevista à jornalista Leda Nagle no YouTube (publicada em 31/10/2019), quando era líder do PSL na Câmara, falando de protestos como os do Chile. Gerou processos no Conselho de Ética e pedidos de cassação.', 'entrevista', 'https://congressoemfoco.com.br/legislativo/radicalizacao-da-esquerda-justifica-edicao-de-novo-ai-5-afirma-eduardo-bolsonaro', null, 1, 'draft', 'Fonte: Congresso em Foco · Por que: Deputado no exercício do mandato sugerindo a volta do ato mais duro da ditadura · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar.'
from people where slug = 'eduardo-bolsonaro'
  and not exists (select 1 from quotes where text = 'Se a esquerda radicalizar a esse ponto, vamos precisar dar uma resposta. E essa resposta pode ser via um novo AI-5.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Substitua a usina nuclear pelo coronavírus e a ditadura soviética pela chinesa. A culpa é da China e liberdade seria a solução.', 'pt', '2020-03-18', 'Post no Twitter no começo da pandemia, comparando a Covid a Chernobyl. A embaixada chinesa disse que ele tinha pegado um ''vírus mental'' em Miami, e Rodrigo Maia pediu desculpas à China.', 'post', 'https://www.poder360.com.br/congresso/eduardo-bolsonaro-culpa-china-por-pandemia-e-embaixada-rebate/', null, 2, 'draft', 'Fonte: Poder360 · Por que: Abriu crise diplomática com o maior parceiro comercial do Brasil · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. No tuíte original há um trecho entre as duas frases, omitido aqui. Data 17 ou 18/03.'
from people where slug = 'eduardo-bolsonaro'
  and not exists (select 1 from quotes where text = 'Substitua a usina nuclear pelo coronavírus e a ditadura soviética pela chinesa. A culpa é da China e liberdade seria a solução.');

-- lula
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Porque o homem é covarde. As mulheres aprendem a tomar toque desde pequenas. O homem não, ele é cheio de trejeito.', 'pt', '2026-09-28', 'Comício em Belém, falando de cirurgia de próstata. Nikolas Ferreira usou o trecho para acusar Lula de alusão à pedofilia; o Aos Fatos classificou a acusação como enganosa e a campanha foi ao TSE.', 'materia', 'https://www.diariodepernambuco.com.br/politica/2026/09/11725307-mulheres-sao-corajosas-fazem-exame-e-nao-tem-medo-enfatiza-lula-sobre-fala-do-toque.html', null, 2, 'draft', 'Fonte: Diário de Pernambuco · Por que: Comparação desastrada que virou munição para a oposição em plena campanha · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar.'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Porque o homem é covarde. As mulheres aprendem a tomar toque desde pequenas. O homem não, ele é cheio de trejeito.');

-- janja
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Lá no Paraná a gente costuma chamar os meninos de ''piá''. E quando a gente sabe que tem alguma coisa errada, a gente chama de ''piá de bosta''.', 'pt', '2026-09-29', 'Ato de campanha de Lula em Salvador, respondendo a Nikolas Ferreira, que tinha atacado a fala de Lula sobre o ''toque''. Repetiu o xingamento em BH, e Flávio e Michelle Bolsonaro passaram a chamar Nikolas de ''piá'' como elogio.', 'video', 'https://www.bahianoticias.com.br/noticia/321714-video-janja-chama-nikolas-ferreira-de-pia-de-bosta-durante-ato-de-campanha-com-lula-em-salvador', null, 2, 'draft', 'Fonte: Bahia Notícias · Por que: Primeira-dama xingando um deputado num palanque · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Data deduzida de ''terça-feira''.'
from people where slug = 'janja'
  and not exists (select 1 from quotes where text = 'Lá no Paraná a gente costuma chamar os meninos de ''piá''. E quando a gente sabe que tem alguma coisa errada, a gente chama de ''piá de bosta''.');

-- michel-temer
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Passei os quatro primeiros anos de governo como vice decorativo.', 'pt', '2015-12-07', 'Carta de desabafo enviada a Dilma e vazada na mesma noite, listando 11 episódios em que se sentiu desprestigiado. Veio em meio ao processo de impeachment e virou chuva de memes.', 'materia', 'https://www.migalhas.com.br/quentes/231163/temer-envia-carta-a-dilma-e-aponta-desconfianca-do-governo', null, 2, 'draft', 'Fonte: Migalhas · Por que: O vice se queixando por escrito à presidente, meses antes de substituí-la · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar.'
from people where slug = 'michel-temer'
  and not exists (select 1 from quotes where text = 'Passei os quatro primeiros anos de governo como vice decorativo.');

-- ciro-gomes
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'O Moro que mande me prender, eu recebo a turma dele na bala.', 'pt', '2017-03-21', 'Vídeo que circulou no WhatsApp, gravado no dia em que a PF fez condução coercitiva do blogueiro Eduardo Guimarães por ordem de Moro. Em 2018 disse que foi tirada de contexto.', 'video', 'https://www.infomoney.com.br/?p=65207', null, 2, 'draft', 'Fonte: InfoMoney · Por que: Um presidenciável ameaçando receber a polícia a bala · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Data da gravação não confirmada; viralizou por volta de 27/03/2017.'
from people where slug = 'ciro-gomes'
  and not exists (select 1 from quotes where text = 'O Moro que mande me prender, eu recebo a turma dele na bala.');

-- jair-bolsonaro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Pintou um clima, voltei: ''posso entrar na tua casa?'' Entrei.', 'pt', '2022-10-14', 'Podcast Paparazzo Rubro-Negro, na campanha de 2022, contando que tinha encontrado meninas venezuelanas de 14 e 15 anos em São Sebastião (DF). O trecho virou propaganda do PT, foi levado ao STF e ele pediu desculpas.', 'entrevista', 'https://diariodopara.com.br/noticias/brasil/bolsonaro-diz-que-pintou-um-clima-com-menininhas-de-14-e-15-anos/', null, 1, 'draft', 'Fonte: Diário do Pará · Por que: Fala sobre adolescentes que gerou acusações em plena eleição · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Pode ser famosa demais.'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'Pintou um clima, voltei: ''posso entrar na tua casa?'' Entrei.');

-- donald-trump
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'E então eu vejo o desinfetante, que acaba com ele em um minuto. Um minuto. Existe uma forma de fazermos algo assim, por injeção lá dentro, quase como uma limpeza?', 'pt', '2020-04-23', 'Coletiva da força-tarefa da Covid na Casa Branca, logo após uma apresentação sobre luz e desinfetantes. A fabricante do Lysol avisou para não usar o produto no corpo; no dia seguinte ele disse que era ''sarcasmo''.', 'video', 'https://www.snopes.com/fact-check/trump-disinfectants-covid-19', null, 1, 'draft', 'Original: And then I see the disinfectant, where it knocks it out in a minute. One minute. And is there a way we can do something like that, by injection inside or almost a cleaning? · Fonte: Snopes · Por que: Um presidente sugerindo injetar desinfetante em plena pandemia · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Parte do original em inglês não apareceu no trecho; confira na transcrição.'
from people where slug = 'donald-trump'
  and not exists (select 1 from quotes where text = 'E então eu vejo o desinfetante, que acaba com ele em um minuto. Um minuto. Existe uma forma de fazermos algo assim, por injeção lá dentro, quase como uma limpeza?');

-- paulo-guedes
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Todo mundo indo para a Disneylândia, empregada doméstica indo para Disneylândia, uma festa danada.', 'pt', '2020-02-12', 'Seminário em Brasília, defendendo o dólar alto. Depois de forte reação e de uma doméstica desafiá-lo em vídeo, pediu desculpas dizendo que a avó tinha sido empregada.', 'materia', 'https://www.poder360.com.br/governo/guedes-pede-desculpas-a-empregadas-mae-do-meu-pai-foi-domestica/', null, 2, 'draft', 'Fonte: Poder360 · Por que: Preconceito de classe explícito vindo do ministro da Economia · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'paulo-guedes'
  and not exists (select 1 from quotes where text = 'Todo mundo indo para a Disneylândia, empregada doméstica indo para Disneylândia, uma festa danada.');

-- datena
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Um sujeito que é ateu não tem limites.', 'pt', '2010-07-27', 'Ao vivo no Brasil Urgente (Band), comentando um crime bárbaro, ligou o assassinato ao suposto ateísmo do autor. O MPF processou a emissora e a Justiça obrigou a Band a exibir uma campanha dizendo que o Estado não tem religião oficial, além de indenização.', 'materia', 'https://www.bahianoticias.com.br/justica/noticia/45546-justica-condena-bandeirantes-por-declaracao-de-datena-sobre-ateus', null, 2, 'draft', 'Fonte: Bahia Notícias · Por que: Fala preconceituosa ao vivo que terminou em condenação e direito de resposta · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Data citada pelo MPF.'
from people where slug = 'datena'
  and not exists (select 1 from quotes where text = 'Um sujeito que é ateu não tem limites.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se tiver alguém vendo vocês na minha casa, eu chuto a televisão.', 'pt', '2016-02-01', 'Ao vivo no Brasil Urgente, atacando a Globo por ter questionado o uso de um helicóptero na homenagem a um policial morto. No mesmo desabafo gritou ''eu quero que vocês se explodam'' para a emissora rival.', 'materia', 'https://www.jornalopcao.com.br/colunas-e-blogs/imprensa/datena-ataca-tv-globo-eu-quero-que-voces-se-explodam-58517/', null, 2, 'draft', 'Fonte: Jornal Opção · Por que: Ataque ao vivo de um apresentador a uma emissora concorrente · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Só o mês é certo (fev/2016).'
from people where slug = 'datena'
  and not exists (select 1 from quotes where text = 'Se tiver alguém vendo vocês na minha casa, eu chuto a televisão.');

-- silvio-santos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Mulher não tem o direito de ser feia.', 'pt', '2017-07-09', 'No Jogo das Três Pistas do seu programa no SBT, com Manu Gavassi e Marthina Brandt no palco, comparando as mulheres a travestis que ''se arrumam e ficam bonitas''. Foi criticado como machista numa série de polêmicas dele em 2017.', 'materia', 'https://www.uai.com.br/app/noticia/series-e-tv/2017/07/10/noticias-series-e-tv,209422/mulher-nao-tem-o-direito-de-ser-feia-diz-silvio-santos.shtml', null, 2, 'draft', 'Fonte: Uai (Estado de Minas) · Por que: Machismo explícito ao vivo na TV aberta · Obs.: Conferida pelo trecho da busca (título da matéria); abra a fonte antes de aprovar.'
from people where slug = 'silvio-santos'
  and not exists (select 1 from quotes where text = 'Mulher não tem o direito de ser feia.');

-- luan-santana
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Comecei a me questionar se sentava de um jeito muito afetado.', 'pt', '2019-10-20', 'Entrevista à revista Veja, contando que os boatos de que seria gay, no começo da carreira, o incomodaram a ponto de questionar até o jeito de sentar.', 'materia', 'https://www.maisgoias.com.br/entretenimento/luan-santana-sobre-boatos-de-homossexualidade-comecei-a-me-questionar-se-sentava-de-um-jeito-muito-afetado/', null, 3, 'draft', 'Fonte: Mais Goiás · Por que: Confissão íntima e inesperada de um galã sertanejo · Obs.: Conferida pelo trecho da busca (título); abra a fonte antes de aprovar. Data da publicação na Veja.'
from people where slug = 'luan-santana'
  and not exists (select 1 from quotes where text = 'Comecei a me questionar se sentava de um jeito muito afetado.');

-- ney-matogrosso
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Que gay o caralho, eu sou um ser humano.', 'pt', '2017-07-01', 'Entrevista à Folha de S.Paulo, recusando o rótulo de gay. Johnny Hooker rebateu que era ''inconcebível'' ler isso ''no país que mais mata LGBTs do mundo''.', 'materia', 'https://www.correio24horas.com.br/noticia/nid/nao-da-para-se-valer-de-humanismo-abstrato-diz-johnny-hooker-sobre-fala-de-ney-matogrosso', null, 2, 'draft', 'Fonte: Correio (Salvador) · Por que: Ícone LGBT rejeitando o rótulo, o que gerou briga com um artista mais jovem · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Tem palavrão. Só o mês é certo (jul/2017).'
from people where slug = 'ney-matogrosso'
  and not exists (select 1 from quotes where text = 'Que gay o caralho, eu sou um ser humano.');

-- roberto-carlos
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Não existiu jogar pedaço de pão, é mentira.', 'pt', '2015-02-01', 'Em coletiva, negou uma cena da cinebiografia de Tim Maia em que levava pães jogados pelo ex-amigo e disse que foi ''falta de ética'' colocar isso no filme. A Globo já tinha cortado outra cena que o desfavorecia.', 'materia', 'https://exame.com/casual/roberto-carlos-chama-de-mentira-cena-de-filme-sobre-tim-maia', null, 3, 'draft', 'Fonte: Exame · Por que: Chamando de mentira um filme sobre o ex-amigo · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Só o mês é certo (fev/2015).'
from people where slug = 'roberto-carlos'
  and not exists (select 1 from quotes where text = 'Não existiu jogar pedaço de pão, é mentira.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quando fico com reiva, nem Juma segura.', 'pt', '2022-07-27', 'Num show em São Paulo, explicando por que tinha mandado um fã ''calar a boca, porra'' num show no Rio uma semana antes, brincando com a personagem Juma, da novela Pantanal.', 'materia', 'https://www.metropoles.com/entretenimento/musica/roberto-sobre-cala-boca-quando-fico-com-reiva-nem-juma-segura', null, 2, 'draft', 'Fonte: Metrópoles · Por que: O artista sempre comedido admitindo o pavio curto depois de xingar um fã ao vivo · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. ''Reiva'' pode dar pista (''rei''). Data 27 ou 28/07.'
from people where slug = 'roberto-carlos'
  and not exists (select 1 from quotes where text = 'Quando fico com reiva, nem Juma segura.');

-- lobao
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Acho que o intelectual de esquerda é o campeão mundial de punheta de pau mole.', 'pt', '2020-06-01', 'No Roda Viva (TV Cultura), já rompido com Bolsonaro. Na mesma entrevista disse que a direita ''não tem intelectuais, tem recalcados''.', 'entrevista', 'https://www.metropoles.com/brasil/politica-brasil/lobao-no-roda-viva-esquerda-tem-pau-mole-e-direita-recalcados', null, 2, 'draft', 'Fonte: Metrópoles · Por que: Ataque grosseiro à esquerda num programa de entrevistas tradicional · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Vulgar. Data aproximada.'
from people where slug = 'lobao'
  and not exists (select 1 from quotes where text = 'Acho que o intelectual de esquerda é o campeão mundial de punheta de pau mole.');

-- tim-maia
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Roberto Carlos não vai se ver nunca livre de mim. Quando a gente morrer, lá em cima eu vou dizer: ''Como é que é, Roberto!''', 'pt', '1992-01-01', 'Entrevista ao historiador Paulo César de Araújo, reproduzida no livro ''O Réu e o Rei'', provocando o ex-parceiro de banda com quem teve relação conturbada.', 'materia', 'https://www.diariodocentrodomundo.com.br/como-funciona-a-operacao-de-limpeza-de-imagem-de-roberto-carlos-na-tv-globo/', null, 2, 'draft', 'Fonte: Diário do Centro do Mundo · Por que: Alfinetada bem-humorada no Rei, de um ex-amigo · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Só o ano. Fonte opinativa.'
from people where slug = 'tim-maia'
  and not exists (select 1 from quotes where text = 'Roberto Carlos não vai se ver nunca livre de mim. Quando a gente morrer, lá em cima eu vou dizer: ''Como é que é, Roberto!''');

-- xuxa
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Taís, eu gostaria de vir com a sua cor, o seu cabelo e a sua pele.', 'pt', '2021-03-01', 'No Superbonita (GNT), Taís Araújo perguntou como ela gostaria de vir numa próxima vida. Taís rebateu: ''Ser preta não é mole não''. Viralizou em abril de 2021 e foi criticada por romantizar a experiência de ser negra.', 'materia', 'https://www.agazeta.com.br/entretenimento/famosos/xuxa-e-criticada-por-dizer-a-tais-araujo-que-queria-ser-negra-na-proxima-vida-0421', null, 2, 'draft', 'Fonte: A Gazeta · Por que: Fala racialmente desastrada, com resposta afiada na hora · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Só o mês é certo.'
from people where slug = 'xuxa'
  and not exists (select 1 from quotes where text = 'Taís, eu gostaria de vir com a sua cor, o seu cabelo e a sua pele.');

-- rita-lee
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Nenhum político se atreverá a comparecer ao meu velório, uma vez que nunca compareci ao palanque de nenhum deles e me levantaria do caixão para vaiá-los.', 'pt', '2016-01-01', 'No texto ''Profecia'', que fecha sua autobiografia de 2016. O trecho voltou a circular quando ela morreu, em maio de 2023.', 'materia', 'https://istoe.com.br/rita-lee-escreveu-profecia-sobre-a-repercussao-de-sua-morte-em-autobiografia-de-2016/', null, 2, 'draft', 'Fonte: IstoÉ · Por que: Desprezo bem-humorado pelos políticos · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Escrita, não falada. Só o ano.'
from people where slug = 'rita-lee'
  and not exists (select 1 from quotes where text = 'Nenhum político se atreverá a comparecer ao meu velório, uma vez que nunca compareci ao palanque de nenhum deles e me levantaria do caixão para vaiá-los.');

-- zeca-pagodinho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu, minha família, meus amigos, todo mundo é Lula, não tem outro.', 'pt', '2026-09-23', 'No ato ''Cultura com Lula'', na Fundição Progresso (Rio), semanas depois de circular um vídeo falso feito com IA em que ele pedia voto para Flávio Bolsonaro.', 'materia', 'https://www.em.com.br/politica/2026/09/7507442-zeca-pagodinho-eu-minha-familia-meus-amigos-todo-mundo-e-lula.html', null, 2, 'draft', 'Fonte: Estado de Minas · Por que: Sambista que foge de política declarando voto, em resposta a um deepfake · Obs.: Conferida pelo trecho da busca (título); abra a fonte antes de aprovar.'
from people where slug = 'zeca-pagodinho'
  and not exists (select 1 from quotes where text = 'Eu, minha família, meus amigos, todo mundo é Lula, não tem outro.');

-- carlinhos-maia
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'É a união de dois caras, não é casamento gay.', 'pt', '2019-01-01', 'Entrevista ao TV Fama nos bastidores da São Paulo Fashion Week de 2019, falando do casamento com Lucas Guimarães. Foi acusado de homofobia internalizada e depois explicou a fala no Programa Raul Gil.', 'materia', 'https://www.bahianoticias.com.br/holofote/noticia/54684-carlinhos-maia-e-chamado-de-homofobico-por-falar-que-seu-matrimonio-nao-e-casamento-gay', null, 2, 'draft', 'Fonte: Bahia Notícias · Por que: Influenciador gay negando que o próprio casamento seja gay; a fala rendeu acusação de homofobia · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. A frase completa continua com ''É a união de Carlinhos e Lucas'' (cortado porque entrega a resposta). Só o ano é certo.'
from people where slug = 'carlinhos-maia'
  and not exists (select 1 from quotes where text = 'É a união de dois caras, não é casamento gay.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Já fiz sexo no banheiro de uma rádio que a gente trabalhava.', 'pt', '2020-01-01', 'Entrevista ao canal de Matheus Mazzafera no YouTube, em janeiro de 2020. A rádio era evangélica, e a comunidade evangélica reagiu com críticas.', 'materia', 'https://www.jornalopcao.com.br/ultimas-noticias/comunidade-evangelica-reage-a-declaracao-polemica-de-carlinhos-maia-228920/', null, 2, 'draft', 'Fonte: Jornal Opção · Por que: Confissão de sexo numa rádio evangélica que gerou revolta religiosa · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Pode haver pequena diferença de redação. Só mês e ano certos (jan/2020).'
from people where slug = 'carlinhos-maia'
  and not exists (select 1 from quotes where text = 'Já fiz sexo no banheiro de uma rádio que a gente trabalhava.');

-- casimiro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Vamos falar a verdade, a Globo não gosta da gente.', 'pt', '2023-01-01', 'Em live depois de transmitir a Copa do Catar, ao explicar que seria difícil transmitir as Olimpíadas porque a Globo tem 100% dos direitos.', 'materia', 'https://www.lance.com.br/fora-de-campo/casimiro-abre-o-jogo-sobre-relacao-com-a-tv-globo-nao-gostam-da-gente.html', null, 2, 'draft', 'Fonte: Lance! · Por que: Streamer acusando abertamente a maior emissora do país de hostilidade · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Data não confirmada (fim de 2022 ou início de 2023).'
from people where slug = 'casimiro'
  and not exists (select 1 from quotes where text = 'Vamos falar a verdade, a Globo não gosta da gente.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu vou votar no Barba. Se o Bolsonaro está de um lado, tô do outro.', 'pt', '2022-10-03', 'Live na Twitch depois do 1º turno de 2022, respondendo ao chat; ''Barba'' é o apelido de Lula. Semanas depois, Flávio Bolsonaro postou uma montagem dele com o número 22, e o desmentido passou de 1 milhão de curtidas.', 'materia', 'https://www.dci.com.br/esporte/casimiro-declara-voto-em-lula-no-segundo-turno-das-eleicoes-2022/', null, 2, 'draft', 'Fonte: DCI · Por que: O maior streamer do país declarando voto ao vivo e entrando na guerra eleitoral · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Trecho original: ''Se o Bolsonaro está de um lado e tô do outro''. Data aproximada (3/10/2022 ou dia anterior).'
from people where slug = 'casimiro'
  and not exists (select 1 from quotes where text = 'Eu vou votar no Barba. Se o Bolsonaro está de um lado, tô do outro.');

-- felipe-castanhari
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Você pode tentar me processar por este post também. Quando eu ganhar, farei outra publicação esfregando isso nessa sua cara sem graça.', 'pt', '2021-01-21', 'Post no Instagram contra Marcius Melhem, a quem chamou de assediador, em defesa de Dani Calabresa. A Justiça mandou apagar e o condenou a pagar R$ 100 mil; a condenação foi suspensa depois pelo TJ-SP.', 'materia', 'https://catracalivre.com.br/cidadania/acusando-de-censura-castanhari-chama-melhem-de-assediador/', null, 3, 'draft', 'Fonte: Catraca Livre · Por que: Provocação direta que terminou em condenação de R$ 100 mil · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Original começa com ''Você, Melhem, pode tentar...'' (nome cortado). Também em A Gazeta: https://www.agazeta.com.br/entretenimento/famosos/justica-suspende-multa-de-r-100-mil-de-castanhari-a-marcius-melhem-0721'
from people where slug = 'felipe-castanhari'
  and not exists (select 1 from quotes where text = 'Você pode tentar me processar por este post também. Quando eu ganhar, farei outra publicação esfregando isso nessa sua cara sem graça.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Chama a GKay, entrevista a GKay aí, que vocês vão entender.', 'pt', '2022-10-01', 'No podcast Groselha Talk, em outubro de 2022, ao ser perguntado se iria à Farofa da GKay. Chamou a influenciadora de ''insuportável'' e insinuou que ela maltrata funcionários; o vídeo viralizou.', 'entrevista', 'https://www.correiobraziliense.com.br/diversao-e-arte/2022/10/5043562-felipe-castanhari-detona-gkay-nao-admito-quem-maltrata-as-pessoas.html', null, 3, 'draft', 'Fonte: Correio Braziliense · Por que: Youtuber detonando publicamente outra influenciadora gigante · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Frase vista no trecho do TNH1 (Folhapress): https://www.tnh1.com.br/noticia/nid/castanhari-detona-gkay-e-a-acusa-de-maltratar-funcionarios/. Só mês e ano certos.'
from people where slug = 'felipe-castanhari'
  and not exists (select 1 from quotes where text = 'Chama a GKay, entrevista a GKay aí, que vocês vão entender.');

-- lionel-messi
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Fui o único jogador que não teve reconhecimento, dos outros 25 jogadores, mas tudo bem.', 'pt', '2023-09-20', 'Entrevista a Migue Granados (Olga), já no Inter Miami, sobre o PSG não tê-lo homenageado pelo título da Copa de 2022, conquistado contra a França. O presidente do PSG, Al-Khelaifi, rebateu.', 'materia', 'https://www.ntn24.com/noticias-deportes/yo-no-estaba-bien-me-toco-ser-campeon-del-mundo-ahi-messi-sobre-su-salida-del-psg-445521', null, 3, 'draft', 'Original: Fui el único jugador que no tuvo reconocimiento, además de los otros 25 jugadores, pero bueno · Fonte: NTN24 · Por que: Messi, sempre discreto, alfinetando publicamente o ex-clube · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Redação varia entre veículos. Data aproximada (matérias de 21/9/2023).'
from people where slug = 'lionel-messi'
  and not exists (select 1 from quotes where text = 'Fui o único jogador que não teve reconhecimento, dos outros 25 jogadores, mas tudo bem.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'No vestiário pensei que acabou para mim a seleção, não é para mim.', 'pt', '2016-06-26', 'Na zona mista do MetLife Stadium, depois de perder a final da Copa América Centenário para o Chile nos pênaltis (ele errou a cobrança), sua quarta final perdida pela seleção. Voltou atrás cerca de dois meses depois.', 'materia', 'https://www.cooperativa.cl/noticias/deportes/copa-america/ee-uu-2016/lionel-messi-se-termino-para-mi-la-seleccion/2016-06-27/003559.html', null, 2, 'draft', 'Original: En el vestuario pensé que se terminó para mí la Selección, no es para mí · Fonte: Cooperativa (Chile) · Por que: O maior jogador do mundo anunciando que ia largar a seleção, e depois virando campeão mundial · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Também na SI: https://www.si.com/soccer/2016/06/27/messi-argentina-national-team-retire-copa-america-final'
from people where slug = 'lionel-messi'
  and not exists (select 1 from quotes where text = 'No vestiário pensei que acabou para mim a seleção, não é para mim.');

-- zlatan-ibrahimovic
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Cheguei como um rei, saio como uma lenda.', 'pt', '2016-05-13', 'Post no Twitter anunciando a saída do PSG, na véspera do último jogo no Parc des Princes, depois de quatro títulos franceses e de ter virado o maior artilheiro do clube.', 'post', 'https://www.thelocal.fr/20160513/zlatan-to-leave-psg-as-a-legend', null, 2, 'draft', 'Original: I came like a king, left like a legend · Fonte: The Local (França) · Por que: Despedida em que ele mesmo se coroa lenda · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Também na CNN: https://amp.cnn.com/cnn/2016/05/13/football/football-zlatan-ibrahimovic-psg'
from people where slug = 'zlatan-ibrahimovic'
  and not exists (select 1 from quotes where text = 'Cheguei como um rei, saio como uma lenda.');

-- kanye-west
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Quando você ouve falar de escravidão por 400 anos... Por 400 anos?! Isso parece uma escolha.', 'pt', '2018-05-01', 'No TMZ Live, depois de defender Donald Trump. O funcionário do TMZ Van Lathan o confrontou ao vivo, e a hashtag #IfSlaveryWasAChoice viralizou.', 'video', 'https://www.fox6now.com/news/kanye-west-on-tmz-live-when-you-hear-about-slavery-for-400-years-for-400-years-that-sounds-like-a-choice', null, 1, 'draft', 'Original: When you hear about slavery for 400 years. For 400 years?! That sounds like a choice. · Fonte: Fox 6 · Por que: Uma das falas mais criticadas da carreira dele, com reação imediata ao vivo · Obs.: Conferida pelo trecho da busca (está no título da matéria); abra a fonte antes de aprovar.'
from people where slug = 'kanye-west'
  and not exists (select 1 from quotes where text = 'Quando você ouve falar de escravidão por 400 anos... Por 400 anos?! Isso parece uma escolha.');

-- elon-musk
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Desculpa, cara pedófilo, você realmente pediu por isso.', 'pt', '2018-07-15', 'Tuíte contra Vernon Unsworth, mergulhador do resgate na caverna da Tailândia que tinha chamado de marketing o minissubmarino oferecido por Musk. Musk apagou o tuíte, pediu desculpas e foi processado por difamação (venceu em 2019).', 'post', 'https://www.ctvnews.ca/world/elon-musk-calls-british-cave-diver-who-helped-in-thailand-rescue-a-pedo-1.4014746', null, 2, 'draft', 'Original: Sorry pedo guy, you really did ask for it. · Fonte: CTV News · Por que: O homem mais rico do mundo chamando de pedófilo um herói do resgate, o que acabou em processo · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Acusação pesada contra pessoa real; avalie se quer no jogo.'
from people where slug = 'elon-musk'
  and not exists (select 1 from quotes where text = 'Desculpa, cara pedófilo, você realmente pediu por isso.');

-- jose-mourinho
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Se eu quisesse um trabalho fácil, teria ficado no Porto: uma bela cadeira azul, a taça da Champions, Deus e, depois de Deus, eu.', 'pt', '2004-01-01', 'Entrevista em 2004, semanas depois de trocar o Porto campeão europeu pelo Chelsea, explicando por que tinha deixado o clube português.', 'materia', 'https://scroll.in/field/826697/the-making-of-the-master-manipulator-why-jose-mourinho-is-jurgen-klopps-antithesis', null, 2, 'draft', 'Original: If I wanted to have an easy job... I would have stayed at Porto – beautiful blue chair, the UEFA Champions League trophy, God, and after God, me. · Fonte: Scroll.in · Por que: Ego no nível divino: ele se coloca logo abaixo de Deus · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. O trecho confirmou ''God, and after God, me''; o resto foi montado de resumos. Cita o Porto, o que pode entregar. Só o ano é certo.'
from people where slug = 'jose-mourinho'
  and not exists (select 1 from quotes where text = 'Se eu quisesse um trabalho fácil, teria ficado no Porto: uma bela cadeira azul, a taça da Champions, Deus e, depois de Deus, eu.');

-- felipe-neto
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, status, review_note)
select id, 'Eu fui no shopping hoje afogar as mágoas e comprar coisas pra tentar me sentir melhor. Descobri por que cartões de crédito PRECISAM de limite.', 'pt', '2022-01-02', 'Tuíte dias depois do fim do namoro de cinco anos com Bruna Gomes. A um seguidor, confirmou que gastou R$ 60 mil só em roupa de cama, edredons e toalhas.', 'materia', 'https://www.correiobraziliense.com.br/diversao-e-arte/2022/01/4975002-felipe-neto-afoga-as-magoas-em-shopping-apos-termino-e-gasta-rs-60-mil.html', null, 2, 'draft', 'Fonte: Correio Braziliense · Por que: Ostentação involuntária: R$ 60 mil em lençóis para curar o término · Obs.: Conferida pelo trecho da busca; abra a fonte antes de aprovar. Data aproximada (matérias de 3/1/2022).'
from people where slug = 'felipe-neto'
  and not exists (select 1 from quotes where text = 'Eu fui no shopping hoje afogar as mágoas e comprar coisas pra tentar me sentir melhor. Descobri por que cartões de crédito PRECISAM de limite.');

commit;
