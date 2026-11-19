// Supabase Edge Function: scrape-books
// Scrapes pages "from" to "to" (20 books per page) and saves them.
// Test with {"from": 1, "to": 10}, then 11-20, 21-30, 31-40, 41-50.

import { createClient } from "npm:@supabase/supabase-js@2";

const BASE = "https://books.toscrape.com/catalogue/";
const RATINGS: Record<string, number> = { One: 1, Two: 2, Three: 3, Four: 4, Five: 5 };

const supabase = createClient(
  Deno.env.get("SUPABASE_URL")!,
  Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!,
);

async function getHtml(url: string): Promise<string> {
  for (let attempt = 1; attempt <= 3; attempt++) {
    try {
      const res = await fetch(url);
      if (res.ok) return await res.text();
    } catch (_) { /* retry */ }
    await new Promise((r) => setTimeout(r, 1000 * attempt));
  }
  throw new Error(`Failed to load ${url}`);
}

function decode(text: string): string {
  return text
    .replace(/&amp;/g, "&").replace(/&quot;/g, '"').replace(/&#39;/g, "'")
    .replace(/&lt;/g, "<").replace(/&gt;/g, ">").trim();
}

function money(text?: string): number | null {
  const m = text?.match(/[\d.]+/);
  return m ? parseFloat(m[0]) : null;
}

async function scrapeBook(url: string) {
  const html = await getHtml(url);
  const info: Record<string, string> = {};
  for (const m of html.matchAll(/<th>(.*?)<\/th>\s*<td>(.*?)<\/td>/gs)) {
    info[decode(m[1])] = decode(m[2]);
  }
  const availability = info["Availability"] ?? "";
  const qty = availability.match(/\((\d+) available\)/);
  const ratingWord = html.match(/<p class="star-rating (\w+)">/)?.[1] ?? "";
  const description = html.match(
    /<div id="product_description"[\s\S]*?<\/div>\s*<p>([\s\S]*?)<\/p>/,
  )?.[1];
  const category = html.match(/<a href="\.\.\/category\/books\/[^"]+">([^<]+)<\/a>/)?.[1];
  const image = html.match(/<div class="item active">\s*<img src="([^"]+)"/)?.[1];
  const title = html.match(/<h1>([\s\S]*?)<\/h1>/)?.[1];

  return {
    upc: info["UPC"],
    title: title ? decode(title) : null,
    category: category ? decode(category) : null,
    product_type: info["Product Type"] ?? null,
    price_excl_tax: money(info["Price (excl. tax)"]),
    price_incl_tax: money(info["Price (incl. tax)"]),
    tax: money(info["Tax"]),
    currency: "GBP",
    in_stock: availability.includes("In stock"),
    stock_quantity: qty ? parseInt(qty[1]) : 0,
    rating: RATINGS[ratingWord] ?? null,
    number_of_reviews: parseInt(info["Number of reviews"] ?? "0") || 0,
    description: description ? decode(description) : null,
    image_url: image ? new URL(image, url).href : null,
    product_url: url,
  };
}

async function scrapePage(page: number) {
  const pageUrl = `${BASE}page-${page}.html`;
  const listing = await getHtml(pageUrl);
  const bookUrls = [...listing.matchAll(/<h3><a href="([^"]+)"/g)]
    .map((m) => new URL(m[1], pageUrl).href);
  const books = (await Promise.all(bookUrls.map(scrapeBook))).filter((b) => b.upc);
  const { error } = await supabase.from("books").upsert(books, { onConflict: "upc" });
  if (error) throw error;
  return books.length;
}

Deno.serve(async (req) => {
  const body = await req.json().catch(() => ({}));
  const from = Number(body.from ?? body.page ?? 1);
  const to = Math.min(Number(body.to ?? from), 50);
  let saved = 0;
  const failed: number[] = [];

  for (let page = from; page <= to; page++) {
    try {
      saved += await scrapePage(page);
    } catch (err) {
      console.error(`Page ${page} failed:`, err);
      failed.push(page);
    }
  }

  return Response.json({ pages: `${from}-${to}`, saved, failed });
});
