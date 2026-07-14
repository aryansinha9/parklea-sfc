// Parklea SFC — Admin dashboard.
// Email/password auth via Supabase; CRUD for all CMS content.
import { supabase } from './supabase-client.js';

const $ = (sel, root = document) => root.querySelector(sel);

const views = {
  unconfigured: $('#viewUnconfigured'),
  login: $('#viewLogin'),
  dashboard: $('#viewDashboard'),
};

function showView(name) {
  Object.entries(views).forEach(([k, el]) => { el.hidden = k !== name; });
}

let toastTimer;
function toast(msg, isError = false) {
  const el = $('#toast');
  el.textContent = msg;
  el.classList.toggle('error', isError);
  el.hidden = false;
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => { el.hidden = true; }, 3200);
}

// ============================================================
// Tab / field configuration
// ============================================================

const BADGE_OPTIONS = [
  { value: 'none', label: 'No badge' },
  { value: 'open', label: 'Open Now' },
  { value: 'new', label: 'New' },
  { value: 'soon', label: 'Coming Soon' },
];

const TABS = {
  quick_links: {
    title: 'Quick Links',
    hint: 'Cards in the “Quick Links” section on the homepage. The grid reflows automatically.',
    groups: [{
      table: 'quick_links',
      addLabel: '+ Add Quick Link',
      fields: [
        { key: 'title', label: 'Title', type: 'text', required: true },
        { key: 'url', label: 'Destination URL', type: 'text', required: true },
        { key: 'description', label: 'Description', type: 'textarea', full: true },
        { key: 'badge', label: 'Badge', type: 'select', options: BADGE_OPTIONS, default: 'none' },
        { key: 'new_tab', label: 'Open in new tab', type: 'checkbox', default: true },
      ],
    }],
  },
  sponsors: {
    title: 'Sponsors',
    hint: 'One source of truth: “Featured on homepage” controls the homepage “Built with great partners” section; every sponsor appears in “Meet Our Sponsors” on the Sponsors page.',
    groups: [{
      table: 'sponsors',
      addLabel: '+ Add Sponsor',
      fields: [
        { key: 'name', label: 'Sponsor name', type: 'text', required: true },
        { key: 'website_url', label: 'Website URL', type: 'text' },
        { key: 'logo_url', label: 'Logo', type: 'image', full: true },
        { key: 'tier', label: 'Tier', type: 'select', default: 'official', options: [
          { value: 'principal', label: 'Principal Partner (large homepage card)' },
          { value: 'major', label: 'Major Partner' },
          { value: 'official', label: 'Official Partner' },
        ] },
        { key: 'featured', label: 'Featured on homepage', type: 'checkbox', default: false },
        { key: 'tagline', label: 'Tagline (principal card only)', type: 'text' },
        { key: 'logo_height', label: 'Logo height px (optional)', type: 'number' },
      ],
    }],
  },
  life_members: {
    title: 'Life Members',
    hint: 'Shown in the “Life Members” section on the Our Identity page.',
    groups: [{
      table: 'life_members',
      addLabel: '+ Add Life Member',
      fields: [
        { key: 'name', label: 'Name', type: 'text', required: true },
        { key: 'year', label: 'Year (or e.g. “Founder”)', type: 'text' },
      ],
    }],
  },
  committee: {
    title: 'Committee',
    hint: 'The page heading year updates automatically each calendar year.',
    groups: [
      {
        table: 'committee_members', heading: 'Executive Committee',
        match: { section: 'executive' }, addLabel: '+ Add Executive Member',
        fields: [
          { key: 'role', label: 'Position / Role', type: 'text', required: true },
          { key: 'name', label: 'Name (use “Vacant” for open roles)', type: 'text', required: true },
          { key: 'email', label: 'Email', type: 'text' },
          { key: 'mobile', label: 'Mobile', type: 'text' },
        ],
      },
      {
        table: 'committee_members', heading: 'Management Committee',
        match: { section: 'management' }, addLabel: '+ Add Management Member',
        fields: [
          { key: 'role', label: 'Position / Role', type: 'text', required: true },
          { key: 'name', label: 'Name', type: 'text', required: true },
          { key: 'email', label: 'Email', type: 'text' },
          { key: 'mobile', label: 'Mobile', type: 'text' },
        ],
      },
      {
        table: 'committee_members', heading: 'General Committee',
        match: { section: 'general' }, addLabel: '+ Add General Member',
        fields: [
          { key: 'name', label: 'Name', type: 'text', required: true },
        ],
      },
    ],
  },
  policies: {
    title: 'Policies & Regulations',
    hint: 'Links on the Policies & Guidelines page, grouped by section.',
    groups: ['regulations', 'policies', 'guidelines', 'code_of_conduct'].map((section, i) => ({
      table: 'policies',
      heading: ['Regulations', 'Policies', 'Guidelines', 'Code of Conduct'][i],
      match: { section },
      addLabel: '+ Add Link',
      fields: [
        { key: 'title', label: 'Title', type: 'text', required: true },
        { key: 'url', label: 'URL / file link', type: 'text', required: true },
      ],
    })),
  },
};

