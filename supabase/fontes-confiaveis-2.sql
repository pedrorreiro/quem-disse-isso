-- Fontes em veículos grandes, parte 2: as 10 frases em jogo que ainda vinham de sites
-- regionais ou pequenos (O Povo, Uai, JB, DN, CM Jornal, Aos Fatos, site do Palmeiras, Estado de Minas).
-- Quando o veículo grande registra a fala com outras palavras, o texto da frase acompanha a nova fonte.
-- O snapshot arquivado era da fonte antiga, então é limpo. Pode rodar mais de uma vez.

begin;

update quotes q set source_url = v.url, source_type = 'materia', archive_url = null
from (values
  ('6a45028f-b927-4b05-acc3-ec946fdb195d'::uuid, 'https://www.goal.com/br/not%C3%ADcias/romario-melhores-frases-polemicas-flamengo-vasco-senador/mkg4mxepwb4c1ce0bmt8yut16'), -- Romário: Pelé calado
  ('66bdc550-765e-4f0e-9189-82b1517b6d4f', 'https://exame.com/brasil/tenho-conviccao-do-quanto-a-mulher-faz-pelo-lar-diz-temer'), -- Temer: supermercado
  ('40c27b2a-1052-4a83-8217-8607ef902efa', 'https://www.metropoles.com/celebridades/indireta-para-sonza-anitta-diz-que-nao-faria-musica-para-namorado'), -- Anitta: minha moral
  ('a823cf20-1a73-47e1-864b-5f7dbbf43031', 'https://www.cartacapital.com.br/politica/bolsonaro-sobre-vacina-se-voce-tomar-e-virar-um-jacare-e-problema-seu/'), -- Bolsonaro: jacaré
  ('2da71aa6-17da-4e12-8b20-4f1234ea25ed', 'https://www.gazetaesportiva.com/times/palmeiras/melo-revela-chapeu-no-sao-paulo-e-promete-dar-tapa-na-cara-de-uruguaio/'), -- Felipe Melo: tapa
  ('a426798a-4b4f-4f51-a9aa-fc862dabee60', 'https://poder360.com.br/poder-eleicoes/eleicoes/comprova-meme-mistura-e-distorce-frases-ditas-por-ciro-gomes') -- Ciro: dormir comigo
) as v(id, url)
where q.id = v.id;

-- Texto igual ao que a nova fonte publica.
update quotes set text = 'Ninguém merece essa minha moral, nesse nível.'
 where id = '40c27b2a-1052-4a83-8217-8607ef902efa';
update quotes set text = 'Se tiver que dar porrada eu vou dar. Se tiver que ir no Uruguai dar tapa na cara de uruguaio, eu vou dar.'
 where id = '2da71aa6-17da-4e12-8b20-4f1234ea25ed';
update quotes set text = 'Se você virar um jacaré, é problema seu.'
 where id = 'a823cf20-1a73-47e1-864b-5f7dbbf43031';

-- Sem cobertura em veículo grande: saem do jogo.
update quotes
   set status = 'rejected',
       review_note = concat_ws(' · ', nullif(review_note, ''), 'Fora do jogo: sem fonte em veículo grande (fonte antiga: ' || source_url || ')')
 where status = 'verified'
   and id in (
     '6f9e4555-74bc-455d-94f4-d43f122f3d85', -- Felipe Neto: cadeia nesse corrupto
     '82af88e3-4caa-47a2-918b-4a1267a3be87', -- Kéfera: passei vergonha
     '92af6179-60bd-477c-967f-a0ab31339850', -- Ivete Sangalo: nunca transei com a Xuxa
     'af620f32-63d4-46c1-9894-047db1576eee'  -- Silvio Santos: direito de ser feia
   );

commit;
