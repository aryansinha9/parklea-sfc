-- ============================================================
-- Parklea SFC — quick links: closed/disabled states + reorder
-- Run once in the Supabase SQL Editor (Dashboard → SQL Editor).
-- Non-destructive: alters the existing quick_links table and
-- updates the live rows. Safe to re-run.
-- ============================================================

-- ---------- SCHEMA ----------

alter table public.quick_links add column if not exists disabled boolean not null default false;
alter table public.quick_links add column if not exists note     text    not null default '';

alter table public.quick_links drop constraint if exists quick_links_badge_check;
alter table public.quick_links add  constraint quick_links_badge_check
  check (badge in ('none','open','new','soon','closed'));

-- ---------- CONTENT ----------

-- Registrations closed for the season: greyed out and not clickable.
update public.quick_links
   set badge = 'closed', disabled = true,
       note = 'Registrations open again next season.'
 where title = 'Register for 2026';

-- Super Kickers is closed too: greyed out and not clickable.
update public.quick_links
   set badge = 'closed', disabled = true,
       note = 'Registrations open again next season.',
       description = 'Our flagship program for 2–4 year olds. Registrations for this season have now closed.'
 where title = 'Super Kickers';

-- Development Program loses its "New" tag.
update public.quick_links set badge = 'none' where title = 'Development Program';

-- Swap Super Kickers (was 3) and Committee Nominations (was 8).
update public.quick_links set sort_order = 3 where title = 'Committee Nominations';
update public.quick_links set sort_order = 8 where title = 'Super Kickers';
