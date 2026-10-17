-- Carga 10: Música, para chegar a pelo menos 20 frases por tipo (icônicas e polêmicas).
-- Fontes: CNN Brasil, Metrópoles, Terra, Correio Braziliense e Poder360.
-- O agente não conseguiu abrir as matérias (o ambiente bloqueia os sites); os textos vêm dos trechos que a busca
-- devolveu. Por isso o review_note pede para conferir a frase na matéria antes de aprovar.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove em /admin → Fotos). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Sérgio Reis', 'sergio-reis', 'musica', 'musica', 'm', 'BR', 'Cantor sertanejo, de "O Menino da Porteira", e ex-deputado federal'),
  ('Zé Neto', 'ze-neto', 'musica', 'musica', 'm', 'BR', 'Cantor sertanejo, da dupla Zé Neto & Cristiano'),
  ('Zezé Di Camargo', 'zeze-di-camargo', 'musica', 'musica', 'm', 'BR', 'Cantor sertanejo, da dupla Zezé Di Camargo & Luciano'),
  ('Luísa Sonza', 'luisa-sonza', 'musica', 'musica', 'f', 'BR', 'Cantora pop gaúcha'),
  ('Joelma', 'joelma', 'musica', 'musica', 'f', 'BR', 'Cantora paraense, ex-vocalista da banda Calypso'),
  ('Ed Motta', 'ed-motta', 'musica', 'musica', 'm', 'BR', 'Cantor e compositor de soul e jazz, sobrinho de Tim Maia'),
  ('Milton Nascimento', 'milton-nascimento', 'musica', 'musica', 'm', 'BR', 'Cantor e compositor mineiro, do Clube da Esquina'),
  ('Mano Brown', 'mano-brown', 'musica', 'musica', 'm', 'BR', 'Rapper, líder dos Racionais MC''s'),
  ('Claudia Leitte', 'claudia-leitte', 'musica', 'musica', 'f', 'BR', 'Cantora de axé, ex-vocalista do Babado Novo'),
  ('Thomas Machado', 'thomas-restart', 'musica', 'musica', 'm', 'BR', 'Baterista da banda Restart'),
  ('Leonardo', 'leonardo', 'musica', 'musica', 'm', 'BR', 'Cantor sertanejo, ex-dupla com Leandro'),
  ('Valesca Popozuda', 'valesca-popozuda', 'musica', 'musica', 'f', 'BR', 'Funkeira carioca, ex-Gaiola das Popozudas'),
  ('Baby do Brasil', 'baby-do-brasil', 'musica', 'musica', 'f', 'BR', 'Cantora, ex-Novos Baianos, hoje pastora'),
  ('Laércia Dantas', 'laercia-dantas', 'musica', 'musica', 'f', 'BR', 'Cantora de forró e brega pernambucana')
on conflict (slug) do nothing;

-- sergio-reis
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Se em 30 dias eles não tirarem aqueles caras, nós vamos invadir, quebrar tudo e tirar os caras na marra', 'pt', '2021-08-14', 'Em áudio que vazou, convocando caminhoneiros contra os ministros do STF. Foi alvo de operação da PF, perdeu shows, e Zé Ramalho cancelou um dueto com ele.', 'video', 'https://www.cnnbrasil.com.br/politica/como-sergio-reis-foi-de-astro-sertanejo-a-investigado-pela-pf/', null, 2, 'polemica', 'draft', 'Fonte: CNN Brasil · Por que: O Menino da Porteira ameaçando invadir o STF · Obs.: Texto pelo trecho da busca ("[os ministros do STF]" é inserção da matéria e foi tirado). Data aproximada (áudio de meados de agosto de 2021); confira. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'sergio-reis'
  and not exists (select 1 from quotes where text = 'Se em 30 dias eles não tirarem aqueles caras, nós vamos invadir, quebrar tudo e tirar os caras na marra');
-- ze-neto
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'A gente não precisa fazer tatuagem no toba pra mostrar se a gente tá bem ou mal', 'pt', '2022-05-12', 'Num show em Sorriso (MT), dizendo que a dupla não depende da Lei Rouanet. Foi lido como indireta para Anitta e abriu a CPI dos cachês: o próprio show tinha sido pago com R$ 400 mil da prefeitura.', 'video', 'https://www.correiobraziliense.com.br/diversao-e-arte/2022/05/5007766-sertanejo-manda-indireta-para-anitta-em-show-e-video-viraliza.html', null, 1, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: A indireta que expôs os cachês pagos por prefeituras · Obs.: A busca só trouxe a fala parafraseada ("não precisa fazer tatuagem no toba"): CONFIRA o texto exato na matéria. Cachê público segundo o Metrópoles. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'ze-neto'
  and not exists (select 1 from quotes where text = 'A gente não precisa fazer tatuagem no toba pra mostrar se a gente tá bem ou mal');
