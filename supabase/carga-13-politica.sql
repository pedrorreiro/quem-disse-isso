-- Carga 13: Política, para chegar a pelo menos 20 frases por tipo (icônicas e polêmicas).
-- Fontes: Exame, Terra, Metrópoles, Correio Braziliense e Poder360.
-- O agente não conseguiu abrir as matérias (o ambiente bloqueia os sites); os textos vêm dos trechos que a busca
-- devolveu. Por isso o review_note pede para conferir a frase na matéria antes de aprovar.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove em /admin → Fotos). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Jânio Quadros', 'janio-quadros', 'politica', 'politica', 'm', 'BR', 'Presidente que renunciou em 1961, depois de sete meses no cargo'),
  ('Tiririca', 'tiririca', 'politica', 'politica', 'm', 'BR', 'Palhaço e humorista, deputado federal desde 2011'),
  ('Enéas Carneiro', 'eneas-carneiro', 'politica', 'politica', 'm', 'BR', 'Médico e político do Prona, candidato a presidente em 1989, 1994 e 1998'),
  ('Ulysses Guimarães', 'ulysses-guimaraes', 'politica', 'politica', 'm', 'BR', 'Presidente da Assembleia Constituinte de 1988'),
  ('Romero Jucá', 'romero-juca', 'politica', 'politica', 'm', 'BR', 'Ex-senador por Roraima e ex-ministro do Planejamento de Temer'),
  ('Abraham Weintraub', 'abraham-weintraub', 'politica', 'politica', 'm', 'BR', 'Ministro da Educação de Bolsonaro entre 2019 e 2020'),
  ('Ricardo Salles', 'ricardo-salles', 'politica', 'politica', 'm', 'BR', 'Ministro do Meio Ambiente de Bolsonaro entre 2019 e 2021'),
  ('Pablo Marçal', 'pablo-marcal', 'politica', 'politica', 'm', 'BR', 'Coach e influenciador, candidato a prefeito de São Paulo em 2024')
on conflict (slug) do nothing;

-- janio-quadros
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Fi-lo porque qui-lo', 'pt', null, 'Resposta atribuída a Jânio Quadros quando um repórter perguntou por que ele tinha renunciado à Presidência, em 1961.', 'entrevista', 'https://blogs.correiobraziliense.com.br/dad/fi-lo_porque_qui-lo/', null, 1, 'iconica', 'draft', 'Fonte: Correio Braziliense · Por que: Frase mais famosa do português de político · Obs.: A própria matéria diz que a frase é "atribuída" a Jânio; não há registro confirmado. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'janio-quadros'
  and not exists (select 1 from quotes where text = 'Fi-lo porque qui-lo');
-- tiririca
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Pior do que tá não fica', 'pt', '2010-08-17', 'Slogan da primeira campanha do palhaço a deputado federal, no horário eleitoral de 2010. Ele foi o deputado mais votado do país.', 'video', 'https://www.metropoles.com/colunas/guilherme-fiuza/em-busca-da-tempestade-perfeita', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Slogan eleitoral que virou ditado · Obs.: A fonte é uma coluna que cita a frase; procure uma matéria factual se quiser. Data aproximada (início do horário eleitoral de 2010). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'tiririca'
  and not exists (select 1 from quotes where text = 'Pior do que tá não fica');
-- lula
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Nunca antes na história deste país', 'pt', null, 'Expressão que Lula usava para exaltar as realizações do governo. Virou bordão e até título de livro de Marcelo Tas, em 2009.', 'discurso', 'https://www.terra.com.br/noticias/brasil/politica/a-era-lula-veja-selecao-de-40-frases-marcantes-do-presidente,088e63fc8940b310VgnCLD200000bbcceb0aRCRD.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: O bordão do Lula'
from people where slug = 'lula'
  and not exists (select 1 from quotes where text = 'Nunca antes na história deste país');
-- eneas-carneiro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Meu nome é Enéas!', 'pt', '1989-09-15', 'O fecho dos 15 segundos de propaganda eleitoral a que ele tinha direito na campanha presidencial de 1989, falados a toda velocidade.', 'video', 'https://www.metropoles.com/brasil/politica-brasil/no-horario-eleitoral-sete-presidenciaveis-terao-tempo-de-eneas', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão do horário eleitoral · Obs.: Data aproximada (horário eleitoral de 1989). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'eneas-carneiro'
  and not exists (select 1 from quotes where text = 'Meu nome é Enéas!');
-- jair-bolsonaro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Brasil acima de tudo, Deus acima de todos', 'pt', '2018-08-01', 'Slogan da campanha de 2018, repetido em quase todos os discursos de Bolsonaro.', 'discurso', 'https://www.metropoles.com/brasil/saiba-qual-e-a-nova-frase-de-efeito-nos-discursos-de-bolsonaro', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Slogan de campanha · Obs.: Data aproximada (campanha de 2018).'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'Brasil acima de tudo, Deus acima de todos');
-- ulysses-guimaraes
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Temos ódio à ditadura. Ódio e nojo.', 'pt', '1988-10-05', 'No discurso de promulgação da Constituição, erguendo um exemplar do texto. Em 2025, Hugo Motta repetiu a frase e o gesto ao tomar posse na presidência da Câmara.', 'discurso', 'https://www.terra.com.br/noticias/brasil/temos-odio-e-nojo-a-ditadura-os-30-anos-do-discurso-historico-que-promulgou-a-constituicao-do-brasil,34e9e05539338e037d27bd9f18e13b13q321ih7j.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Frase símbolo da redemocratização · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'ulysses-guimaraes'
  and not exists (select 1 from quotes where text = 'Temos ódio à ditadura. Ódio e nojo.');
