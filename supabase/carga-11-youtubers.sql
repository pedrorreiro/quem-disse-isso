-- Carga 11: YouTubers, para chegar a pelo menos 20 frases por tipo (icônicas e polêmicas).
-- Fontes: Terra, Metrópoles, Correio Braziliense, CNN Brasil e Poder360.
-- O agente não conseguiu abrir as matérias (o ambiente bloqueia os sites); os textos vêm dos trechos que a busca
-- devolveu. Por isso o review_note pede para conferir a frase na matéria antes de aprovar.
-- Tudo entra como RASCUNHO: nada fica jogável até você aprovar em /admin → Fila de revisão. Pessoas novas entram sem foto
-- (aprove em /admin → Fotos). Pode rodar mais de uma vez: não duplica pessoas nem frases.

begin;

-- Pessoas novas
insert into people (name, slug, category, area, gender, country, bio_short) values
  ('Luva de Pedreiro', 'luva-de-pedreiro', 'youtubers', 'internet', 'm', 'BR', 'Iran Ferreira, influenciador baiano que viralizou com vídeos de gols no campinho'),
  ('Jout Jout', 'jout-jout', 'youtubers', 'internet', 'f', 'BR', 'Julia Tolezano, youtuber do canal Jout Jout Prazer'),
  ('Christian Figueiredo', 'christian-figueiredo', 'youtubers', 'internet', 'm', 'BR', 'Youtuber do canal Eu Fico Loko'),
  ('Felca', 'felca', 'youtubers', 'internet', 'm', 'BR', 'Youtuber de humor que denunciou a adultização de crianças na internet'),
  ('Luccas Neto', 'luccas-neto', 'youtubers', 'internet', 'm', 'BR', 'Youtuber de conteúdo infantil, irmão de Felipe Neto')
on conflict (slug) do nothing;

-- casimiro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Estamos falando da elite', 'pt', null, 'Um dos bordões do streamer nas lives da CazéTV, ao lado de "meteu essa?" e "que papinho".', 'video', 'https://www.terra.com.br/esportes/mais-um-recorde-batido-10-fatos-que-explicam-o-sucesso-do-fenomeno-casimiro,4e9308f04503e041a55c15ea34d84df3ifuxwfkk.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão de live'
from people where slug = 'casimiro'
  and not exists (select 1 from quotes where text = 'Estamos falando da elite');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Aceitas pix?', 'pt', null, 'Bordão das lives de Casimiro que virou meme nas redes.', 'video', 'https://www.metropoles.com/colunas/leo-dias/meteu-essa-conheca-casimiro-streamer-que-bateu-recorde-com-neymar', null, 2, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão de live · Obs.: A busca citou o bordão numa lista (Metrópoles/Terra); confira em qual matéria ele aparece.'
from people where slug = 'casimiro'
  and not exists (select 1 from quotes where text = 'Aceitas pix?');
-- whindersson-nunes
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Passar por uma palhaçada dessa por 500 mil, nunca mais', 'pt', '2024-11-01', 'Depois de perder a estreia no boxe profissional para o indiano Neeraj Goyat, luta em que virou meme ao acertar o próprio rosto.', 'post', 'https://www.metropoles.com/celebridades/video-whindersson-vira-meme-apos-dar-soco-no-proprio-rosto-em-luta', null, 2, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Autodeboche que viralizou · Obs.: Data aproximada (novembro de 2024).'
from people where slug = 'whindersson-nunes'
  and not exists (select 1 from quotes where text = 'Passar por uma palhaçada dessa por 500 mil, nunca mais');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Ganhei uns 40 milhões. E gastei tudo com droga', 'pt', '2026-05-12', 'Em entrevista a Maya Massafera, falando de um ano de faturamento. A fala viralizou, e ele gravou um vídeo dizendo que tinha exagerado.', 'entrevista', 'https://www.terra.com.br/diversao/gente/ganhei-uns-40-milhoes-e-gastei-tudo-com-droga-aos-31-anos-whindersson-nunes-faz-revelacao-surpreendente-sobre-faturamento-anual-e-dependencia-quimica,7b7a6fca40680307f84f95d73ec0afd12vf1ywsi.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Confissão milionária que teve de ser desmentida · Obs.: Data aproximada (meados de maio de 2026). Retratação na CNN Brasil.'