// ============================================================
// Auth
// ============================================================

async function init() {
  if (!supabase) { showView('unconfigured'); return; }

  const { data: { session } } = await supabase.auth.getSession();
  if (session) enterDashboard(); else showView('login');

  supabase.auth.onAuthStateChange((_event, s) => {
    if (s) enterDashboard(); else showView('login');
  });

  $('#loginForm').addEventListener('submit', async (e) => {
    e.preventDefault();
    const btn = $('#loginBtn');
    const errEl = $('#loginError');
    errEl.hidden = true;
    btn.disabled = true;
    btn.textContent = 'Signing in…';
    const { error } = await supabase.auth.signInWithPassword({
      email: $('#loginEmail').value.trim(),
      password: $('#loginPassword').value,
    });
    btn.disabled = false;
    btn.textContent = 'Sign In';
    if (error) {
      errEl.textContent = error.message === 'Invalid login credentials'
        ? 'Incorrect email or password.' : error.message;
      errEl.hidden = false;
    }
  });

  $('#signOutBtn').addEventListener('click', () => supabase.auth.signOut());

  $('#adminNav').addEventListener('click', (e) => {
    const btn = e.target.closest('button[data-tab]');
    if (!btn) return;
    $('#adminNav .active')?.classList.remove('active');
    btn.classList.add('active');
    loadTab(btn.dataset.tab);
  });
}

let dashboardStarted = false;
function enterDashboard() {
  showView('dashboard');
  if (!dashboardStarted) {
    dashboardStarted = true;
    loadTab('quick_links');
  }
}

// ============================================================
// Tab rendering
// ============================================================

let currentTab = null;

async function loadTab(key) {
  currentTab = key;
  const tab = TABS[key];
  $('#tabTitle').textContent = tab.title;
  $('#tabHint').textContent = tab.hint;
  const root = $('#tabContent');
  root.innerHTML = '<div class="admin-loading">Loading…</div>';

  // All groups of a tab share one table; fetch once.
  const table = tab.groups[0].table;
  const { data, error } = await supabase.from(table).select('*').order('sort_order');
  if (currentTab !== key) return; // user switched tabs mid-fetch
  if (error) {
    root.innerHTML = `<div class="admin-empty">Couldn’t load content: ${error.message}</div>`;
    return;
  }

  root.innerHTML = '';
  for (const group of tab.groups) {
    const rows = group.match
      ? data.filter(r => Object.entries(group.match).every(([k, v]) => r[k] === v))
      : data;

    if (group.heading) {
      const h = document.createElement('h3');
      h.className = 'admin-section-title';
      h.textContent = group.heading;
      root.appendChild(h);
    }

    const list = document.createElement('div');
    root.appendChild(list);
    if (!rows.length) {
      const empty = document.createElement('div');
      empty.className = 'admin-empty';
      empty.textContent = 'Nothing here yet.';
      list.appendChild(empty);
    }
    rows.forEach((row, i) => list.appendChild(itemCard(tab, group, row, rows, i)));

    const addBtn = document.createElement('button');
    addBtn.className = 'admin-btn';
    addBtn.textContent = group.addLabel;
    addBtn.style.marginBottom = '10px';
    addBtn.addEventListener('click', () => {
      const maxOrder = rows.reduce((m, r) => Math.max(m, r.sort_order || 0), 0);
      const blank = { sort_order: maxOrder + 1, ...(group.match || {}) };
      for (const f of group.fields) if (f.default !== undefined) blank[f.key] = f.default;
      const card = itemCard(tab, group, blank, rows, rows.length);
      card.classList.add('unsaved');
      list.appendChild(card);
      card.querySelector('input, textarea, select')?.focus();
      card.scrollIntoView({ behavior: 'smooth', block: 'center' });
    });
    root.appendChild(addBtn);
  }
}

function fieldControl(f, value) {
  const wrap = document.createElement('div');
  wrap.className = `field${f.type === 'checkbox' ? ' checkbox' : ''}${f.full ? ' full' : ''}`;
  const id = `f_${f.key}_${Math.random().toString(36).slice(2, 8)}`;

  const label = document.createElement('label');
  label.htmlFor = id;
  label.textContent = f.label;

  let input;
  if (f.type === 'textarea') {
    input = document.createElement('textarea');
    input.value = value ?? '';
  } else if (f.type === 'select') {
    input = document.createElement('select');
    for (const o of f.options) {
      const opt = document.createElement('option');
      opt.value = o.value; opt.textContent = o.label;
      input.appendChild(opt);
    }
    input.value = value ?? f.default ?? f.options[0].value;
  } else if (f.type === 'checkbox') {
    input = document.createElement('input');
    input.type = 'checkbox';
    input.checked = !!value;
  } else if (f.type === 'image') {
    return imageControl(f, value, wrap, label);
  } else {
    input = document.createElement('input');
    input.type = f.type === 'number' ? 'number' : 'text';
    input.value = value ?? '';
  }
  input.id = id;
  input.dataset.field = f.key;

  if (f.type === 'checkbox') { wrap.append(input, label); }
  else { wrap.append(label, input); }
  return wrap;
}

