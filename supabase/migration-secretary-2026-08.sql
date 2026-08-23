-- ============================================================
-- Parklea SFC — 2026 committee: correct the Secretary's name
-- Run once in the Supabase SQL Editor (Dashboard → SQL Editor).
-- Non-destructive: updates one existing row. Safe to re-run.
--
-- The committee page renders from committee_members, so the
-- static HTML fix in committee.html only shows until Supabase
-- responds — this row is what the live page actually displays.
-- ============================================================

update public.committee_members
   set name = 'David Quitto'
 where section = 'executive'
   and role    = 'Secretary';

-- ---------- VERIFY ----------
-- Expect one row: executive | Secretary | David Quitto
select section, role, name, email, mobile
  from public.committee_members
 where section = 'executive'
   and role    = 'Secretary';