-- donald-trump
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Você está demitido!', 'pt', null, 'O bordão de Trump ao eliminar participantes do reality "O Aprendiz", que ele comandou de 2004 a 2015. No original, "Youre fired!".', 'video', 'https://exame.com/carreira/de-magnata-a-presidente-dos-eua-a-trajetoria-de-trump-comecou-no-estado-decisivo-de-sua-reeleicao/', null, 1, 'iconica', 'draft', 'Fonte: Exame · Por que: Bordão de reality que virou marca'
from people where slug = 'donald-trump'
  and not exists (select 1 from quotes where text = 'Você está demitido!');
-- michel-temer
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Tem que manter isso, viu?', 'pt', '2017-03-07', 'Gravada por Joesley Batista no Palácio do Jaburu, logo depois de o dono da JBS dizer que estava "de bem" com Eduardo Cunha, que estava preso. O áudio quase derrubou o governo.', 'video', 'https://exame.com/brasil/5-pontos-essenciais-para-entender-a-conversa-de-joesley-e-temer/', null, 1, 'polemica', 'draft', 'Fonte: Exame · Por que: O áudio que quase derrubou Temer'
from people where slug = 'michel-temer'
  and not exists (select 1 from quotes where text = 'Tem que manter isso, viu?');
-- romero-juca
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Tem que mudar o governo pra poder estancar essa sangria', 'pt', '2016-03-01', 'Em conversa gravada por Sérgio Machado, ex-presidente da Transpetro, sobre a Lava Jato, semanas antes do impeachment de Dilma. Ele deixou o Ministério do Planejamento dias depois de o áudio vir à tona.', 'video', 'https://www.terra.com.br/noticias/brasil/a-conversa-entre-juca-e-sergio-machado-sobre-a-lava-jato,bb0e6045aa8413a29e8448f4a4f5c760ytz9pg4k.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Plano para parar a Lava Jato · Obs.: Data aproximada (março de 2016); o áudio saiu na Folha em maio de 2016. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'romero-juca'
  and not exists (select 1 from quotes where text = 'Tem que mudar o governo pra poder estancar essa sangria');
-- abraham-weintraub
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Por mim colocava esses vagabundos na cadeia, começando pelo STF', 'pt', '2020-04-22', 'Na reunião ministerial cujo vídeo o STF tornou público. Celso de Mello viu possível crime contra a honra dos ministros, e Weintraub ficou em silêncio no depoimento à PF.', 'video', 'https://www.poder360.com.br/governo/weintraub-por-mim-colocava-esses-vagabundos-na-cadeia-comecando-pelo-stf/', null, 1, 'polemica', 'draft', 'Fonte: Poder360 · Por que: Ministro querendo prender o STF · Obs.: Texto é a manchete do Poder360; o vídeo traz a fala mais longa. Confira. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'abraham-weintraub'
  and not exists (select 1 from quotes where text = 'Por mim colocava esses vagabundos na cadeia, começando pelo STF');
-- ricardo-salles
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Ir passando a boiada e mudando todo o regramento e simplificando normas', 'pt', '2020-04-22', 'Na mesma reunião ministerial, sugerindo aproveitar que a imprensa só falava de covid para afrouxar as regras ambientais. Respondeu a ação por improbidade.', 'video', 'https://exame.com/brasil/salles-sugeriu-aproveitar-pandemia-para-passar-a-boiada-no-meio-ambiente/', null, 1, 'polemica', 'draft', 'Fonte: Exame · Por que: Aproveitar a pandemia para "passar a boiada" · Obs.: Trecho da fala; a frase completa começa com "porque só fala de covid e...". Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'ricardo-salles'
  and not exists (select 1 from quotes where text = 'Ir passando a boiada e mudando todo o regramento e simplificando normas');
-- jair-bolsonaro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Pelo meu histórico de atleta, caso fosse contaminado pelo vírus, não precisaria me preocupar, nada sentiria ou seria acometido, quando muito, de uma gripezinha ou resfriadinho', 'pt', '2020-03-24', 'Em pronunciamento em rede nacional no começo da pandemia, criticando as quarentenas. Meses depois, ele negou ter chamado a covid de "gripezinha".', 'discurso', 'https://www.correiobraziliense.com.br/politica/2020/12/4896881-em-live-bolsonaro-nega-novamente-que-tenha-dito-que-a-covid-e-gripezinha.html', null, 1, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: A "gripezinha" na TV · Obs.: Texto pelo trecho da busca (Terra e Correio).'
from people where slug = 'jair-bolsonaro'
  and not exists (select 1 from quotes where text = 'Pelo meu histórico de atleta, caso fosse contaminado pelo vírus, não precisaria me preocupar, nada sentiria ou seria acometido, quando muito, de uma gripezinha ou resfriadinho');
-- pablo-marcal
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Você não é homem nem para fazer isso. Você não é homem', 'pt', '2024-09-15', 'Para José Luiz Datena, no debate da TV Cultura para a Prefeitura de São Paulo, lembrando que o apresentador ameaçou agredi-lo em outro debate. Segundos depois, Datena acertou Marçal com uma cadeira.', 'video', 'https://www.correiobraziliense.com.br/politica/2024/09/6942905-voce-nao-e-homem-disse-marcal-antes-de-levar-cadeirada-de-datena-em-debate.html', null, 1, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: A provocação antes da cadeirada · Obs.: Texto pela transcrição do Terra citada na busca. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'pablo-marcal'
  and not exists (select 1 from quotes where text = 'Você não é homem nem para fazer isso. Você não é homem');

commit;