function imageControl(f, value, wrap, label) {
  const preview = document.createElement('img');
  preview.className = `logo-preview${value ? '' : ' empty'}`;
  if (value) preview.src = value;

  const hidden = document.createElement('input');
  hidden.type = 'hidden';
  hidden.dataset.field = f.key;
  hidden.value = value ?? '';

  const file = document.createElement('input');
  file.type = 'file';
  file.accept = 'image/*';
  file.addEventListener('change', async () => {
    const chosen = file.files?.[0];
    if (!chosen) return;
    toast('Uploading logo…');
    const safeName = chosen.name.replace(/[^a-zA-Z0-9.\-_]/g, '_');
    const path = `${Date.now()}-${safeName}`;
    const { error } = await supabase.storage.from('sponsor-logos').upload(path, chosen, { upsert: false });
    if (error) { toast(`Upload failed: ${error.message}`, true); return; }
    const { data } = supabase.storage.from('sponsor-logos').getPublicUrl(path);
    hidden.value = data.publicUrl;
    preview.src = data.publicUrl;
    preview.classList.remove('empty');
    hidden.dispatchEvent(new Event('input', { bubbles: true }));
    toast('Logo uploaded — remember to Save.');
  });

  wrap.append(label, preview, hidden, file);
  return wrap;
}

function itemCard(tab, group, row, rows, index) {
  const card = document.createElement('div');
  card.className = 'item-card';

  const grid = document.createElement('div');
  grid.className = 'item-grid';
  for (const f of group.fields) grid.appendChild(fieldControl(f, row[f.key]));
  card.appendChild(grid);

  card.addEventListener('input', () => card.classList.add('unsaved'));

  const actions = document.createElement('div');
  actions.className = 'item-actions';

  const up = document.createElement('button');
  up.className = 'icon-btn'; up.textContent = '↑'; up.title = 'Move up';
  up.disabled = !row.id || index === 0;
  const down = document.createElement('button');
  down.className = 'icon-btn'; down.textContent = '↓'; down.title = 'Move down';
  down.disabled = !row.id || index === rows.length - 1;
  up.addEventListener('click', () => swapOrder(group.table, row, rows[index - 1]));
  down.addEventListener('click', () => swapOrder(group.table, row, rows[index + 1]));

  const del = document.createElement('button');
  del.className = 'icon-btn danger'; del.textContent = 'Delete';
  del.addEventListener('click', async () => {
    if (!row.id) { card.remove(); return; }
    if (!confirm('Delete this item? This updates the live website immediately.')) return;
    const { error } = await supabase.from(group.table).delete().eq('id', row.id);
    if (error) { toast(`Delete failed: ${error.message}`, true); return; }
    toast('Deleted.');
    loadTab(currentTab);
  });

  const save = document.createElement('button');
  save.className = 'icon-btn'; save.textContent = 'Save';
  save.style.fontWeight = '700';
  save.addEventListener('click', async () => {
    const payload = { ...(group.match || {}), sort_order: row.sort_order || 0 };
    for (const f of group.fields) {
      const input = card.querySelector(`[data-field="${f.key}"]`);
      let v = f.type === 'checkbox' ? input.checked : input.value.trim();
      if (f.type === 'number') v = v === '' ? null : Number(v);
      if (f.required && !v) { toast(`“${f.label}” is required.`, true); input.focus(); return; }
      payload[f.key] = v;
    }
    save.disabled = true;
    const q = row.id
      ? supabase.from(group.table).update(payload).eq('id', row.id)
      : supabase.from(group.table).insert(payload);
    const { error } = await q;
    save.disabled = false;
    if (error) { toast(`Save failed: ${error.message}`, true); return; }
    toast('Saved — live website updated.');
    loadTab(currentTab);
  });

  actions.append(up, down);
  const spacer = document.createElement('div');
  spacer.className = 'spacer';
  actions.append(spacer, del, save);
  card.appendChild(actions);
  return card;
}

async function swapOrder(table, a, b) {
  if (!a?.id || !b?.id) return;
  let aNew = b.sort_order, bNew = a.sort_order;
  if (aNew === bNew) bNew = aNew + 1; // break ties so the swap is visible
  const [ra, rb] = await Promise.all([
    supabase.from(table).update({ sort_order: aNew }).eq('id', a.id),
    supabase.from(table).update({ sort_order: bNew }).eq('id', b.id),
  ]);
  if (ra.error || rb.error) { toast('Reorder failed.', true); return; }
  loadTab(currentTab);
}

init();