from people where slug = 'whindersson-nunes'
  and not exists (select 1 from quotes where text = 'Ganhei uns 40 milhões. E gastei tudo com droga');
-- luva-de-pedreiro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Receba!', 'pt', null, 'O grito depois de cada gol nos vídeos do campinho. Segundo ele, é um desabafo contra quem o criticava.', 'video', 'https://www.metropoles.com/celebridades/luva-de-pedreiro-desiste-de-ser-jogador-e-abre-o-jogo-sobre-mansao', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão que conquistou o país · Obs.: Confira em qual matéria do Metrópoles está a explicação do bordão. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'luva-de-pedreiro'
  and not exists (select 1 from quotes where text = 'Receba!');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Obrigado, meu Deus!', 'pt', null, 'O agradecimento que fecha os vídeos dos gols no campinho, junto com o "Receba!".', 'video', 'https://www.terra.com.br/esportes/luva-de-pedreiro-ganha-destaque-em-jornal-na-europa,08070da81799c99fbbcd86800350d1c3zzcexwta.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão dos vídeos'
from people where slug = 'luva-de-pedreiro'
  and not exists (select 1 from quotes where text = 'Obrigado, meu Deus!');
-- jout-jout
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Não tira o batom vermelho', 'pt', '2015-02-01', 'Título e mote do vídeo em que a youtuber listou sinais de relacionamento abusivo. Virou hashtag e ficou entre os assuntos mais comentados do Twitter.', 'video', 'https://www.correiobraziliense.com.br/app/noticia/brasil/2015/05/29/interna-brasil,485009/conheca-jout-jout-a-carioca-que-fala-de-namoros-menstruacao-e-pes.shtml', null, 2, 'iconica', 'draft', 'Fonte: Correio Braziliense · Por que: Vídeo que virou bordão · Obs.: Data aproximada (fevereiro de 2015). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'jout-jout'
  and not exists (select 1 from quotes where text = 'Não tira o batom vermelho');
-- christian-figueiredo
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu fico loko', 'pt', null, 'Bordão do youtuber que virou nome do canal, de livro, de filme e de peça.', 'video', 'https://www.metropoles.com/entretenimento/teatro/youtuber-christian-figueiredo-traz-show-eu-fico-loko-a-brasilia', null, 1, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Bordão que virou marca · Obs.: Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'christian-figueiredo'
  and not exists (select 1 from quotes where text = 'Eu fico loko');
-- toguro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Em pleno 2022', 'pt', null, 'Bordão com que Toguro repreendia quem agia mal nos vídeos. Virou meme: "em pleno 2022, ano da Copa, das eleições, do iPhone 14".', 'video', 'https://www.terra.com.br/diversao/sabor-energetico-entenda-o-meme-que-parou-a-internet,f7a9881a63dff573d08e4d635cc0fe4fnkx5uanc.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Bordão que virou meme'
from people where slug = 'toguro'
  and not exists (select 1 from quotes where text = 'Em pleno 2022');
-- thiago-nigro
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Um homem bebendo sua coquinha não quer guerra com ninguém', 'pt', '2026-07-01', 'Legenda de vídeo no TikTok, com uma lata de Coca-Cola, logo depois de Maíra Cardi contar que jogou fora o refrigerante dele.', 'post', 'https://www.terra.com.br/diversao/gente/apos-maira-cardi-proibir-refrigerante-em-casa-thiago-nigro-aparece-bebendo-coquinha-e-diz-nao-querer-guerra,f0e785d356fb273c52062caf30a517bfidv8cu54.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: Ironia que viralizou · Obs.: Data aproximada (julho de 2026).'
from people where slug = 'thiago-nigro'
  and not exists (select 1 from quotes where text = 'Um homem bebendo sua coquinha não quer guerra com ninguém');
