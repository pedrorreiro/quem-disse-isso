-- Fontes em veículos grandes: troca a fonte das frases em jogo que vinham de sites pequenos
-- (as mesmas falas, noticiadas por CNN, Terra, Metrópoles, Correio Braziliense, ISTOÉ, Lance, ESPN…).
-- O snapshot arquivado era da fonte antiga, então é limpo. Pode rodar mais de uma vez.
-- As frases sem cobertura em veículo grande saem do jogo (ficam como rejeitadas; dá para voltar pelo painel).

begin;

update quotes q set source_url = v.url, source_type = 'materia', archive_url = null
from (values
  ('2f7bad1a-c633-4ed4-be79-6de646427f9b'::uuid, 'https://www.terra.com.br/diversao/gente/carlinhos-maia-e-chamado-de-homofobico-apos-negar-que-seu-casamento-com-outro-homem-seja-gay,bf2144e89628d425c676c142efa3fcbblgn81zxg.html'),
  ('25fe244a-5a4f-4ba5-9aa1-5143048af3ec', 'https://www.correiobraziliense.com.br/diversao-e-arte/2024/05/6862602-carlinhos-maia-revela-sexo-com-o-marido-nos-bastidores-de-emissora-evangelica.html'),
  ('5771750e-4877-44a1-8545-e55603bfc1cc', 'https://www.correiobraziliense.com.br/politica/2022/10/5041708-casimiro-declara-voto-em-lula-se-bolsonaro-ta-de-um-lado-eu-to-do-outro.html'),
  ('ae450f87-b408-45b8-b8f6-da5f07682a37', 'https://www.goal.com/en/news/cristiano-ronaldo-saudi-arabia-south-africa-al-nassr-press-conference/blt66cb5cbe80dd7d00'),
  ('28373e84-3806-4571-a4c9-30d87d63d35e', 'https://www.terra.com.br/esportes/futebol/internacional/portugal/campeonato-portugues/cristiano-ronaldo-de-garoto-mimado-a-craque-mundial,14c90c184efda410VgnCLD200000b1bf46d0RCRD.html'),
  ('beaa16c3-11ed-4192-b3db-c4ceb21a85cf', 'https://www.terra.com.br/esportes/futebol/copa-2014/eliminatorias/desabafos-de-maradona-viram-temas-de-camisas-na-argentina,648998eb320aa310VgnCLD200000bbcceb0aRCRD.html'),
  ('248a3398-5602-4701-9ac8-865d658a330a', 'https://www.correiobraziliense.com.br/app/noticia/politica/2015/06/24/interna_politica,487718/dilma-nos-transformamos-em-homo-sapiens-ou-mulheres-sapiens.shtml'),
  ('1c36d0f3-22f3-42e7-b36a-cd79c0bb0f4d', 'https://istoe.com.br/435263_META+NO+VENTILADOR/'),
  ('768c8c2b-f6f3-4ea0-a191-c21de674ba9f', 'https://istoe.com.br/humor-do-impeachment/'),
  ('54dc2191-ee8e-4cb1-972b-dbd2bb2b5fc4', 'https://www.cnnbrasil.com.br/economia/macroeconomia/dilma-relembra-criticas-por-estocar-vento-e-diz-que-estava-correta/'),
  ('6f99799b-b7af-4c0b-ad78-ccd1194e89d6', 'https://www.cnn.com/2020/04/24/politics/fact-check-trump-disinfectant-sarcastic'),
  ('8e009237-d480-4939-8cec-7dc1e6bc5e5b', 'https://www.terra.com.br/esportes/vasco/edmundo-confessa-traicao-em-meio-as-criticas-a-pedrinho-em-live-sobre-o-vasco-veja-video,9a97843da327b8816342d691900c17487zcy3ifk.html'),
  ('b4c57c61-baa0-4bfc-871b-3b3e452961ef', 'https://www.metropoles.com/esportes/video-edmundo-comete-gafe-assume-que-traiu-esposa-ao-vivo-e-viraliza'),
  ('27edd6d4-f8b9-4472-96c1-df98801d095f', 'https://www.lance.com.br/palmeiras/felipe-melo-recepciona-vina-brinca-achavam-que-nao-gosto-uruguaio.html'),
  ('fb68a48d-b14f-47d0-899d-17cac4328044', 'https://www.correiobraziliense.com.br/diversao-e-arte/2023/06/5099215-gilberto-gil-revela-que-ja-se-relacionou-com-homens-somos-todos-bissexuais.html'),
  ('07e603fe-641d-4f15-9baf-71106262082b', 'https://www.metropoles.com/brasil/gusttavo-lima-musica-popular-brasileira-para-mim-e-o-sertanejo'),
  ('edd8ee69-745e-46bc-8369-2744894e6661', 'https://www.correiobraziliense.com.br/politica/2022/10/5044582-pintou-um-clima-fala-de-bolsonaro-sobre-meninas-venezuelanas-repercute.html'),
  ('7e2b484b-3143-40af-bddb-17e9b345568b', 'https://www.cnnbrasil.com.br/nacional/2020/04/20/nao-sou-coveiro-diz-bolsonaro-ao-ser-questionado-por-mortes-por-covid-19'),
  ('77507bad-5f79-4275-92ce-6758a61fdb1a', 'http://www.espn.com.br/noticia/597606_joel-santana-conta-como-ficou-ainda-mais-famoso-com-seu-ingles'),
  ('bd0fe634-3b41-4845-bdc2-ddf1d01ee232', 'https://www.rollingstone.com/music/music-news/kanye-west-says-400-years-of-slavery-sounds-like-a-choice-628849/'),
  ('f6d39ee7-b143-4f4c-9e35-b598db7fe52f', 'https://www.correiobraziliense.com.br/app/noticia/diversao-e-arte/2019/10/22/interna_diversao_arte,799879/luan-santana-afirma-que-se-incomodava-com-boatos-sobre-sexualidade.shtml'),
  ('6174b6fa-9686-4929-b738-4546983d5c06', 'https://www.poder360.com.br/poder-governo/bancos-publicos-fizeram-crise-de-2008-ser-marolinha-diz-lula/'),
  ('56021152-2f64-4a16-a2ff-07ba0e6581eb', 'https://www.cnnbrasil.com.br/eleicoes/lula-diz-que-falou-de-coragem-feminina-ao-citar-toque-e-critica-nikolas/'),
  ('70ecfbcd-2418-447e-9efa-fe96288170da', 'https://www.cnnbrasil.com.br/politica/lula-quer-bater-em-mulher-va-bater-em-outro-lugar/'),
  ('d777c03a-b81e-474c-8a75-d3b0fb86f9de', 'https://www.correiobraziliense.com.br/app/noticia/politica/2019/03/21/interna_politica,744401/michel-temer-de-vice-decorativo-a-ex-presidente-da-republica-preso.shtml'),
  ('9382f0f8-e3dd-4d37-874c-70e1b9949dc5', 'https://www.terra.com.br/diversao/narcisa-detona-boninho-em-recado-a-filha-ele-nao-te-merece,21b321277b7c24b0381b5a94578771aaa638y75m.html'),
  ('afae9321-a5a2-4447-b23d-57b43a4e8fa5', 'https://www.cnnbrasil.com.br/esportes/futebol/santos/neymar-tem-fala-misogina-ao-reclamar-de-arbitro-na-vila-acordou-de-chico/'),
  ('8cb07d30-f1ea-4a1d-aa40-a88769a29ce8', 'https://www.terra.com.br/esportes/flamengo/de-ipanema-a-gavea-flagra-de-renato-gaucho-na-praia-e-acerto-com-o-flamengo-quebram-a-internet,16179df99e6a39e684588c0245ad9b34m27uputc.html'),
  ('e9b61433-c2e4-41f0-ace5-dc0e8dfcec37', 'https://www.espn.com.br/futebol/vasco/artigo/_/id/12875287/romario-edmundo-maior-culpado-derrota-vasco-mundial-dispara-bobo-da-corte-serve-ate-hoje'),
  ('164ef9a8-4aaa-4fa5-95db-3ae83b3362a8', 'https://www.lance.com.br/todos-esportes/hotel-vasco-vampeta-diz-fla-finge-paga.html'),
  ('5036f189-a1fa-4e50-b74b-80811747b3fe', 'https://www.correiobraziliense.com.br/esportes/2026/04/7407852-pentacampeao-diz-secar-selecao-brasileira-e-afirma-nao-quero-que-ganhe-a-copa.html'),
  ('a0992069-6671-4a0c-963c-066b7e38f1c3', 'https://www.correiobraziliense.com.br/diversao-e-arte/2021/04/4919194-xuxa-e-criticada-por-dizer-a-tais-araujo-que-queria-ser-negra-na-proxima-vida.html'),
  ('1b28382b-9854-4d4b-902f-63fbf20df10d', 'https://www.nbcsports.com/soccer/news/ibrahimovic-a-world-cup-without-me-is-not-worth-watching-as-sweden-succumb-to-ronaldos-heroics'),
  ('84dc9df5-148e-4132-a7fa-7d20c748516e', 'https://edition.cnn.com/2016/05/13/football/football-zlatan-ibrahimovic-psg/index.html'),
  ('c5bc174a-4dc8-4ee4-850c-59991461e6b0', 'https://www.rollingstone.com/music/music-latin/anitta-decade-recap-921708/')
) as v(id, url)
where q.id = v.id;

