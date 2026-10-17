-- Classificação das frases que já existiam (polêmica x icônica). Roda depois da migração 20261027000000_tipo_frase.
-- Pode rodar mais de uma vez.

begin;

-- Aprovadas que são bordão ou meme, não polêmica.
update quotes set kind = 'iconica'
 where status = 'verified' and left(id::text, 8) in (
   '77507bad', -- Joel Santana, inglês
   'bd089333', -- Romário, "esse é o cara"
   '164ef9a8', -- Vampeta, "fingem que pagam"
   '696ba055', -- Felipe Melo, "minhas genitais"
   '84dc9df5', '1b28382b', '83c14224', '7278f187', -- Zlatan
   'ece846b4', '28373e84', -- Cristiano Ronaldo
   'b175c62a', -- Mourinho, "special one"
   '38ba2e99', -- Elon Musk, Marte
   '0b6d5679', '294bad22', -- Kanye
   '9336721c', -- Kim Kardashian
   '2fe97c5c', -- MrBeast
   'cb90b48b', -- Inês Brasil
   '9382f0f8', -- Narcisa
   '959781ac', -- Jojo, "Tá num SPA?"
   'edba779d', '40c27b2a', 'c5bc174a', -- Anitta
   '566d36d5', '706b1356', '0646cdb2', 'b99a8f60', '9ef03fc5', -- Rita Lee
   'cd520a5b', -- Tim Maia
   'ea13457b', '46708326', -- Zeca Pagodinho
   '54dc2191', '248a3398', 'a2cb5682', '1c36d0f3', '768c8c2b', -- Dilma
   '101f7964', -- Lula, picanha
   'cc8d8794', 'e5d85356', -- Ana Maria Braga
   'e32aa8ba', -- Galvão
   '08f9a2b5', -- Xuxa
   '34e6d529', '78de4df5', -- Whindersson
   '1d280f75'  -- Felipe Neto, limite do cartão
 );

-- Recusadas só por não serem polêmicas: voltam como rascunho icônico para nova aprovação.
update quotes
   set kind = 'iconica', status = 'draft', verified_by = null, verified_at = null,
       review_note = concat_ws(' · ', review_note, 'Reaberta como icônica (bordão/meme, sem exigir polêmica).')
 where status = 'rejected' and left(id::text, 8) in (
   'f104d667', 'fa19d541', 'b25d2c10', -- Faustão
   '3296157c', 'bcd45528', '5891f9b5', -- Galvão
   'da5b4cdb', 'f5df484a', -- Silvio Santos
   '20c9c832', '4d47b693', -- Ana Maria Braga
   '2b3e16d4', -- Inês Brasil
   '421bf99e', '2ed3e758', -- Narcisa
   '443c22fb', -- Jojo, "roubaram o meu cabelo"
   '0b870afd', -- Bettina
   '8a975fc6', '8d34f4d8', -- Ivete
   'a287b99a', -- Roberto Carlos, "reiva"
   '42f2f1e4', 'd2bb888f', -- Zeca Pagodinho
   'e47677fc', -- Tim Maia
   '78d4d58c', -- Vampeta
   'a4afb711', -- Joel Santana
   '483db14a', '47ca411f', -- Neymar
   'b26f40d7', -- Mourinho, "Deus e, depois de Deus, eu"
   'f4976ef4', -- Zlatan
   'e7b914d0', -- Maradona, mão de Deus
   '8a3b300d', -- Elon Musk no SNL
   'c11eeef5', -- Kanye, "vou deixar você terminar"
   '1437a9dc', '9d5d9d8e', 'a1dc2bfe', -- Bolsonaro
   '5b6d275c', '0cf0c341', -- Trump
   '0300a710', -- Eduardo Bolsonaro, hambúrguer
   '3ec0cd59', 'c6601f6f', -- Casimiro
   'b0f596cc'  -- Toguro
 );

commit;
