create extension if not exists pgcrypto;

create table if not exists public.convocatorias (
  id uuid primary key default gen_random_uuid(),
  nombre text not null,
  institucion text not null,
  pais_alcance text not null check (pais_alcance in ('Colombia', 'Latinoamérica', 'Internacional')),
  monto_texto text,
  monto_numerico numeric,
  moneda text,
  fecha_limite date,
  abierta_permanente boolean not null default false,
  requisitos_postulante text,
  criterios_elegibilidad_proyecto text,
  niveles text[] not null default '{}'::text[],
  tipos_apoyo text[] not null default '{}'::text[],
  areas_ingenieria text[] not null default '{}'::text[],
  url_oficial text not null,
  url_tdr text,
  fuente text not null,
  url_hash text not null unique,
  estado text not null default 'pendiente' check (estado in ('pendiente', 'publicada', 'rechazada')),
  puntaje integer not null default 0,
  creada_por text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.admins (
  email text primary key,
  rol text not null check (rol in ('admin', 'editor'))
);

create table if not exists public.bloqueados (
  url_hash text primary key,
  motivo text,
  created_at timestamptz not null default now()
);

create table if not exists public.log_cambios (
  id bigint generated always as identity primary key,
  convocatoria_id uuid references public.convocatorias(id) on delete set null,
  usuario_email text,
  accion text not null,
  detalle jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_convocatorias_publicadas on public.convocatorias (estado, deleted_at, fecha_limite);
create index if not exists idx_convocatorias_puntaje on public.convocatorias (puntaje desc);
create index if not exists idx_convocatorias_created_at on public.convocatorias (created_at desc);

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

drop trigger if exists set_convocatorias_updated_at on public.convocatorias;
create trigger set_convocatorias_updated_at
before update on public.convocatorias
for each row execute function public.set_updated_at();

alter table public.convocatorias enable row level security;
alter table public.admins enable row level security;
alter table public.bloqueados enable row level security;
alter table public.log_cambios enable row level security;
