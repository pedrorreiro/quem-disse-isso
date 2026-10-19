-- Carga 15: polêmicas de Flávio Bolsonaro (pessoa nova) e mais de Lula e Jair Bolsonaro, com foco em 2026.
-- Fontes: CNN Brasil, Poder360, Correio Braziliense e Terra. Os textos vêm do que o agente leu nas matérias; confira o
-- review_note antes de aprovar.
-- Bolsonaro está preso desde novembro de 2025 e quase não deu declarações em 2026. Por isso as falas dele aqui são do
-- fim de 2025, mais a "Papuda lhe espera" (2017), que governistas ressuscitaram em janeiro de 2026.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão.
-- Pode rodar mais de uma vez: não duplica frases.

begin;

-- Pessoa nova
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Flávio Bolsonaro', 'flavio-bolsonaro', 'politica', 'politica', 'm', 'BR', 'Senador pelo Rio de Janeiro, filho mais velho de Jair Bolsonaro e candidato do PL a presidente em 2026')
on conflict (slug) do nothing;

-- flavio-bolsonaro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Tem uma possibilidade de eu não ir até o fim e eu tenho um preço para isso, que eu vou negociar.', 'pt', '2025-12-07', 'Dois dias depois de lançar a pré-candidatura a presidente, falando a jornalistas após um culto. Perguntado se o preço era a anistia ao pai, respondeu: "Está quente". A candidatura foi vista como moeda de troca, e a bolsa caiu forte com o anúncio.', 'entrevista', 'https://www.cnnbrasil.com.br/eleicoes/flavio-diz-que-existe-um-preco-para-seguir-com-candidatura-ate-o-fim/', null, 1, 'polemica', 'draft', 'Fonte: CNN Brasil · Por que: Candidatura a presidente com "preço" para desistir · Obs.: Ver também https://www.terra.com.br/noticias/brasil/flavio-bolsonaro-indica-que-sua-pre-candidatura-e-moeda-de-troca,7c0e0f4dded13987401a3abcdf2ac386hu7njj2x.html. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'flavio-bolsonaro'
  and not exists (select 1 from quotes where text = 'Tem uma possibilidade de eu não ir até o fim e eu tenho um preço para isso, que eu vou negociar.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Ele me relatou uma história bastante plausível e me garantiu que não teria nenhuma ilegalidade nas suas movimentações', 'pt', null, 'Sobre Fabrício Queiroz, seu ex-assessor, depois que o Coaf apontou movimentações atípicas na conta dele. Flávio nunca contou que história era essa, e o caso virou a investigação da "rachadinha".', 'entrevista', 'https://www.terra.com.br/noticias/brasil/os-capitulos-do-caso-queiroz,71db39bb413e389cc86be9770191fc76viuf4gkq.html', null, 1, 'polemica', 'draft', 'Fonte: Terra · Por que: A "história plausível" que nunca foi contada · Obs.: Sem data exata; dita em dezembro de 2018, quando ele era senador eleito.'
from people where slug = 'flavio-bolsonaro'
  and not exists (select 1 from quotes where text = 'Ele me relatou uma história bastante plausível e me garantiu que não teria nenhuma ilegalidade nas suas movimentações');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'A sanção que o Trump impõe não é meramente econômica, todos nós sabemos disso.', 'pt', '2025-07-10', 'Em entrevista à GloboNews, dias depois de Trump anunciar tarifa de 50% sobre produtos brasileiros, defendendo a anistia aos condenados do 8 de Janeiro como saída. A fala foi lida como admissão de que o tarifaço era pressão pelo pai. Dias depois, ele apagou um post sugerindo que Trump trocasse a tarifa por sanções individuais.', 'entrevista', 'https://www.terra.com.br/noticias/brasil/politica/o-que-familia-bolsonaro-ja-falou-sobre-influencia-no-tarifaco-de-trump-veja,4e6e9ca368c00ac7e0168d82fab7459715e3j9h3.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Senador admitindo que o tarifaço era político'
from people where slug = 'flavio-bolsonaro'
  and not exists (select 1 from quotes where text = 'A sanção que o Trump impõe não é meramente econômica, todos nós sabemos disso.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Se alguém não entende a razão da minha obrigação de me comportar daquele jeito, eu peço desculpas.', 'pt', '2026-05-15', 'Em entrevista à CNN, pedindo desculpas por ter negado relação com Daniel Vorcaro, dono do Banco Master. O Intercept tinha divulgado áudios e mensagens em que ele pedia ao banqueiro cerca de R$ 134 milhões para o filme "Dark Horse", sobre o pai.', 'entrevista', 'https://www.cnnbrasil.com.br/politica/a-cnn-flavio-pede-desculpas-por-negar-relacao-com-vorcaro/', null, 2, 'polemica', 'draft', 'Fonte: CNN Brasil · Por que: Desculpas depois de ser pego negando relação com Vorcaro · Obs.: Reportagem do Intercept em https://www.cnnbrasil.com.br/politica/flavio-pediu-r-134-mi-a-vorcaro-para-filme-de-bolsonaro-diz-intercept/'
from people where slug = 'flavio-bolsonaro'
  and not exists (select 1 from quotes where text = 'Se alguém não entende a razão da minha obrigação de me comportar daquele jeito, eu peço desculpas.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu estou falando de um pedido de um patrocínio privado para um filme privado, sem absolutamente nenhuma contrapartida', 'pt', '2026-10-16', 'Na sabatina da TV Globo, defendendo o pedido de R$ 134 milhões a Daniel Vorcaro para o filme sobre o pai. Segundo a PF, ele recebeu quase R$ 70 milhões, que foram para um fundo nos EUA e não para a produtora. Ele é investigado no STF pelo caso.', 'entrevista', 'https://www.correiobraziliense.com.br/mundo/2026/10/7522555-flavio-bolsonaro-na-globo-o-que-disse-o-candidato-a-presidencia-na-2-entrevista-a-emissora.html', null, 2, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: R$ 134 milhões do dono do Master "sem contrapartida"'
from people where slug = 'flavio-bolsonaro'
  and not exists (select 1 from quotes where text = 'Eu estou falando de um pedido de um patrocínio privado para um filme privado, sem absolutamente nenhuma contrapartida');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Em nenhum momento ofendi ou tive a intenção de ofender a Michelle.', 'pt', '2026-06-25', 'Resposta a vídeos em que Michelle Bolsonaro, sua madrasta, disse ter sido maltratada e humilhada por ele, que teria dito que ela não entendia de política, na briga sobre a aliança do PL no Ceará. Na mesma nota, pediu desculpas "mais uma vez".', 'post', 'https://www.correiobraziliense.com.br/politica/2026/06/7448517-flavio-bolsonaro-diz-que-nao-ofendeu-michelle-se-fiz-peco-desculpas.html', null, 2, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: Racha público com a madrasta em plena pré-campanha'
from people where slug = 'flavio-bolsonaro'
  and not exists (select 1 from quotes where text = 'Em nenhum momento ofendi ou tive a intenção de ofender a Michelle.');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Suspeito que o Lula está ficando meio Biden', 'pt', '2026-06-23', 'Na Feicorte, em Presidente Prudente (SP), ao lado de Tarcísio, insinuando que Lula, aos 80 anos, não teria condições de seguir no cargo, como Joe Biden, que desistiu da reeleição em 2024.', 'discurso', 'https://www.poder360.com.br/poder-eleicoes/flavio-compara-lula-a-biden-e-confirma-ida-aos-eua-contra-taxas/', null, 2, 'polemica', 'draft', 'Fonte: Poder360 · Por que: Ataque à idade de Lula · Obs.: A matéria não registra reação à frase; avalie se passa no critério.'
from people where slug = 'flavio-bolsonaro'
  and not exists (select 1 from quotes where text = 'Suspeito que o Lula está ficando meio Biden');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Corrupto tem duas letrinhas: ''PT''', 'pt', '2026-10-18', 'No debate da Band do segundo turno, mostrando "corruPTo" escrito na palma da mão justamente quando Lula o questionava sobre o banqueiro Daniel Vorcaro. A "cola na mão", como fazia o pai, virou assunto nas redes.', 'video', 'https://terra.com.br/noticias/eleicoes/provocacoes-bronca-e-falso-alarme-de-bomba-o-debate-entre-flavio-bolsonaro-e-lula-em-7-pontos,229aaed7065dd27f8196692a58196065yy45xwbi.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: A mão escrita "corruPTo" no debate · Obs.: Repercussão moderada; talvez sirva melhor como icônica.'
from people where slug = 'flavio-bolsonaro'
  and not exists (select 1 from quotes where text = 'Corrupto tem duas letrinhas: ''PT''');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'O verdadeiro golpe que está acontecendo é o do atual presidente', 'pt', '2026-10-16', 'Na sabatina da Globo, depois de negar que o 8 de Janeiro tenha sido tentativa de golpe, com "motoboy" escrito na mão. Ele acusava Lula de "punir" os motoboys de São Paulo na briga com o prefeito Ricardo Nunes.', 'entrevista', 'https://terra.com.br/noticias/eleicoes/assim-como-o-pai-flavio-bolsonaro-leva-cola-na-mao-em-entrevista-na-globo,565bd1875fe767eb485d01ed7c0c7f8faya1xkzt.html', null, 3, 'polemica', 'draft', 'Fonte: Terra · Por que: Negou o golpe do pai e chamou de golpe a política de motoboys · Obs.: A matéria registra mais a "cola" do que reação à frase; avalie.'
from people where slug = 'flavio-bolsonaro'
  and not exists (select 1 from quotes where text = 'O verdadeiro golpe que está acontecendo é o do atual presidente');

-- lula
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Vocês não podem permitir que prevaleça em Santa Catarina o racismo.', 'pt', '2026-06-26', 'Num estaleiro em Itajaí (SC), criticando o governador Jorginho Mello (PL) pela tentativa de acabar com as cotas raciais. No mesmo discurso, citou Hitler. O PL acionou o TSE por discurso de ódio contra os catarinenses, e o governo do estado acusou Lula de xenofobia e foi à PGR.', 'discurso', 'https://www.poder360.com.br/poder-governo/lula-cita-hitler-e-diz-querer-acabar-com-o-racismo-em-sc/', null, 2, 'polemica', 'draft', 'Fonte: Poder360 · Por que: Presidente chamando um estado de racista em ano eleitoral · Obs.: Reações em https://www.cnnbrasil.com.br/politica/pl-aciona-tse-e-acusa-lula-de-discurso-de-odio-contra-catarinenses/ e https://www.metropoles.com/brasil/governo-de-sc-diz-que-vai-acionar-pgr-por-fala-de-lula-sobre. A CNN publicou "Não pode permitir..."; o Poder360, "Vocês não podem permitir...".'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Vocês não podem permitir que prevaleça em Santa Catarina o racismo.');

insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu nunca fui esquerdista. Eu era um dirigente sindical', 'pt', '2026-06-17', 'Captada por um microfone aberto na cúpula do G7, na França, em conversa com a diretora do FMI, Kristalina Georgieva, e o chanceler alemão Friedrich Merz. Na mesma conversa, disse que "o mundo é do caminho do meio". Rogério Marinho, líder da oposição no Senado, chamou Lula de "camaleão".', 'video', 'https://www.correiobraziliense.com.br/politica/2026/06/7442949-lula-diz-que-nunca-foi-esquerdista-em-conversa-vazada-em-encontro-do-g7.html', null, 3, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: O líder do PT dizendo que nunca foi de esquerda · Obs.: Reação do Marinho em https://www.poder360.com.br/poder-governo/marinho-chama-lula-de-camaleao-apos-fala-sobre-nao-ser-de-esquerda/'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Eu nunca fui esquerdista. Eu era um dirigente sindical');

insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Só precisamos ter cuidado para não ir muito profundo e tirar um japonesinho lá de dentro', 'pt', '2026-05-18', 'Brincadeira com a presidente da Petrobras, Magda Chambriard, num anúncio da estatal, ao falar de exploração em águas profundas com o México. Entrou na lista de 19 declarações controversas de Lula no primeiro semestre feita pelo Poder360.', 'discurso', 'https://www.poder360.com.br/poder-governo/petrobras-deve-cuidar-para-nao-tirar-japonesinho-do-pre-sal-diz-lula/', null, 3, 'polemica', 'draft', 'Fonte: Poder360 · Por que: Piada com "japonesinho" num evento oficial · Obs.: A repercussão é mais editorial (lista de gafes do Poder360) do que nota de entidade; avalie se passa no critério.'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Só precisamos ter cuidado para não ir muito profundo e tirar um japonesinho lá de dentro');

insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'A pessoa não sabe qual delegado vai encontrar', 'pt', '2026-06-10', 'Explicando por que quem recebesse um celular roubado poderia devolvê-lo nos Correios em vez de numa delegacia, no anúncio de uma nova fase do Celular Seguro. O sindicato dos delegados de São Paulo (Sindesp) reagiu defendendo o papel da polícia.', 'discurso', 'https://www.poder360.com.br/poder-governo/lula-acumula-19-declaracoes-controversas-e-lapsos-no-1o-semestre-de-2026/', null, 3, 'polemica', 'draft', 'Fonte: Poder360 · Por que: Presidente desconfiando dos delegados em público · Obs.: A fala vem como trecho entre aspas no levantamento do Poder360; procure a matéria específica do Celular Seguro se quiser uma fonte mais direta.'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'A pessoa não sabe qual delegado vai encontrar');

-- jair-bolsonaro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu meti o ferro quente aí. Curiosidade', 'pt', '2025-11-22', 'Em vídeo gravado por uma agente da Seape-DF, explicando as marcas na tornozeleira eletrônica. Perguntado que ferro era, respondeu: "Ferro de soldar". Horas depois, Alexandre de Moraes mandou prendê-lo preventivamente, e a frase virou meme e até paródia sertaneja.', 'video', 'https://www.cnnbrasil.com.br/politica/bolsonaro-diz-que-queimou-tornozeleira-por-curiosidade/', null, 1, 'polemica', 'draft', 'Fonte: CNN Brasil · Por que: Ex-presidente queimando a tornozeleira "por curiosidade" · Obs.: O vídeo foi divulgado em 22/11/2025.'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'Eu meti o ferro quente aí. Curiosidade');

insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'O tempo todo isso de vamos prender Bolsonaro. Eu caguei para a prisão', 'pt', '2025-02-20', 'No seminário de comunicação do PL, dias depois de a PGR denunciá-lo pela trama golpista. No dia seguinte, no mesmo evento, admitiu: "Ontem eu exagerei um pouquinho". Meses depois, foi condenado a 27 anos e preso.', 'discurso', 'https://www.cnnbrasil.com.br/politica/bolsonaro-afirma-ter-exagerado-ao-dizer-caguei-para-prisao/', null, 2, 'polemica', 'draft', 'Fonte: CNN Brasil · Por que: Desdenhou da prisão e teve que voltar atrás'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'O tempo todo isso de vamos prender Bolsonaro. Eu caguei para a prisão');

insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'A Papuda lhe espera', 'pt', null, 'Em vídeo de 2017, quando ainda era deputado, comentando a lista de políticos investigados na Lava Jato. Em 15 de janeiro de 2026, quando Moraes o transferiu para a Papudinha, Boulos, Maria do Rosário e Duda Salabert republicaram o vídeo; um deputado do PT disse que a frase tinha "envelhecido mal".', 'video', 'https://www.poder360.com.br/poder-governo/governistas-republicam-fala-de-bolsonaro-papuda-lhe-espera/', null, 2, 'polemica', 'draft', 'Fonte: Poder360 · Por que: A ironia de quem acabou preso na Papuda · Obs.: Sem data exata do vídeo original (2017). Ver também https://www.metropoles.com/colunas/igor-gadelha/petistas-ressuscitam-meme-de-bolsonaro-falando-da-papuda'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'A Papuda lhe espera');

commit;
