create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.admins
    where lower(email) = lower(coalesce(auth.jwt() ->> 'email', ''))
  );
$$;

grant execute on function public.is_admin() to authenticated, anon;

alter table public.convocatorias force row level security;
alter table public.admins force row level security;
alter table public.bloqueados force row level security;
alter table public.log_cambios force row level security;

drop policy if exists "Publica solo convocatorias publicadas" on public.convocatorias;
create policy "Publica solo convocatorias publicadas"
on public.convocatorias for select
to anon, authenticated
using (estado = 'publicada' and deleted_at is null);

drop policy if exists "Admins leen todas las convocatorias" on public.convocatorias;
create policy "Admins leen todas las convocatorias"
on public.convocatorias for select
to authenticated
using (public.is_admin());

drop policy if exists "Admins insertan convocatorias" on public.convocatorias;
create policy "Admins insertan convocatorias"
on public.convocatorias for insert
to authenticated
with check (public.is_admin());

drop policy if exists "Admins actualizan convocatorias" on public.convocatorias;
create policy "Admins actualizan convocatorias"
on public.convocatorias for update
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Admins eliminan convocatorias" on public.convocatorias;
create policy "Admins eliminan convocatorias"
on public.convocatorias for delete
to authenticated
using (public.is_admin());

drop policy if exists "Solo admins gestionan admins" on public.admins;
create policy "Solo admins gestionan admins"
on public.admins for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Solo admins gestionan bloqueados" on public.bloqueados;
create policy "Solo admins gestionan bloqueados"
on public.bloqueados for all
to authenticated
using (public.is_admin())
with check (public.is_admin());

drop policy if exists "Solo admins leen cambios" on public.log_cambios;
create policy "Solo admins leen cambios"
on public.log_cambios for select
to authenticated
using (public.is_admin());

drop policy if exists "Solo admins registran cambios" on public.log_cambios;
create policy "Solo admins registran cambios"
on public.log_cambios for insert
to authenticated
with check (public.is_admin());
