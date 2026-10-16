-- DADOS DE EXEMPLO (is_demo = true): pessoas e frases FICTÍCIAS só para testar o ritmo do jogo.
-- Tudo entra como rascunho/foto pendente: aprove em /admin para jogar.
-- Antes de publicar:  delete from quotes where is_demo;  delete from people where is_demo;

insert into people (name, slug, category, country, image_url, image_type, image_credit, image_license, is_demo) values
  ('Zeca Chuteira', 'zeca-chuteira', 'futebol', 'BR', '/demo/p01.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Dedé Marcador', 'dede-marcador', 'futebol', 'BR', '/demo/p02.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Tonhão da Várzea', 'tonhao-da-varzea', 'futebol', 'BR', '/demo/p03.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Marlene Sertaneja', 'marlene-sertaneja', 'musica', 'BR', '/demo/p04.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('DJ Paçoca', 'dj-pacoca', 'musica', 'BR', '/demo/p05.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Bruninho do Pagode', 'bruninho-do-pagode', 'musica', 'BR', '/demo/p06.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Tia Neide', 'tia-neide', 'tv', 'BR', '/demo/p07.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Seu Lauro', 'seu-lauro', 'tv', 'BR', '/demo/p08.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Rita Novelinha', 'rita-novelinha', 'tv', 'BR', '/demo/p09.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Cazé Influ', 'caze-influ', 'internet', 'BR', '/demo/p10.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Mari Dicas', 'mari-dicas', 'internet', 'BR', '/demo/p11.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true),
  ('Juninho Reação', 'juninho-reacao', 'internet', 'BR', '/demo/p12.svg', 'ilustracao', 'Ilustração de exemplo', 'n/a', true);

insert into quotes (person_id, text, language, said_on, context, source_type, source_url, difficulty, status, verified_at, is_demo)
select p.id, v.text, 'pt', date '2024-01-01', 'Trecho fictício de exemplo', 'video', 'https://example.com/demo/' || v.n, v.diff, 'draft', null, true
from (values
  ('zeca-chuteira', 1, 'Eu não perdi o pênalti, a bola é que escolheu o outro lado.', 1),
  ('zeca-chuteira', 2, 'Estou 100% focado, só falta o resto dos 100%.', 2),
  ('dede-marcador', 3, 'Marcação cerrada é quando eu cuido do adversário até depois do jogo.', 2),
  ('tonhao-da-varzea', 4, 'Na várzea a gente joga por amor e pelo churrasco.', 1),
  ('marlene-sertaneja', 5, 'Meu novo álbum tem 14 faixas, todas sobre o mesmo corno.', 1),
  ('dj-pacoca', 6, 'Se o grave não te fez repensar a vida, aumenta mais.', 2),
  ('bruninho-do-pagode', 7, 'Eu só canto o que eu já chorei.', 3),
  ('tia-neide', 8, 'Boa noite, e se você chegou agora, a culpa não é minha.', 1),
  ('seu-lauro', 9, 'Vale mil reais, mas pra você, que é meu amigo, vale mil e cinquenta.', 2),
  ('rita-novelinha', 10, 'Essa cena eu gravei três vezes, na terceira o cachorro entendeu a emoção.', 3),
  ('caze-influ', 11, 'Gente, não é publi, mas se fosse eu estaria mais bem vestido.', 1),
  ('mari-dicas', 12, 'Acorda às 4h, bebe 3 litros d''água e culpa a Mercúrio retrógrado.', 2),
  ('juninho-reacao', 13, 'Reagindo ao meu próprio vídeo reagindo ao meu vídeo anterior.', 2),
  ('caze-influ', 14, 'Deixa o like, que eu deixo o resto pro algoritmo.', 3)
) as v(slug, n, text, diff) join people p on p.slug = v.slug;
