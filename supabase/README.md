# Supabase backend

Everything the site needs on the Supabase side. No secrets are stored here.

| Path | What it is |
| --- | --- |
| `migrations/001_books.sql` | `books` table, indexes and the public read-only policy. |
| `migrations/002_recommendations.sql` | `recommendations` table and its policies (public read and insert only, with length and format checks). |
| `seed.sql` | One example book row, for testing before you scrape. |
| `functions/scrape-books/index.ts` | Edge Function that scrapes [Books to Scrape](https://books.toscrape.com) and upserts each book into `books`. Requires the `SCRAPER_SECRET` header. |
| `../scripts/run-scraper.sh` | Calls the function in five batches to load all 1,000 books. |

## Setup

Requirements: a Supabase project and the [Supabase CLI](https://supabase.com/docs/guides/cli) (to deploy the function).

1. In the SQL Editor, run `migrations/001_books.sql`, then `migrations/002_recommendations.sql`.
2. In Edge Functions -> Secrets, add `SCRAPER_SECRET` with a long random value.
3. Deploy the function: `supabase functions deploy scrape-books --no-verify-jwt`.
   Supabase provides `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to it automatically.
4. Copy `.env.example` to `.env`, fill it in, and run `bash scripts/run-scraper.sh`.
5. Put your project URL and publishable key in the `SETTINGS` block at the top of the `<script>` in `index.html`.