-- zeze-di-camargo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Se puderem, não precisa passar meu especial, não quero participar disso', 'pt', '2025-12-14', 'Em vídeo criticando o SBT por receber Lula e Alexandre de Moraes, no qual também disse que as filhas de Silvio Santos estavam "se prostituindo". O SBT cancelou o especial de Natal dele, e Lula chamou a fala de "cretinice".', 'post', 'https://www.poder360.com.br/poder-midia/zeze-critica-sbt-sugere-aproximacao-com-lula-e-pede-fim-de-show/', null, 2, 'polemica', 'draft', 'Fonte: Poder360 · Por que: Ataque às herdeiras de Silvio Santos · Obs.: Texto pelo trecho da busca. A frase mais famosa ("se prostituir") aparece com grafias diferentes nas matérias; se achar a versão exata, prefira ela. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'zeze-di-camargo'
  and not exists (select 1 from quotes where text = 'Se puderem, não precisa passar meu especial, não quero participar disso');
-- luisa-sonza
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Pega um copo d''água pra mim? Você não trabalha aqui?', 'pt', '2018-09-01', 'Segundo a advogada Isabel Macedo, que é negra, foi o que a cantora disse a ela em Fernando de Noronha, confundindo-a com uma funcionária da pousada. A advogada processou por injúria racial, houve acordo, e a cantora admitiu: "Realmente, eu cometi um ato racista".', 'materia', 'https://www.metropoles.com/brasil/luisa-sonza-e-acusada-de-racismo-por-advogada-negra', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Caso de racismo que virou processo · Obs.: Texto pelo relato da advogada (trecho da busca). Data aproximada (setembro de 2018). Admissão no Terra. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'luisa-sonza'
  and not exists (select 1 from quotes where text = 'Pega um copo d''água pra mim? Você não trabalha aqui?');
-- joelma
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'É como um drogado tentando se recuperar', 'pt', '2013-03-30', 'Em entrevista à revista Época, comparando gays a dependentes químicos. Também disse que, se tivesse um filho gay, lutaria até a morte para convertê-lo. Depois negou a comparação.', 'entrevista', 'https://www.correiobraziliense.com.br/app/noticia/brasil/2013/03/31/interna-brasil,357664/joelma-do-calypso-compara-gays-a-drogados-e-causa-polemica-na-internet.shtml', null, 2, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: Comparou gays a drogados · Obs.: Texto pelo trecho da busca; confira. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'joelma'
  and not exists (select 1 from quotes where text = 'É como um drogado tentando se recuperar');
-- ed-motta
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Qualquer um que ouve hip hop é burro', 'pt', null, 'Declaração do cantor, que coleciona brigas com o público. A fala revoltou fãs de rap.', 'video', 'https://www.terra.com.br/noticias/qualquer-um-que-ouve-hip-hop-e-burro-dispara-ed-motta,fbeaa484dc7e77e8640e4a522c5c30b4muigejav.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Chamou fãs de hip hop de burros · Obs.: Data aproximada (2024, segundo a CNN Brasil); confira onde foi dito. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'ed-motta'
  and not exists (select 1 from quotes where text = 'Qualquer um que ouve hip hop é burro');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Era um funcionariozinho de gravadora gravando uns discos de merda', 'pt', '2022-02-01', 'Em live no YouTube, sobre Raul Seixas. A filha de Raul rebateu, e duas semanas depois ele pediu perdão "pela forma agressiva e grosseira".', 'video', 'https://www.correiobraziliense.com.br/diversao-e-arte/2022/02/4987348-raul-seixas-era-sem-carater-diz-ed-motta-em-live-nas-redes-sociais.html', null, 2, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: Atacou Raul Seixas · Obs.: Texto pelo trecho da busca. Data aproximada (fevereiro de 2022).'
from people where slug = 'ed-motta'
  and not exists (select 1 from quotes where text = 'Era um funcionariozinho de gravadora gravando uns discos de merda');
