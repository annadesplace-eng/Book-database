-- Visitor recommendations shown on the "Recommended by visitors" shelf.
-- NOT YET APPLIED: this table does not exist in the live project yet.
-- Run this in the Supabase SQL Editor to enable the "Recommend a book" feature.
--
-- Note: recommended_by and note are typed by visitors and shown publicly.

create table if not exists public.recommendations (
  id             bigint generated always as identity primary key,
  title          text not null check (char_length(title) between 1 and 300),
  author         text check (char_length(author) <= 300),
  year           integer check (year between 0 and 2100),
  genres         text check (char_length(genres) <= 300),
  cover_url      text check (cover_url like 'https://covers.openlibrary.org/%'),
  ol_key         text check (ol_key ~ '^/(works|books)/[A-Za-z0-9]+$'),
  recommended_by text check (char_length(recommended_by) <= 60),
  note           text check (char_length(note) <= 500),
  created_at     timestamptz not null default now()
);

alter table public.recommendations enable row level security;

-- Anyone can read recommendations
drop policy if exists "Public can read recommendations" on public.recommendations;
create policy "Public can read recommendations"
  on public.recommendations for select
  using (true);

-- Anyone can add a recommendation (no editing or deleting)
drop policy if exists "Public can add recommendations" on public.recommendations;
create policy "Public can add recommendations"
  on public.recommendations for insert
  with check (true);

grant select, insert on public.recommendations to anon, authenticated;
grant all on public.recommendations to service_role;