-- Sem cobertura em veículo grande: saem do jogo.
update quotes
   set status = 'rejected',
       review_note = concat_ws(' · ', nullif(review_note, ''), 'Fora do jogo: sem fonte em veículo grande (fonte antiga: ' || source_url || ')')
 where status = 'verified'
   and id in (
     '4d47b693-72a3-4e17-88f7-49362a17e14c', -- Ana Maria Braga: o mundo dá voltas
     'b25d2c10-2d7e-4150-bd0f-a1f13ee7e549', -- Faustão: vida me atropelar
     '10312a96-aff7-4db4-b66d-bbaea88ab5b1', -- Gretchen: sou uma fênix
     'de9fbc64-46de-4ede-aad8-0c2120909e66', -- Gusttavo Lima: funciono na palavra
     '2ab00c8a-ee79-4b6d-a915-3a2e08707743', -- MrBeast: se você não viaja
     '49bccd7f-1de4-49ea-92cb-3e3fd964b8e9', -- Ney Matogrosso: que gay o caralho
     '5a7bc3f6-cb40-469f-bfc4-1c757059a426', -- Neymar: nenhum momento fiz teatro
     '483db14a-2c0c-438a-8f65-28d55c2419c5', -- Neymar: pedalada no psicólogo
     '4b8a871b-c59e-4b39-9f3e-2b3d8a59e4d6', -- Neymar: falaram demais
     '78d4d58c-c411-48a5-8aff-899cc7a2d9b6', -- Vampeta: já bebo sem ganhar nada
     '42f2f1e4-c6df-4649-b84e-90a2374ea8fc'  -- Zeca Pagodinho: psicóloga pra quê
   );

commit;