-- felca
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Geladinho, gostosinho', 'pt', '2023-01-01', 'No vídeo em que testou a base da WePink, de Virginia Fonseca, que não saía do rosto dele. O vídeo passou de 19 milhões de visualizações.', 'video', 'https://www.terra.com.br/diversao/gente/quem-e-felca-conheca-o-youtuber-que-denunciou-a-adultizacao-na-internet,893154ce15e208e67c81675fc9674b626yw5vp5u.html', null, 2, 'iconica', 'draft', 'Fonte: Terra · Por que: O meme da base da Virginia · Obs.: Data aproximada (2023). Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'felca'
  and not exists (select 1 from quotes where text = 'Geladinho, gostosinho');
-- luccas-neto
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Podem gritar daí que eu grito daqui!', 'pt', null, 'No anúncio, no Dia dos Pais, de que ele e Jessi esperavam o primeiro filho.', 'post', 'https://www.metropoles.com/colunas/claudia-meireles/hoje-e-o-meu-dia-luccas-neto-anuncia-estar-a-espera-do-primeiro-filho', null, 3, 'iconica', 'draft', 'Fonte: Metrópoles · Por que: Anúncio que viralizou · Obs.: Confira a data do post. Pessoa nova: aprove a foto em /admin → Fotos.'
from people where slug = 'luccas-neto'
  and not exists (select 1 from quotes where text = 'Podem gritar daí que eu grito daqui!');
-- felipe-neto
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Eu era a criança viada mais viada q já existiu', 'pt', '2021-09-16', 'Tuíte com uma foto de infância. Foi criticado por usar o termo sendo heterossexual e nunca ter sofrido homofobia.', 'post', 'https://www.terra.com.br/diversao/gente/felipe-neto-e-criticado-apos-dizer-que-foi-crianca-viada,f26dfd1fa7bf810261972da758d48df2rd0qapwv.html', null, 2, 'polemica', 'draft', 'Fonte: Terra · Por que: Termo da comunidade LGBT usado por um hétero'
from people where slug = 'felipe-neto'
  and not exists (select 1 from quotes where text = 'Eu era a criança viada mais viada q já existiu');
-- monark
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'A gente vê o TSE censurando gente, a gente vê o Alexandre de Moraes prendendo pessoas', 'pt', '2023-06-01', 'Em vídeo no Rumble em que levantou suspeitas sobre as urnas. O TSE levou o caso ao STF, e Moraes mandou bloquear todas as redes dele.', 'video', 'https://www.poder360.com.br/justica/moraes-determina-bloqueio-das-redes-sociais-de-monark/', null, 2, 'polemica', 'draft', 'Fonte: Poder360 · Por que: Teve as redes bloqueadas pelo STF · Obs.: Texto pelo trecho da busca. Data aproximada (o bloqueio foi em 13/06/2023).'
from people where slug = 'monark'
  and not exists (select 1 from quotes where text = 'A gente vê o TSE censurando gente, a gente vê o Alexandre de Moraes prendendo pessoas');
insert into quotes (person_id, text, language, said_on, context, source_type, source_url, source_timestamp, difficulty, kind, status, review_note)
select id, 'Um golpe do judiciário aliado as oligarquias', 'pt', '2024-01-08', 'No X, sobre os atos de 8 de janeiro, rebatendo quem chama a invasão da Praça dos Três Poderes de tentativa de golpe.', 'post', 'https://www.poder360.com.br/justica/moraes-multa-monark-em-r-300-mil-e-manda-abrir-inquerito/', null, 3, 'polemica', 'draft', 'Fonte: Poder360 · Por que: Chamou o 8 de janeiro de golpe do Judiciário · Obs.: Texto pelo trecho da busca; confira em qual matéria do Poder360 ele aparece. Data aproximada (aniversário do 8/1).'
from people where slug = 'monark'
  and not exists (select 1 from quotes where text = 'Um golpe do judiciário aliado as oligarquias');

commit;
