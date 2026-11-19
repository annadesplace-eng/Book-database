-- Books to Scrape -> Supabase (PostgreSQL)
-- One table holding every field shown on a book's product page.
create table if not exists public.books (
  id                bigint generated always as identity primary key,
  upc               text not null unique,            -- e.g. 90fa61229261140a
  title             text not null,
  category          text,                            -- breadcrumb, e.g. Historical Fiction
  product_type      text default 'Books',
  price_excl_tax    numeric(10,2),                   -- in GBP
  price_incl_tax    numeric(10,2),
  tax               numeric(10,2) default 0,
  currency          text default 'GBP',
  in_stock          boolean default true,
  stock_quantity    integer,                         -- "20 available"
  rating            smallint check (rating between 1 and 5), -- star rating
  number_of_reviews integer default 0,
  description       text,
  image_url         text,
  product_url       text unique,
  created_at        timestamptz default now()
);

-- Helpful indexes
create index if not exists books_category_idx on public.books (category);
create index if not exists books_price_idx    on public.books (price_incl_tax);

-- Row Level Security (Supabase best practice): public read-only
alter table public.books enable row level security;

drop policy if exists "Public can read books" on public.books;
create policy "Public can read books"
  on public.books for select
  using (true);

-- Let the website (anon) read and the Edge Function (service_role) write
grant usage on schema public to anon, authenticated, service_role;
grant select on public.books to anon, authenticated;
grant all on public.books to service_role;
