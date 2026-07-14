-- ============================================================
-- Parklea SFC — CMS schema, security policies & seed data
-- Run this once in the Supabase SQL Editor (Dashboard → SQL Editor).
-- It is safe to re-run: it drops and recreates the CMS tables.
-- ============================================================

-- ---------- TABLES ----------

drop table if exists public.quick_links;
create table public.quick_links (
  id          uuid primary key default gen_random_uuid(),
  title       text not null,
  description text not null default '',
  url         text not null,
  badge       text not null default 'none' check (badge in ('none','open','new','soon')),
  new_tab     boolean not null default true,
  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);

drop table if exists public.sponsors;
create table public.sponsors (
  id          uuid primary key default gen_random_uuid(),
  name        text not null,
  logo_url    text,                -- public URL (Supabase Storage or /path)
  website_url text,
  tier        text not null default 'official' check (tier in ('principal','major','official')),
  tagline     text,                -- shown under the name for the principal partner on the homepage
  featured    boolean not null default false,  -- featured = shown on the homepage "Built with great partners"
  logo_height int,                 -- optional logo height override in px (e.g. 120 for Kings Park Tavern)
  sort_order  int not null default 0,
  created_at  timestamptz not null default now()
);

drop table if exists public.life_members;
create table public.life_members (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  year       text not null default '',   -- text so values like "Founder" work
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

drop table if exists public.committee_members;
create table public.committee_members (
  id         uuid primary key default gen_random_uuid(),
  section    text not null check (section in ('executive','management','general')),
  role       text,                -- e.g. "President" (not used for General Committee)
  name       text not null,
  email      text,
  mobile     text,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

drop table if exists public.policies;
create table public.policies (
  id         uuid primary key default gen_random_uuid(),
  section    text not null check (section in ('regulations','policies','guidelines','code_of_conduct')),
  title      text not null,
  url        text not null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

-- ---------- ROW LEVEL SECURITY ----------
-- Everyone can read (the public website needs the content);
-- only authenticated users (admins) can write.

alter table public.quick_links       enable row level security;
alter table public.sponsors          enable row level security;
alter table public.life_members      enable row level security;
alter table public.committee_members enable row level security;
alter table public.policies          enable row level security;

do $$
declare t text;
begin
  foreach t in array array['quick_links','sponsors','life_members','committee_members','policies'] loop
    execute format('create policy "Public read"  on public.%I for select using (true)', t);
    execute format('create policy "Admin insert" on public.%I for insert to authenticated with check (true)', t);
    execute format('create policy "Admin update" on public.%I for update to authenticated using (true)', t);
    execute format('create policy "Admin delete" on public.%I for delete to authenticated using (true)', t);
  end loop;
end $$;

-- ---------- STORAGE (sponsor logos) ----------

insert into storage.buckets (id, name, public)
values ('sponsor-logos', 'sponsor-logos', true)
on conflict (id) do nothing;

drop policy if exists "Public read sponsor logos"   on storage.objects;
drop policy if exists "Admin upload sponsor logos"  on storage.objects;
drop policy if exists "Admin update sponsor logos"  on storage.objects;
drop policy if exists "Admin delete sponsor logos"  on storage.objects;

create policy "Public read sponsor logos"  on storage.objects for select using (bucket_id = 'sponsor-logos');
create policy "Admin upload sponsor logos" on storage.objects for insert to authenticated with check (bucket_id = 'sponsor-logos');
create policy "Admin update sponsor logos" on storage.objects for update to authenticated using (bucket_id = 'sponsor-logos');
create policy "Admin delete sponsor logos" on storage.objects for delete to authenticated using (bucket_id = 'sponsor-logos');

-- ---------- SEED DATA (matches the current live content exactly) ----------

insert into public.quick_links (title, description, url, badge, new_tab, sort_order) values
('Register for 2026',     'Secure your spot for the upcoming season. Senior, women''s and junior registrations are now live.', 'https://tinyurl.com/PSFC-Registrations', 'open', true, 1),
('Training Schedule',     'View the full training allocation for all squads across the 2026 season.', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/training_allocation_2026_v4.pdf', 'new', true, 2),
('Super Kickers',         'Register your little one for our flagship program designed for 2–4 year olds.', 'https://www.trybooking.com/events/landing/1566830', 'open', true, 3),
('Development Program',   'Elevate your game with our new development pathway. Information and registration open.', 'https://www.trybooking.com/events/landing/1566830', 'new', true, 4),
('Payment Plans',         'Flexible payment options available for the 2026 season fees.', 'payment-plans', 'none', false, 5),
('U5s–U7s Parent Info',   'Everything parents need to know about junior football at Parklea SFC.', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/under_5s_to_7s_faqs_2026.pdf', 'none', true, 6),
('Season Calendar',       'Key dates, match days, and events for the full 2026 season.', 'coming-soon?page=calendar', 'soon', false, 7),
('Committee Nominations', 'Nominate for the 2026 committee and help shape the future of the club.', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/2026_committee_nomination_form_final.pdf', 'none', true, 8);

insert into public.sponsors (name, logo_url, website_url, tier, tagline, featured, logo_height, sort_order) values
('El Jannah',              '/cms-assets/sponsor-el-jannah.png', 'https://www.eljannah.com.au',        'principal', 'Major Partner · Legendary Charcoal Chicken', true, null, 1),
('KOTP',                   '/cms-assets/sponsor-kotp.png',       null,                                 'major',     null, true, null, 2),
('Kings Park Tavern',      '/cms-assets/sponsor-kings-park.png', null,                                 'major',     null, true, 120,  3),
('F45 Training',           '/cms-assets/sponsor-f45.png',        null,                                 'official',  null, true, null, 4),
('Hydraulic Distributors', '/cms-assets/sponsor-hydraulic.png',  null,                                 'official',  null, true, null, 5),
('JOGA',                   null, 'https://jogagear.com',                        'official', null, false, null, 6),
('H3VISUALS',              null, 'https://www.instagram.com/h3visuals/',        'official', null, false, null, 7);

insert into public.life_members (name, year, sort_order) values
('Reg Moore', '', 1), ('Jim Kay', 'Founder', 2), ('Bob Jess', '1985', 3),
('Dianne Scrimshaw', '', 4), ('Glen Chant', '', 5), ('Tom Liddell', '', 6),
('Gary Clarke', '', 7), ('Ron Di Sandro', '', 8), ('Dennis Vella', '', 9),
('Ian Hudson', '', 10), ('Larry Tibbetts', '', 11), ('Phil Partington', '', 12),
('Tony Viviani', '', 13), ('Ian Westray', '', 14), ('Les McLaren', '', 15),
('Graeme Roberts', '', 16), ('Jenny Auwers', '', 17), ('Mick Leechburch-Auwers', '', 18),
('Rosanne Vowles', '2004', 19), ('Mark Vowles', '2004', 20), ('Mick Bergin', '2004', 21),
('Paul Clarke', '2005', 22), ('John McShane', '', 23), ('John Papaioannou', '', 24),
('Maurice Krenich', '2009', 25), ('Brian Mac', '', 26), ('Brad McCarthy', '', 27),
('Michael Carraro', '2012', 28), ('Peter Kerrigan', '2013', 29), ('Michelle Ewen', '2013', 30),
('Alan Mason', '2013', 31), ('John Gough', '2013', 32), ('Christos Panayi', '2019', 33);

insert into public.committee_members (section, role, name, email, mobile, sort_order) values
('executive', 'President',             'Maurice Krenich',   'president.parklea@gmail.com',      '0413 426 494', 1),
('executive', 'Secretary',             'Karin Boulter',     'secretary.parklea@gmail.com',      '0413 615 722', 2),
('executive', 'Vice President',        'Christos Panayi',   'svicepresident.parklea@gmail.com', '0407 077 421', 3),
('executive', 'Junior Vice President', 'Danielle Hancock',  'jvicepresident.parklea@gmail.com', '0414 267 870', 4),
('executive', 'Registrar',             'Lisa Reeves',       'registrar.parklea@gmail.com',      '0402 478 702', 5),
('executive', 'Treasurer',             'Vacant',            'treasurer.parklea@gmail.com',      null,           6),
('management', 'Grassroots Coordinator',       'Danielle Hancock',   'smallsidedfootball.parklea@gmail.com', '0414 267 870', 1),
('management', 'Asst. Grassroots Coordinator', 'Natalie Buccini',    'grassroots.parklea@gmail.com',         '0407 285 485', 2),
('management', 'Equipment Managers',           'Peta & David Imber', 'equipment.parklea@gmail.com',          'TBA',          3),
('management', 'Canteen Manager',              'John McShane',       null,                                   '0416 135 442', 4),
('management', 'Publicity Officer',            'Christos Panayi',    'svicepresident.parklea@gmail.com',     '0407 077 421', 5),
('management', 'MPIO',                         'Matt MacLaren',      'mpio.parklea@gmail.com',               null,           6),
('general', null, 'Thomas Palacios',  null, null, 1),
('general', null, 'Karin Boulter',    null, null, 2),
('general', null, 'Michael Juillerat', null, null, 3),
('general', null, 'Thomas Juillerat', null, null, 4);

insert into public.policies (section, title, url, sort_order) values
('regulations', 'PSFC By-Laws and Regulations (Latest Version)', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/psfc_by_laws___regulations_120618.pdf', 1),
('regulations', 'PSFC Constitution', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/psfc_constitution.pdf', 2),
('policies', 'PSFC Refund Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/refund_policy.pdf', 1),
('policies', 'PSFC Zero Tolerance Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/zero_tolerance_policy.pdf', 2),
('policies', 'FNSW Hot Weather Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/fnsw_hot_weather_policy.pdf', 3),
('policies', 'FNSW Lightning Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/fnsw_lightning_policy.pdf', 4),
('policies', 'FNSW Social Media Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/social_media_policy_fnsw.pdf', 5),
('policies', 'FNSW Pregnant Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/pregnancy-policy.pdf', 6),
('policies', 'FNSW Smoking Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/smoking-policy.pdf', 7),
('policies', 'FNSW Working with Children Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/working-with-children-check-policy-20190504-1.pdf', 8),
('policies', 'FNSW Goalpost Safety Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/goalpost-safety-policy.pdf', 9),
('policies', 'BDSFA Alcohol Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-alcohol.pdf', 10),
('policies', 'BDSFA Concussion Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-concussion.pdf', 11),
('policies', 'BDSFA Injury Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-injury.pdf', 12),
('policies', 'BDSFA Privacy Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-privacy.pdf', 13),
('policies', 'BDSFA Referee Payments Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-referee-payment.pdf', 14),
('policies', 'BDSFA Social Media Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-social-media.pdf', 15),
('policies', 'BDSFA Videos and Images Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy-video-images.pdf', 16),
('policies', 'BDSFA Miniroos Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy_-_miniroos.pdf', 17),
('policies', 'BDSFA Game Leader Policy', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/policy_-_game_leader_copy.pdf', 18),
('guidelines', 'Ground Official Guidelines', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/document_-_ground_official_guidelines_copy.pdf', 1),
('guidelines', 'Match Day Supervisor Guidelines', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/document_-_match_day_supervisor_guidelines.pdf', 2),
('code_of_conduct', 'For Coaches', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_coach.pdf', 1),
('code_of_conduct', 'For Managers', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_manager.pdf', 2),
('code_of_conduct', 'For Players', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_player.pdf', 3),
('code_of_conduct', 'For Parents', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_parent.pdf', 4),
('code_of_conduct', 'For Officials', 'http://www.parkleasfc.com.au/uploads/3/1/0/6/31069323/code_of_behaviour_official.pdf', 5);
