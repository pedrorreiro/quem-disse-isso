-- Alternativas que fazem sentido: as 3 opções erradas saem da mesma área (futebol, música...),
-- do mesmo gênero e do mesmo "lado" (brasileiro x gringo) de quem disse a frase.
-- Também aumenta o tempo de cada rodada para 30 s. Pode rodar mais de uma vez.

create or replace function public.round_seconds() returns int
language sql immutable as $$ select 30 $$;

alter table public.people add column if not exists area   text;
alter table public.people add column if not exists gender text;
alter table public.people drop constraint if exists people_gender_check;
alter table public.people add constraint people_gender_check check (gender in ('m', 'f'));

-- área = categoria, exceto os gringos, que vão para a área em que atuam
update public.people set area = category where area is null and category <> 'gringos';

update public.people p set area = coalesce(p.area, v.area), gender = coalesce(p.gender, v.gender)
from (values
  ('edmundo', 'futebol', 'm'), ('felipe-melo', 'futebol', 'm'), ('joel-santana', 'futebol', 'm'), ('neto', 'futebol', 'm'),
  ('neymar', 'futebol', 'm'), ('pele', 'futebol', 'm'), ('renato-gaucho', 'futebol', 'm'), ('romario', 'futebol', 'm'),
  ('ronaldo-fenomeno', 'futebol', 'm'), ('vampeta', 'futebol', 'm'),
  ('cristiano-ronaldo', 'futebol', 'm'), ('diego-maradona', 'futebol', 'm'), ('jose-mourinho', 'futebol', 'm'),
  ('lionel-messi', 'futebol', 'm'), ('zlatan-ibrahimovic', 'futebol', 'm'),
  ('elon-musk', 'internet', 'm'), ('mrbeast', 'internet', 'm'), ('kanye-west', 'musica', 'm'),
  ('madonna', 'musica', 'f'), ('kim-kardashian', 'tv', 'f'), ('donald-trump', 'politica', 'm'),
  ('carlinhos-maia', 'internet', 'm'), ('casimiro', 'internet', 'm'), ('felipe-castanhari', 'internet', 'm'),
  ('felipe-neto', 'internet', 'm'), ('gil-do-vigor', 'internet', 'm'), ('whindersson-nunes', 'internet', 'm'),
  ('gretchen', 'internet', 'f'), ('ines-brasil', 'internet', 'f'), ('jojo-todynho', 'internet', 'f'),
  ('karol-conka', 'internet', 'f'), ('kefera-buchmann', 'internet', 'f'), ('narcisa-tamborindeguy', 'internet', 'f'),
  ('virginia-fonseca', 'internet', 'f'),
  ('caetano-veloso', 'musica', 'm'), ('fabio-jr', 'musica', 'm'), ('gilberto-gil', 'musica', 'm'),
  ('gusttavo-lima', 'musica', 'm'), ('lobao', 'musica', 'm'), ('luan-santana', 'musica', 'm'),
  ('ney-matogrosso', 'musica', 'm'), ('roberto-carlos', 'musica', 'm'), ('tim-maia', 'musica', 'm'),
  ('zeca-pagodinho', 'musica', 'm'), ('anitta', 'musica', 'f'), ('ivete-sangalo', 'musica', 'f'),
  ('rita-lee', 'musica', 'f'), ('pabllo-vittar', 'musica', 'f'),
  ('ciro-gomes', 'politica', 'm'), ('eduardo-bolsonaro', 'politica', 'm'), ('jair-bolsonaro', 'politica', 'm'),
  ('lula', 'politica', 'm'), ('michel-temer', 'politica', 'm'), ('dilma-rousseff', 'politica', 'f'),
  ('damares-alves', 'politica', 'f'), ('janja', 'politica', 'f'),
  ('datena', 'tv', 'm'), ('faustao', 'tv', 'm'), ('galvao-bueno', 'tv', 'm'), ('silvio-santos', 'tv', 'm'),
  ('ana-maria-braga', 'tv', 'f'), ('luciana-gimenez', 'tv', 'f'), ('xuxa', 'tv', 'f')
) as v(slug, area, gender)
where p.slug = v.slug;