-- milton-nascimento
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Música brasileira está uma porcaria', 'pt', '2019-09-01', 'À coluna de Mônica Bergamo, na Folha, reclamando que as letras só falam de bebida e traição. Foi atacado nas redes e explicou que falava só do mainstream.', 'entrevista', 'https://www.metropoles.com/colunas/pipocando/musica-brasileira-esta-uma-porcaria-dispara-milton-nascimento', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Ícone da MPB detonando a música atual · Obs.: Na Folha a frase saiu como "está uma merda"; o Metrópoles publicou "porcaria". Data aproximada (2019). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'milton-nascimento'
  and not exists (select 1 from quotes where text = 'Música brasileira está uma porcaria');
-- mano-brown
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Se não está conseguindo falar a língua do povo, vai perder mesmo', 'pt', '2018-10-23', 'No palco de um comício de Fernando Haddad, no Rio, criticando o próprio PT a cinco dias do segundo turno. Foi vaiado, e Bolsonaro usou a fala contra Haddad.', 'discurso', 'https://www.correiobraziliense.com.br/app/noticia/politica/2018/10/24/interna_politica,714669/video-mano-brown-critica-pt-em-ato-pro-haddad-com-artistas-no-rio.shtml', null, 2, 'polemica', 'draft', 'Fonte: Correio Braziliense · Por que: Detonou o PT no comício do PT · Obs.: Texto pelo trecho da busca ("A comunicação é a alma. Se não está conseguindo..."). Repercussão na Exame. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'mano-brown'
  and not exists (select 1 from quotes where text = 'Se não está conseguindo falar a língua do povo, vai perder mesmo');
-- gusttavo-lima
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Vão ter que prender o país inteiro', 'pt', '2024-09-01', 'Sobre os contratos de artistas e clubes com casas de apostas, quando era investigado na Operação Integration. A investigação contra ele foi arquivada depois.', 'video', 'https://www.terra.com.br/diversao/musica/gusttavo-lima-sobre-empresas-de-apostas-vao-ter-que-prender-o-pais-inteiro,633f6790c663ce3e5c69e03fe4c7f4360vv6zgnk.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Defesa das bets em plena investigação · Obs.: Data aproximada (setembro de 2024).'
from people where slug = 'gusttavo-lima'
  and not exists (select 1 from quotes where text = 'Vão ter que prender o país inteiro');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu nem sei como lava dinheiro', 'pt', '2024-09-01', 'Em live, respondendo à investigação sobre lavagem de dinheiro ligada à Vai de Bet, da qual era garoto-propaganda.', 'video', 'https://www.metropoles.com/colunas/fabia-oliveira/gusttavo-lima-sobre-investigacao-eu-nem-sei-como-lava-dinheiro', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Investigado por lavagem diz não saber lavar · Obs.: Data aproximada (setembro de 2024). CNN Brasil traz "Nem sei como é que lava dinheiro".'
from people where slug = 'gusttavo-lima'
  and not exists (select 1 from quotes where text = 'Eu nem sei como lava dinheiro');
-- claudia-leitte
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu adoro os gays, mas prefiro que meu filho seja macho', 'pt', null, 'Em entrevista ao TV Fama, grávida do primeiro filho. O marido completou: "Deus me livre. Ele será bem-criado". Houve protestos e ameaça de boicote.', 'entrevista', 'https://www.metropoles.com/entretenimento/musica/filho-macho-e-abajur-de-arma-entenda-as-polemicas-de-claudia-leitte', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Fala homofóbica que a persegue até hoje · Obs.: Data incerta: as matérias falam em 2008 ou 2011. Confira. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'claudia-leitte'
  and not exists (select 1 from quotes where text = 'Eu adoro os gays, mas prefiro que meu filho seja macho');
-- thomas-restart
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Não sei como é o público de lá, não sei nem se tem gente, civilização.', 'pt', '2011-03-01', 'No Vídeo Show, sobre Manaus. Houve protestos e ameaças, e o show do Restart na cidade foi cancelado.', 'entrevista', 'https://www.cnnbrasil.com.br/blogs/mari-palma/entretenimento/restart-descobre-ligacao-antiga-com-mari-palma/', null, 2, 'polemica', 'draft', 'Fonte: CNN Brasil · Por que: Ofendeu Manaus e perdeu o show · Obs.: Data aproximada (início de 2011). Cancelamento no Terra. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'thomas-restart'
  and not exists (select 1 from quotes where text = 'Não sei como é o público de lá, não sei nem se tem gente, civilização.');
