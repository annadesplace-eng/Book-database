#!/usr/bin/env bash
# Fills the books table by calling the scrape-books Edge Function
# in five batches of 10 pages (50 pages x 20 books = 1,000 books).
#
# Usage: copy .env.example to .env, fill in SUPABASE_URL and
# SUPABASE_PUBLISHABLE_KEY, then run: bash scripts/run-scraper.sh
set -euo pipefail

if [ -f .env ]; then set -a; . ./.env; set +a; fi
: "${SUPABASE_URL:?Set SUPABASE_URL in .env}"
: "${SUPABASE_PUBLISHABLE_KEY:?Set SUPABASE_PUBLISHABLE_KEY in .env}"

for from in 1 11 21 31 41; do
  to=$((from + 9))
  echo "Scraping pages $from-$to..."
  curl -sS -X POST "$SUPABASE_URL/functions/v1/scrape-books" \
    -H "apikey: $SUPABASE_PUBLISHABLE_KEY" \
    -H "Content-Type: application/json" \
    --data "{\"from\": $from, \"to\": $to}"
  echo
done
