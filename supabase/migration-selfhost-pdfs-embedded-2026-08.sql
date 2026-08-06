-- ============================================================
-- Parklea SFC - follow-up to migration-selfhost-pdfs-2026-08.sql
--
-- That migration matched whole values (where value = '<url>'), which covers
-- every policies.url, quick_links.url and single-URL page_content value. It
-- could not touch URLs *embedded inside* a larger value: page_content holds
-- some fields as HTML, and miniroos.links is a block of
-- <li><a href="...">...</a></li> lines carrying 5 legacy URLs between them.
--
-- Every downloaded file kept its original basename byte-for-byte, so swapping
-- the directory prefix is an exact rewrite, not a guess.
--
-- The LIKE guard is deliberately '/uploads/': it leaves the shop login
-- (/401/login.php on the same host) alone, which is a live application rather
-- than a file and is intentionally staying put.
--
-- Idempotent: replace() is a no-op once the URLs are already rewritten.
-- Run in Supabase Dashboard -> SQL Editor.
-- ============================================================

begin;

update public.page_content
set value = replace(
      value,
      'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/',
      '/docs/'
    )
where value like '%www.parkleasfc.com.au/uploads/%';

-- Same guard applied to the other two tables, in case any value ever embeds a
-- URL rather than being one. No-ops today; cheap insurance.
update public.policies
set url = replace(url, 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/', '/docs/')
where url like '%www.parkleasfc.com.au/uploads/%';

update public.quick_links
set url = replace(url, 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/', '/docs/')
where url like '%www.parkleasfc.com.au/uploads/%';

-- Verify before committing.
-- legacy_left must be 0 on all three.
-- The shop login is expected to survive and is NOT counted here.
select 'policies'     as tbl, count(*) as legacy_left from public.policies     where url   like '%parkleasfc.com.au/uploads/%'
union all
select 'quick_links'  as tbl, count(*)                from public.quick_links  where url   like '%parkleasfc.com.au/uploads/%'
union all
select 'page_content' as tbl, count(*)                from public.page_content where value like '%parkleasfc.com.au/uploads/%';

commit;
