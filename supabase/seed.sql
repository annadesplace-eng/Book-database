-- Example row: Tipping the Velvet
insert into public.books (
  upc, title, category, product_type,
  price_excl_tax, price_incl_tax, tax, currency,
  in_stock, stock_quantity, rating, number_of_reviews,
  description, image_url, product_url
) values (
  '90fa61229261140a',
  'Tipping the Velvet',
  'Historical Fiction',
  'Books',
  53.74, 53.74, 0.00, 'GBP',
  true, 20, 1, 0,
  'Nan King, an oyster girl, falls for music-hall star Kitty Butler and follows her to London.',
  'https://books.toscrape.com/media/cache/08/e9/08e94f3731d7d6b760dfbfbc02ca5c62.jpg',
  'https://books.toscrape.com/catalogue/tipping-the-velvet_999/index.html'
)
on conflict (upc) do nothing;
