#!/usr/bin/env bash
# Fills the books table by calling the scrape-books Edge Function
# in five batches of 10 pages (50 pages x 20 books = 1,000 books).
#
# Usage: copy .env.example to .env, fill in SUPABASE_URL,
# SUPABASE_PUBLISHABLE_KEY and SCRAPER_SECRET, then run:
#   bash scripts/run-scraper.sh
set -euo pipefail

if [ -f .env ]; then set -a; . ./.env; set +a; fi
: "${SUPABASE_URL:?Set SUPABASE_URL in .env}"
: "${SUPABASE_PUBLISHABLE_KEY:?Set SUPABASE_PUBLISHABLE_KEY in .env}"
: "${SCRAPER_SECRET:?Set SCRAPER_SECRET in .env (same value as the Supabase secret)}"

for from in 1 11 21 31 41; do
  to=$((from + 9))
  echo "Scraping pages $from-$to..."
  curl -sS -X POST "$SUPABASE_URL/functions/v1/scrape-books" \
    -H "apikey: $SUPABASE_PUBLISHABLE_KEY" \
    -H "x-scraper-secret: $SCRAPER_SECRET" \
    -H "Content-Type: application/json" \
    --data "{\"from\": $from, \"to\": $to}"
  echo
done