-- leonardo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Tem muita coisa ali que é voltada para o Satanás', 'pt', '2024-05-06', 'Sobre o show gratuito de Madonna em Copacabana, que também chamou de "suruba". Fãs da cantora rebateram.', 'video', 'https://www.metropoles.com/celebridades/leonardo-detona-show-de-madonna-no-rio-voltado-para-o-satanas', null, 2, 'polemica', 'draft', 'Fonte: Metrópoles · Por que: Chamou show da Madonna de satanismo · Obs.: Data aproximada (dias depois do show de 04/05/2024). "Suruba" na CNN Brasil. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'leonardo'
  and not exists (select 1 from quotes where text = 'Tem muita coisa ali que é voltada para o Satanás');
-- valesca-popozuda
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Beijinho no ombro pro recalque passar longe', 'pt', null, 'Refrão de "Beijinho no ombro", que virou resposta oficial a quem tem inveja. Uma professora do DF chegou a chamá-la de "grande pensadora contemporânea" numa prova.', 'musica', 'https://www.correiobraziliense.com.br/app/noticia/diversao-e-arte/2017/07/10/interna_diversao_arte,608423/nova-versao-de-beijinho-no-ombro.shtml', null, 1, 'iconica', 'draft', 'Fonte: Correio Braziliense · Por que: Refrão que virou bordão nacional · Obs.: Data aproximada (lançamento no fim de 2013). Confira a letra. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'valesca-popozuda'
  and not exists (select 1 from quotes where text = 'Beijinho no ombro pro recalque passar longe');
-- baby-do-brasil
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Nós entramos em apocalipse', 'pt', '2024-02-10', 'Pregando em cima do trio de Ivete Sangalo no Carnaval de Salvador, dizendo que o arrebatamento viria em cinco a dez anos. Ivete respondeu que ia "macetar o apocalipse".', 'video', 'https://www.terra.com.br/noticias/baby-do-brasil-quem-e-a-cantora-que-anunciou-o-apocalipse-saiba-mais,0a37d55f86219feccf12ddb9965c7a97aww24218.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: O meme do Carnaval de 2024 · Obs.: Data aproximada (Carnaval de 2024). As matérias trazem versões um pouco diferentes da fala. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'baby-do-brasil'
  and not exists (select 1 from quotes where text = 'Nós entramos em apocalipse');
-- luisa-sonza
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Claro, gente, eu fui corna de propósito, faz todo o sentido. Parabéns', 'pt', '2023-09-01', 'Comentário numa página de fofoca, rebatendo quem dizia que o fim do namoro, anunciado ao vivo no Mais Você, era marketing para o disco "Escândalo Íntimo".', 'post', 'https://www.cnnbrasil.com.br/entretenimento/claro-fui-corna-de-proposito-luisa-sonza-ironiza-criticas-sobre-anuncio-de-separacao/', null, 1, 'iconica', 'draft', 'Fonte: CNN Brasil · Por que: Ironia que viralizou · Obs.: Data aproximada (setembro de 2023).'
from people where slug = 'luisa-sonza'
  and not exists (select 1 from quotes where text = 'Claro, gente, eu fui corna de propósito, faz todo o sentido. Parabéns');
-- tim-maia
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Mais retorno!', 'pt', null, 'O pedido de Tim Maia ao técnico de som, antes e durante os shows. Virou a expressão mais ligada a ele.', 'video', 'https://www.terra.com.br/diversao/musica/tim-maia-o-artista-que-engrandeceu-o-soul-e-o-funk-no-brasil,1f3616d7136487dbcfcc1b89f2d0d2a9es5ta1yb.html', null, 1, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão de palco · Obs.: Confira se esta matéria é a que traz o "mais retorno" (a busca juntou duas matérias do Terra sobre ele).'
from people where slug = 'tim-maia'
  and not exists (select 1 from quotes where text = 'Mais retorno!');
-- laercia-dantas
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Garçom! Tem Pitu? Traz!', 'pt', null, 'Trecho de um vídeo da cantora num show, que virou meme e foi repetido por Pabllo Vittar, Rodrigo Faro e Adriane Galisteu.', 'video', 'https://www.metropoles.com/viralizou/garcom-tem-pitu-cantora-explica-como-surgiu-o-bordao-que-virou-meme', null, 2, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão que virou meme · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'laercia-dantas'
  and not exists (select 1 from quotes where text = 'Garçom! Tem Pitu? Traz!');

commit;
