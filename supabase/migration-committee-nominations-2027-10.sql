-- ============================================================
-- Parklea SFC — quick links: 2027 committee nomination form
-- Run once in the Supabase SQL Editor (Dashboard → SQL Editor).
-- Non-destructive: adds one column and updates one existing row.
-- Safe to re-run.
--
-- The homepage Quick Links render from quick_links, so the static
-- HTML change in index.html only shows until Supabase responds —
-- this row is what the live page actually displays.
-- ============================================================

-- ---------- SCHEMA ----------

-- When true, the card downloads the file instead of opening it.
alter table public.quick_links add column if not exists download boolean not null default false;

-- ---------- CONTENT ----------

update public.quick_links
   set url         = '/docs/2027_committee_nomination_form_final.pdf',
       badge       = 'new',
       new_tab     = false,
       download    = true
 where title = 'Committee Nominations';
