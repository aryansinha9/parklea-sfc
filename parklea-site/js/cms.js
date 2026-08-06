// Public-side CMS renderer.
// Fetches content from Supabase and re-renders the editable sections using
// the exact same markup/classes as the static HTML, so the design never changes.
// If Supabase isn't configured or a fetch fails, the static HTML is left untouched.
import { supabase } from './supabase-client.js';

const esc = (s) => String(s ?? '')
  .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
  .replace(/"/g, '&quot;').replace(/'/g, '&#39;');

// The page's own IntersectionObserver only watches elements present at parse
// time, so injected .reveal elements need their own observer (same settings).
const io = new IntersectionObserver((entries) => {
  entries.forEach(en => { if (en.isIntersecting) { en.target.classList.add('in'); io.unobserve(en.target); } });
}, { threshold: 0.12, rootMargin: '0px 0px -8% 0px' });

// Replace a container's children. If the static content was already revealed
// (user scrolled there before data arrived), show instantly — no re-animation.
function inject(container, html) {
  const alreadyRevealed = !!container.querySelector('.reveal.in');
  container.innerHTML = html;
  container.querySelectorAll('.reveal').forEach(el => {
    if (alreadyRevealed) el.classList.add('in');
    else io.observe(el);
  });
}

// '#' is an inert fallback: only an authenticated admin can set these URLs, and
// every legitimate one passes safeUrl, so this fires on a hostile value alone.
const linkAttrs = (url, newTab) =>
  `href="${esc(safeUrl(url) || '#')}"${newTab ? ' target="_blank" rel="noopener"' : ''}`;

// ---------- Editable page copy ----------
// Elements marked data-cms-text / data-cms-html are filled from the page_content
// table for the page named in <body data-cms-page="…">. Only the copy inside an
// element is ever replaced — never its tag, classes, or position — and the value
// is sanitised down to plain formatting, so an admin can change words but cannot
// change the design. If a page has no saved row, the static HTML stays as-is.

const INLINE_TAGS = new Set(['EM', 'I', 'STRONG', 'B', 'BR', 'A', 'SMALL', 'U']);
const BLOCK_TAGS  = new Set(['P', 'UL', 'OL', 'LI', 'H4', 'H5', 'BLOCKQUOTE']);
const DROP_TAGS   = new Set(['SCRIPT', 'STYLE', 'TEMPLATE', 'IFRAME', 'OBJECT']);

// Links may only point somewhere a browser can safely navigate — never javascript:.
// Anything carrying a scheme other than the four below is rejected; everything
// else is a relative path, which cannot execute script. Bare relative URLs such
// as "payment-plans" and "coming-soon?page=calendar" are real values in the CMS,
// so they have to keep working.
const SAFE_SCHEME = /^(?:https?|mailto|tel):/i;
const ANY_SCHEME = /^[a-z][a-z0-9+.\-]*:/i;
const safeUrl = (url) => {
  // Browsers ignore control characters when resolving a URL, so strip them before
  // testing — otherwise "java\tscript:alert(1)" would slip past as a relative path.
  const u = String(url ?? '').trim().replace(/[\u0000-\u001F\u007F]/g, '');
  if (!u) return null;
  if (ANY_SCHEME.test(u) && !SAFE_SCHEME.test(u)) return null;
  return u;
};

function clean(el, allowBlocks) {
  for (const child of [...el.childNodes]) {
    if (child.nodeType === Node.TEXT_NODE) continue;
    if (child.nodeType !== Node.ELEMENT_NODE) { child.remove(); continue; }
    if (DROP_TAGS.has(child.tagName)) { child.remove(); continue; } // contents and all
    clean(child, allowBlocks); // clean the subtree before deciding on the parent
    if (!INLINE_TAGS.has(child.tagName) && !(allowBlocks && BLOCK_TAGS.has(child.tagName))) {
      child.replaceWith(...child.childNodes); // drop the tag, keep the words
      continue;
    }
    const href = child.tagName === 'A' ? safeUrl(child.getAttribute('href') || '') : null;
    for (const attr of [...child.attributes]) child.removeAttributeNode(attr);
    if (child.tagName === 'A') {
      if (!href) { child.replaceWith(...child.childNodes); continue; } // unusable link → plain text
      child.href = href; child.target = '_blank'; child.rel = 'noopener';
    }
  }
  return el;
}

function toHtml(value, allowBlocks) {
  // Parsed inert (no scripts, no network) before it is cleaned and inserted.
  if (/<[a-z][\s\S]*>/i.test(value)) {
    return clean(new DOMParser().parseFromString(value, 'text/html').body, allowBlocks).innerHTML;
  }
  if (allowBlocks) {
    return value.split(/\n\s*\n/).filter(p => p.trim())
      .map(p => `<p>${esc(p.trim()).replace(/\n/g, '<br>')}</p>`).join('');
  }
  return esc(value).replace(/\n/g, '<br>');
}

async function renderPageCopy() {
  const page = document.body.dataset.cmsPage;
  const nodes = document.querySelectorAll('[data-cms-text], [data-cms-html], [data-cms-href]');
  if (!page || !nodes.length) return;
  const { data, error } = await supabase.from('page_content').select('key, value').eq('page', page);
  if (error || !data?.length) return;
  const saved = new Map(data.map(r => [r.key, r.value]));
  nodes.forEach(el => {
    if (el.dataset.cmsHref) {
      const url = saved.get(el.dataset.cmsHref);
      if (url && safeUrl(url)) el.href = safeUrl(url);
    }
    const isBlock = el.hasAttribute('data-cms-html');
    const key = isBlock ? el.dataset.cmsHtml : el.dataset.cmsText;
    if (!key) return;
    const value = saved.get(key);
    if (value) el.innerHTML = toHtml(value, isBlock);
  });
}

// ---------- Registration page: FAQs ----------
async function renderFaqs(container) {
  const { data, error } = await supabase.from('faqs').select('*').order('sort_order');
  if (error || !data?.length) return;
  inject(container, data.map(f => `
    <div class="faq-item reveal">
      <div class="faq-q">${esc(f.question)}</div>
      <div class="faq-a">${toHtml(f.answer, false)}</div>
    </div>`).join(''));
}

const BADGES = { open: 'Open Now', new: 'New', soon: 'Coming Soon', closed: 'Closed Now' };
const TIERS = { principal: 'Major Partner', major: 'Major Partner', official: 'Official Partner' };
const DELAY = ['', ' d1', ' d2', ' d3'];

// ---------- Homepage: Quick Links ----------
async function renderQuickLinks(container) {
  const { data, error } = await supabase.from('quick_links').select('*').order('sort_order');
  if (error || !data?.length) return;
  inject(container, data.map((q, i) => {
    const badge = q.badge !== 'none' && BADGES[q.badge]
      ? `<span class="ql-badge ${esc(q.badge)}">${BADGES[q.badge]}</span>` : '';
    const body = `
      ${badge}
      <h4>${esc(q.title)}</h4>
      <p>${esc(q.description)}</p>`;
    // A disabled card is a plain div — greyed out, not clickable — with the
    // note (e.g. "Registrations open again next season.") in place of the arrow.
    return q.disabled
      ? `<div class="ql-card is-disabled reveal${DELAY[i % 4]}" role="link" aria-disabled="true">${body}
      ${q.note ? `<span class="ql-note">${esc(q.note)}</span>` : ''}
    </div>`
      : `<a ${linkAttrs(q.url, q.new_tab)} class="ql-card reveal${DELAY[i % 4]}">${body}
      <span class="ql-arrow">→</span>
    </a>`;
  }).join(''));
}

// ---------- Homepage: "Built with great partners" (featured sponsors) ----------
async function renderHomeSponsors(container) {
  const { data, error } = await supabase.from('sponsors').select('*')
    .eq('featured', true).order('sort_order');
  if (error || !data?.length) return;
  const tierRank = { principal: 0, major: 1, official: 2 };
  data.sort((a, b) => (tierRank[a.tier] - tierRank[b.tier]) || (a.sort_order - b.sort_order));
  let alt = 0;
  inject(container, data.map(s => {
    const img = s.logo_url
      ? `<img src="${esc(s.logo_url)}" alt="${esc(s.name)}" class="sponsor-logo-img"${s.logo_height ? ` style="height: ${Number(s.logo_height)}px;"` : ''} />`
      : `<div class="tier" style="font-size:24px; opacity:0.8;">${esc(s.name)}</div>`;
    if (s.tier === 'principal') {
      return `
      <div class="sponsor-card principal reveal">
        ${img}
        <div class="sponsor-info">
          <h5>${esc(s.name)}</h5>
          <p>${esc(s.tagline || TIERS[s.tier])}</p>
        </div>
      </div>`;
    }
    alt += 1;
    return `
      <div class="sponsor-card reveal d${(alt % 2) + 1}">
        ${img}
        <div class="tier">${TIERS[s.tier] || 'Official Partner'}</div>
      </div>`;
  }).join(''));
}

// ---------- Sponsors page: Meet Our Sponsors ----------
async function renderSponsorsPage(container) {
  const { data, error } = await supabase.from('sponsors').select('*').order('sort_order');
  if (error || !data?.length) return;
  inject(container, data.map((s, i) => {
    const inner = s.logo_url
      ? `<img src="${esc(s.logo_url)}" alt="${esc(s.name)}" style="max-height: 70%; max-width: 80%; object-fit: contain;" />`
      : esc(s.name);
    const delay = ['', ' d1', ' d2', ' d3', ' d4'][(i % 5)];
    const cls = `sponsor-placeholder reveal${delay}`;
    // An unusable URL falls back to the existing non-link tile rather than a dead anchor.
    const href = safeUrl(s.website_url);
    return href
      ? `<a href="${esc(href)}" target="_blank" rel="noopener" class="${cls}" style="text-decoration:none; color:inherit;" aria-label="${esc(s.name)}">${inner}</a>`
      : `<div class="${cls}">${inner}</div>`;
  }).join(''));
}

// ---------- Club page: Life Members ----------
async function renderLifeMembers(container) {
  const { data, error } = await supabase.from('life_members').select('*').order('sort_order');
  if (error || !data?.length) return;
  inject(container, data.map(m => `
    <div class="lm-card reveal"><div class="lm-name">${esc(m.name)}</div><div class="lm-year">${esc(m.year)}</div></div>`).join(''));
}

// ---------- Committee page ----------
function committeeDetails(m) {
  const parts = [];
  if (m.email) parts.push(`Email: <a href="mailto:${esc(m.email)}">${esc(m.email)}</a>`);
  if (m.mobile) parts.push(`Mobile: ${esc(m.mobile)}`);
  return parts.join('<br/>');
}

async function renderCommittee(sections) {
  const { data, error } = await supabase.from('committee_members').select('*').order('sort_order');
  if (error || !data?.length) return;
  for (const [section, container] of Object.entries(sections)) {
    const members = data.filter(m => m.section === section);
    if (!members.length) continue;
    if (section === 'general') {
      inject(container, members.map(m => `
        <div class="comm-card reveal" style="padding: 16px;"><div class="name" style="font-size:18px;">${esc(m.name)}</div></div>`).join(''));
    } else {
      inject(container, members.map(m => {
        const vacant = m.name.trim().toLowerCase() === 'vacant';
        return `
        <div class="comm-card reveal">
          <h5>${esc(m.role || '')}</h5>
          <div class="name"${vacant ? ' style="opacity:0.5;"' : ''}>${esc(m.name)}</div>
          ${committeeDetails(m) ? `<div class="details">${committeeDetails(m)}</div>` : ''}
        </div>`;
      }).join(''));
    }
  }
}

// ---------- Policies page ----------
async function renderPolicies(sections) {
  const { data, error } = await supabase.from('policies').select('*').order('sort_order');
  if (error || !data?.length) return;
  for (const [section, container] of Object.entries(sections)) {
    const items = data.filter(p => p.section === section);
    if (!items.length) continue;
    container.innerHTML = items.map(p => {
      // A policy with an unusable URL still lists its title, just not as a link.
      const href = safeUrl(p.url);
      return href
        ? `<li><a href="${esc(href)}" target="_blank" rel="noopener">${esc(p.title)}</a></li>`
        : `<li>${esc(p.title)}</li>`;
    }).join('');
  }
}

// ---------- Committee year: "2026 Committee" tracks the calendar year ----------
function updateCommitteeYear() {
  const el = document.querySelector('[data-cms="committee-year"]');
  if (el) el.textContent = new Date().getFullYear();
}

function grab(name) { return document.querySelector(`[data-cms="${name}"]`); }

updateCommitteeYear(); // runs even without Supabase configured

if (supabase) {
  const jobs = [renderPageCopy()];
  const ql = grab('quick-links');          if (ql) jobs.push(renderQuickLinks(ql));
  const hs = grab('sponsors-home');        if (hs) jobs.push(renderHomeSponsors(hs));
  const sp = grab('sponsors-page');        if (sp) jobs.push(renderSponsorsPage(sp));
  const lm = grab('life-members');         if (lm) jobs.push(renderLifeMembers(lm));
  const fq = grab('faqs');                 if (fq) jobs.push(renderFaqs(fq));

  const committeeSections = {};
  for (const s of ['executive', 'management', 'general']) {
    const el = grab(`committee-${s}`);
    if (el) committeeSections[s] = el;
  }
  if (Object.keys(committeeSections).length) jobs.push(renderCommittee(committeeSections));

  const policySections = {};
  for (const s of ['regulations', 'policies', 'guidelines', 'code_of_conduct']) {
    const el = grab(`policies-${s}`);
    if (el) policySections[s] = el;
  }
  if (Object.keys(policySections).length) jobs.push(renderPolicies(policySections));

  Promise.allSettled(jobs);
}