-- Cada opção errada ganha "pontos de estranheza"; ficam as 3 com menos (empate: sorteio).
create or replace function public._pick_options(p_quote_id uuid) returns uuid[]
language plpgsql volatile security definer set search_path = public as $$
declare
  v_diff    smallint;
  v_p       people;
  v_wrong   uuid[];
begin
  select q.difficulty into v_diff from quotes q where q.id = p_quote_id;
  select p.* into v_p from quotes q join people p on p.id = q.person_id where q.id = p_quote_id;

  select array_agg(id) into v_wrong from (
    select id from people o
     where o.id <> v_p.id and o.photo_status = 'approved'
     order by
       (case when coalesce(o.area, o.category) <> coalesce(v_p.area, v_p.category) then 8 else 0 end)
     + (case when o.gender is not null and v_p.gender is not null and o.gender <> v_p.gender then 6 else 0 end)
     + (case when (o.country = 'BR') is distinct from (v_p.country = 'BR') then 3 else 0 end)
     + (case when o.category <> v_p.category then 1 else 0 end)
     + (case when v_diff >= 3 and o.country is distinct from v_p.country then 1 else 0 end),
       random()
     limit 3
  ) s;

  if v_wrong is null or cardinality(v_wrong) < 3 then
    raise exception 'not_enough_people';
  end if;

  return (select array_agg(x order by random()) from unnest(array_append(v_wrong, v_p.id)) x);
end $$;

-- Painel: área e gênero editáveis.
create or replace function public.admin_upsert_person(p jsonb) returns uuid
language plpgsql volatile security definer set search_path = public as $$
declare
  v_id uuid := (p->>'id')::uuid;
begin
  perform public._require_admin();
  if v_id is null then
    insert into people (name, slug, category, area, gender, country, bio_short, wikidata_id,
                        image_url, image_type, image_credit, image_license, image_source_url)
    values (p->>'name', p->>'slug', p->>'category', coalesce(nullif(p->>'area', ''), p->>'category'), nullif(p->>'gender', ''),
            nullif(p->>'country', ''), nullif(p->>'bio_short', ''),
            nullif(p->>'wikidata_id', ''), nullif(p->>'image_url', ''), coalesce(nullif(p->>'image_type', ''), 'foto'),
            nullif(p->>'image_credit', ''), nullif(p->>'image_license', ''), nullif(p->>'image_source_url', ''))
    returning id into v_id;
  else
    update people set
      name             = coalesce(p->>'name', name),
      slug             = coalesce(p->>'slug', slug),
      category         = coalesce(p->>'category', category),
      area             = case when p ? 'area' then nullif(p->>'area', '') else area end,
      gender           = case when p ? 'gender' then nullif(p->>'gender', '') else gender end,
      country          = case when p ? 'country' then nullif(p->>'country', '') else country end,
      bio_short        = case when p ? 'bio_short' then nullif(p->>'bio_short', '') else bio_short end,
      wikidata_id      = case when p ? 'wikidata_id' then nullif(p->>'wikidata_id', '') else wikidata_id end,
      image_url        = case when p ? 'image_url' then nullif(p->>'image_url', '') else image_url end,
      image_type       = coalesce(nullif(p->>'image_type', ''), image_type),
      image_credit     = case when p ? 'image_credit' then nullif(p->>'image_credit', '') else image_credit end,
      image_license    = case when p ? 'image_license' then nullif(p->>'image_license', '') else image_license end,
      image_source_url = case when p ? 'image_source_url' then nullif(p->>'image_source_url', '') else image_source_url end
    where id = v_id;
    if not found then raise exception 'person_not_found'; end if;
  end if;
  return v_id;
end $$;

revoke all on function public._pick_options(uuid), public.admin_upsert_person(jsonb) from public, anon, authenticated;
grant execute on function public.admin_upsert_person(jsonb) to authenticated;
