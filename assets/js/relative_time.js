import { watch } from "./observer.js";
import {
  absolute,
  intl,
  parse,
  resolveLocale,
  targetZone,
  zoneParts,
} from "./time_format.js";

const UNITS = [
  ["year", 365 * 86400],
  ["month", 30 * 86400],
  ["week", 7 * 86400],
  ["day", 86400],
  ["hour", 3600],
  ["minute", 60],
];

const DAY_UNITS = [
  ["year", 365],
  ["month", 30],
  ["week", 7],
  ["day", 1],
];

const LIVE_REGION =
  '[aria-live]:not([aria-live="off"]), [role="log"], [role="status"], ' +
  '[role="alert"], [role="timer"], [role="marquee"]';

const fallbacks = new WeakMap();
const written = new WeakMap();
const skews = new WeakMap();
const due = new Map();
const roots = new Set();
let timer = null;
let arming = false;

const relativeFormatter = (locale, options) =>
  intl(Intl.RelativeTimeFormat, locale, options);

// The server's time in `data-relative-now` corrects the browser's clock; the
// difference is measured once, when the element is first seen.
function now(el) {
  if (!skews.has(el)) {
    const server = Date.parse(el.dataset.relativeNow || "");
    skews.set(el, Number.isNaN(server) ? 0 : server - Date.now());
  }
  return Date.now() + skews.get(el);
}

function clamp(seconds, tense) {
  if (tense === "past" && seconds > 0 && seconds < 60) return 0;
  if (tense === "future" && seconds < 0 && seconds > -60) return 0;
  return seconds;
}

// Whole days between today and the date in the zone, and the time left until
// the next midnight there.
function calendarDays(date, timeZone, nowMs) {
  const parts = Object.fromEntries(
    Object.entries(zoneParts(new Date(nowMs), timeZone)).map(
      ([type, value]) => [type, Number(value)],
    ),
  );

  const today = Date.UTC(parts.year, parts.month - 1, parts.day);
  const elapsed = parts.hour * 3600 + parts.minute * 60 + parts.second;

  return {
    days: Math.round((date.getTime() - today) / 86400000),
    next: (86400 - elapsed) * 1000,
  };
}

function relative(el, parsed, nowMs) {
  const locale = resolveLocale(el);
  const style = el.dataset.relativeFormat || "long";
  const numeric = el.dataset.relativeNumeric || "auto";
  const rtf = relativeFormatter(locale, { style, numeric });

  if (el.dataset.relative === "date") {
    const { days, next } = calendarDays(parsed.date, targetZone(el), nowMs);
    const [unit, size] = DAY_UNITS.find(
      ([, unitSize]) => Math.abs(days) >= unitSize || unitSize === 1,
    );

    return {
      text: rtf.format(Math.trunc(days / size), unit),
      seconds: Math.abs(days) * 86400,
      next,
    };
  }

  const seconds = clamp(
    (parsed.date.getTime() - nowMs) / 1000,
    el.dataset.relativeTense,
  );
  const abs = Math.abs(seconds);

  if (abs < 60) {
    return {
      text: relativeFormatter(locale, { style, numeric: "auto" }).format(
        0,
        "second",
      ),
      seconds: abs,
      next: (60 - abs) * 1000,
    };
  }

  const [unit, size] = UNITS.find(([, unitSize]) => abs >= unitSize);
  const value = Math.trunc(seconds / size);

  return {
    text: rtf.format(value, unit),
    seconds: abs,
    next: (size - (abs % size)) * 1000,
  };
}

function absoluteOrFallback(el) {
  if (el.hasAttribute("data-localize")) {
    try {
      const result = absolute(el, el.dataset.localize);
      if (result) {
        return { text: result.text, title: result.title || result.text };
      }
    } catch {
      // An unknown zone or option falls back to the server text.
    }
  }

  const text = fallbacks.get(el);
  return { text, title: text };
}

function synced(el) {
  return (
    el.dataset.relativeSync === "true" &&
    !el.closest('[data-relative-sync="false"]') &&
    !el.parentElement?.closest(LIVE_REGION)
  );
}

function write(el, text, title) {
  if (text && el.textContent.trim() !== text) el.textContent = text;
  if (title && el.title !== title) el.title = title;
  written.set(el, text);
}

function updateRelative(el, { print = false } = {}) {
  // Text the client did not write is new server text, such as after a
  // patch, and becomes the absolute fallback.
  const current = el.textContent.trim();
  if (current !== written.get(el)) fallbacks.set(el, current);

  const parsed = parse(el.getAttribute("datetime") || "");
  if (!parsed) return;

  try {
    const abs = absoluteOrFallback(el);
    const threshold = Number(el.dataset.relativeThreshold);

    if (print) {
      write(el, abs.text, abs.title);
      return;
    }

    const rel = relative(el, parsed, now(el));

    if (el.dataset.relativeThreshold && rel.seconds > threshold) {
      write(el, abs.text, abs.title);
      due.delete(el);
      return;
    }

    write(el, rel.text, abs.title);
    schedule(el, synced(el) ? rel.next : null);
  } catch {
    // Without Intl.RelativeTimeFormat or with an unknown zone, the server
    // text stays.
  }
}

function schedule(el, delay) {
  if (delay === null) {
    due.delete(el);
  } else {
    due.set(el, Date.now() + Math.max(delay, 1000));
  }

  // Many elements are scheduled in one pass, so the timer is set once after
  // it.
  if (!arming) {
    arming = true;
    queueMicrotask(() => {
      arming = false;
      arm();
    });
  }
}

function arm() {
  clearTimeout(timer);
  timer = null;
  if (document.hidden || due.size === 0) return;

  const next = Math.min(...due.values());
  timer = setTimeout(tick, Math.max(next - Date.now(), 0));
}

function selected(el) {
  const selection = window.getSelection?.();
  return (
    selection && !selection.isCollapsed && selection.containsNode(el, true)
  );
}

function tick() {
  const nowMs = Date.now();

  for (const [el, at] of due) {
    if (!el.isConnected) {
      due.delete(el);
    } else if (at <= nowMs) {
      // A selection over the text is left alone until it ends.
      if (selected(el)) {
        due.set(el, nowMs + 1000);
      } else {
        updateRelative(el);
      }
    }
  }

  arm();
}

function each(callback) {
  for (const root of roots) {
    root.querySelectorAll?.("[data-relative]").forEach(callback);
  }
}

let listening = false;

function listen() {
  if (listening) return;
  listening = true;

  const refreshAll = () => {
    if (!document.hidden) each((el) => updateRelative(el));
    arm();
  };

  document.addEventListener("visibilitychange", refreshAll);
  window.addEventListener("pageshow", refreshAll);
  window.addEventListener("beforeprint", () =>
    each((el) => updateRelative(el, { print: true })),
  );
  window.addEventListener("afterprint", () => each((el) => updateRelative(el)));
}

const watcher = {
  selector: "[data-relative]",
  update: updateRelative,
  written,
};

export function relativeTimes(root = document) {
  roots.add(root);
  listen();
  watch(root, watcher);
}
