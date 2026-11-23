begin;

set role anon;

select not exists (
  select 1
  from public.convocatorias
  where estado = 'pendiente' or estado = 'rechazada' or deleted_at is not null
) as anon_no_ve_estados_reservados;

select exists (
  select 1
  from public.convocatorias
  where estado = 'publicada' and deleted_at is null
) as anon_ve_publicadas;

reset role;
rollback;
