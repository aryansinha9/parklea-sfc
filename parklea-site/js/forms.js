// Web3Forms submission handler.
// Wires up every form marked with data-w3f — the contact form, the sponsorship
// enquiry form and the newsletter signup in the footer of every page — so they
// POST to Web3Forms and report a real result instead of faking one.
//
// The access key lives in VITE_WEB3FORMS_KEY (see .env.example). It is a public,
// write-only key by design — Web3Forms only ever emails the inbox the key is
// registered to — so shipping it in the bundle is safe.

const ACCESS_KEY = import.meta.env.VITE_WEB3FORMS_KEY;
const ENDPOINT = 'https://api.web3forms.com/submit';
const FALLBACK_EMAIL = 'parklea@bdsfa.com';

const MESSAGES = {
  sending: 'Sending…',
  ok: 'Thanks — we\'ve got your message. Someone from the committee will be in touch.',
  fail: `Something went wrong sending that. Please try again, or email us at ${FALLBACK_EMAIL}.`,
  unconfigured: `This form isn't connected yet. Please email us at ${FALLBACK_EMAIL}.`,
};

// The big forms wrap their label in a <span> next to the arrow; the footer
// newsletter button is plain text. Either way this is the node to relabel.
const labelNode = (btn) => btn.querySelector('span:not(.btn-arrow)') || btn;

// Forms that opt out of an inline status box (the footer newsletter, which has
// no room for one) report through the button itself instead.
function statusBox(form) {
  if (form.dataset.w3fStatus === 'button') return null;
  let el = form.querySelector('.form-status');
  if (!el) {
    el = document.createElement('div');
    el.className = 'form-status';
    el.setAttribute('role', 'status');
    el.setAttribute('aria-live', 'polite');
    form.appendChild(el);
  }
  return el;
}

function setStatus(form, state, text) {
  const box = statusBox(form);
  if (!box) return;
  box.textContent = text;
  box.className = `form-status${state ? ` is-${state}` : ''}${text ? ' is-shown' : ''}`;
}

function payload(form) {
  const data = Object.fromEntries(new FormData(form).entries());
  data.access_key = ACCESS_KEY;
  data.subject = form.dataset.w3fSubject || 'New enquiry from parkleasfc.com.au';
  data.from_name = form.dataset.w3fFrom || 'Parklea SFC Website';
  // Web3Forms sets the email's Reply-To from this, so replying goes to the sender.
  if (data.email) data.replyto = data.email;
  data.page = window.location.pathname;
  return data;
}

async function submit(form) {
  const btn = form.querySelector('button[type="submit"], button:not([type])');
  const label = btn ? labelNode(btn) : null;
  const original = label ? label.textContent : '';

  if (btn) { btn.disabled = true; label.textContent = MESSAGES.sending; }
  setStatus(form, 'pending', MESSAGES.sending);

  try {
    const res = await fetch(ENDPOINT, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      body: JSON.stringify(payload(form)),
    });
    const body = await res.json().catch(() => ({}));
    if (!res.ok || !body.success) throw new Error(body.message || `HTTP ${res.status}`);

    form.reset();
    setStatus(form, 'ok', form.dataset.w3fSuccess || MESSAGES.ok);
    if (btn) flashButton(btn, label, original, 'Thanks!');
  } catch (err) {
    console.error('[web3forms] submission failed:', err);
    setStatus(form, 'error', MESSAGES.fail);
    if (btn) flashButton(btn, label, original, 'Try again');
  }
}

// Restores the button after a short confirmation beat, matching the original
// design's "Thanks!" flash on the newsletter signup.
function flashButton(btn, label, original, text) {
  label.textContent = text;
  btn.classList.add('is-flashed');
  setTimeout(() => {
    label.textContent = original;
    btn.classList.remove('is-flashed');
    btn.disabled = false;
  }, 3000);
}

document.querySelectorAll('form[data-w3f]').forEach((form) => {
  // Native validation stays in charge; we only take over the network round-trip.
  form.setAttribute('novalidate', '');
  form.addEventListener('submit', (e) => {
    e.preventDefault();
    if (!form.reportValidity()) return;

    // Honeypot: a real person never sees this field, so anything in it is a bot.
    // Report success so the bot moves on without learning it was filtered.
    if (form.elements.botcheck?.checked) {
      form.reset();
      setStatus(form, 'ok', MESSAGES.ok);
      return;
    }

    if (!ACCESS_KEY) {
      console.error('[web3forms] VITE_WEB3FORMS_KEY is not set — forms cannot submit.');
      setStatus(form, 'error', MESSAGES.unconfigured);
      return;
    }

    submit(form);
  });
});
