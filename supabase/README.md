# Supabase backend

Everything the site needs on the Supabase side. No secrets are stored here.

| Path | What it is |
| --- | --- |
| `migrations/001_books.sql` | `books` table, indexes and the public read-only policy. This is what the live project runs. |
| `migrations/002_recommendations.sql` | `recommendations` table and its policies (public read and insert only). **Not applied to the live project yet.** |
| `seed.sql` | One example book row, for testing before you scrape. |
| `functions/scrape-books/index.ts` | Edge Function that scrapes [Books to Scrape](https://books.toscrape.com) and upserts each book into `books`. |
| `../scripts/run-scraper.sh` | Calls the function in five batches to load all 1,000 books. |

## Setup

1. Create a Supabase project.
2. In the SQL Editor, run `migrations/001_books.sql`, then `migrations/002_recommendations.sql`.
3. Deploy the function: `supabase functions deploy scrape-books`.
   Supabase provides `SUPABASE_URL` and `SUPABASE_SERVICE_ROLE_KEY` to it automatically.
4. Copy `.env.example` to `.env`, fill it in, and run `bash scripts/run-scraper.sh`.
5. Put your project URL and publishable key in the `SETTINGS` block at the top of the `<script>` in `index (2).html`.

## Notes

- The page also calls an `ask-library` function for AI search. That function does not exist yet,
  so the page falls back to simple keyword matching.
- `scrape-books` currently runs without authentication, so anyone with its URL can trigger a scrape.
  It can only re-load data from Books to Scrape, but consider adding a shared-secret check.
