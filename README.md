# The Library

A browsable 3D bookshelf of 1,000 books, stored in Supabase, with a second shelf where visitors can recommend books.

**Live site:** https://annadesplace-eng.github.io/Bts/

## Purpose

The Library is a project for practising the full path from collecting data to showing it: scrape a catalogue, store it in a hosted Postgres database, and build a front end that reads from it and lets visitors add to it.

## Data collection

1. **Book catalogue (scraped).** The `scrape-books` Supabase Edge Function ([`supabase/functions/scrape-books/index.ts`](supabase/functions/scrape-books/index.ts)) reads [Books to Scrape](https://books.toscrape.com), a sandbox site built for scraping practice. For each book it collects the UPC, title, category, prices, tax, stock, star rating, number of reviews, description, cover image and page URL, and upserts it into the `books` table. It is run in five batches by [`scripts/run-scraper.sh`](scripts/run-scraper.sh).
2. **Extra book details (Open Library).** When a visitor looks at a book, the page searches [Open Library](https://openlibrary.org) by title to show the author, first publication year, binding and subjects.
3. **Visitor recommendations.** Visitors search Open Library for a book and can add an optional name and note. The page saves the title, author, year, subjects, Open Library cover and link, name and note to the `recommendations` table.

**Personal data:** the optional name and note in a recommendation are stored in Supabase and **shown publicly** to everyone. The form says so. No accounts, emails or tracking are used.

## Persistence

| Where | What |
| --- | --- |
| Supabase `books` table | The scraped catalogue. The public can only read it; only the scraper (service role) can write. |
| Supabase `recommendations` table | Visitor recommendations. The public can read and add rows, but not edit or delete them. Database checks limit lengths and only allow Open Library cover and link formats. |
| Browser `localStorage` (`ol-cache`) | A cache of Open Library lookups, so details load instantly next time. It stays in the visitor's browser. |

The schema and access rules are in [`supabase/migrations/`](supabase/migrations/).

## User interaction

- **Browse the shelf:** books move slowly along the shelf. Drag or use the arrows to scroll.
- **Hover** a book to see its author, year, binding, rating, price and subjects.
- **Click** a book to pull it out and read its description, with a link to its original page.
- **Filter by genre** with the genre buttons.
- **Search:** type words into "What are you looking for?". The page matches genre names and scores titles, categories and descriptions by keyword.
- **Recommend a book:** search Open Library, pick a result, optionally add your name and why I should read it, and it flies onto the "Recommended to me" shelf.

## Setup

Requirements: a free [Supabase](https://supabase.com) project, the [Supabase CLI](https://supabase.com/docs/guides/cli) to deploy the function, and `bash` and `curl` to run the scraper.

1. **Database:** in the Supabase SQL Editor, run `supabase/migrations/001_books.sql` and `supabase/migrations/002_recommendations.sql`. Optionally run `supabase/seed.sql` for one test row.
2. **Deploy the scraper:** `supabase functions deploy scrape-books --no-verify-jwt`.
3. **Configure:** copy `.env.example` to `.env` and fill in your project URL and publishable key. `.env` is ignored by Git.
4. **Load the books:** `bash scripts/run-scraper.sh`.
5. **Front end:** in `index.html`, set `SUPABASE_URL` and `SUPABASE_KEY` (the publishable key) in the `SETTINGS` block, then open the file in a browser or publish it with GitHub Pages.

The publishable key is designed to be public: it only allows what the database's row-level security rules permit. Never put the service role key in `index.html`.

More detail: [`supabase/README.md`](supabase/README.md).

## Learning

This project practises:

- Web scraping with regular expressions, retries and batching inside a serverless function.
- Designing a Postgres table, indexes and row-level security policies in Supabase.
- Reading and writing through Supabase's REST API from plain JavaScript, with paging for large tables.
- Enriching data from a second API (Open Library) and caching it in `localStorage`.
- Escaping and validating untrusted data before putting it on the page and in the database.
- Animation and performance: a virtualised 3D shelf that only renders the books on screen, and respecting "reduce motion".

<!-- Add your own reflections here: what was hard, what you would do differently. -->

## Limitations

- **Keyword search only.** Search matches words in genres, titles, categories and descriptions; it does not understand prices or meaning.
- **Open Library matches are by title**, so some books get the wrong author or year, or none.
- **Recommendations are not moderated.** Anyone can add one, and names and notes are public. Spam would need to be removed by hand in Supabase.
- **The catalogue is fictional practice data.** Books to Scrape prices, stock and ratings are made up.
- **Fonts load from Google Fonts**, which sends visitors' IP addresses to Google.
- **The scraper has no password.** Anyone who finds its URL can run it; it only re-loads data from Books to Scrape.
- **Needs JavaScript and a modern browser.**

## Credits and licence

- Catalogue data: [Books to Scrape](https://books.toscrape.com) (a sandbox for scraping practice).
- Book details and covers: [Open Library](https://openlibrary.org).
- Fonts: Cormorant Garamond, Karla and Space Mono via Google Fonts.
- Code: MIT licence, see [LICENSE](LICENSE).
