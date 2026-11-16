-- ============================================================
-- Parklea SFC — add the "uploads" storage bucket
-- Run this ONCE in the Supabase SQL Editor (Dashboard → SQL Editor).
--
-- SAFE TO RUN ON A LIVE SITE: this only creates a storage bucket and its
-- access policies. It does NOT touch or drop any of your content tables, so
-- none of your existing data is affected. (Do not re-run the full schema.sql
-- for this — that one drops and recreates the tables.)
--
-- This powers the "upload a file from your computer" button on Quick Links
-- and Policies in the admin dashboard. Uploaded files are publicly readable
-- (so site visitors can view/download them); only signed-in admins can upload.
-- ============================================================

insert into storage.buckets (id, name, public, file_size_limit)
values ('uploads', 'uploads', true, 52428800)  -- 50 MB per file
on conflict (id) do update set public = true, file_size_limit = 52428800;

drop policy if exists "Public read uploads"  on storage.objects;
drop policy if exists "Admin upload uploads"  on storage.objects;
drop policy if exists "Admin update uploads"  on storage.objects;
drop policy if exists "Admin delete uploads"  on storage.objects;

create policy "Public read uploads"  on storage.objects for select using (bucket_id = 'uploads');
create policy "Admin upload uploads" on storage.objects for insert to authenticated with check (bucket_id = 'uploads');
create policy "Admin update uploads" on storage.objects for update to authenticated using (bucket_id = 'uploads');
create policy "Admin delete uploads" on storage.objects for delete to authenticated using (bucket_id = 'uploads');
