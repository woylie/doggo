const STYLE_KEYS = {
  date: ["dateStyle"],
  time: ["timeStyle"],
  datetime: ["dateStyle", "timeStyle"],
};

const RESERVED = [
  "localize",
  "localizeStyle",
  "localizePattern",
  "localizeZone",
  "localizeTitle",
];

const CLOCK = ["hourCycle", "hour12"];

const formats = new Map();

// Intl objects are expensive to build, so each one is built once per locale
// and options.
export function intl(Constructor, locale, options) {
  const key = JSON.stringify([Constructor.name, locale, options]);
  if (!formats.has(key)) formats.set(key, new Constructor(locale, options));
  return formats.get(key);
}

const formatter = (locale, options) =>
  intl(Intl.DateTimeFormat, locale, options);

// The numeric parts of an instant in a zone, from the year to the second, and
// the offset.
export function zoneParts(date, timeZone) {
  return Object.fromEntries(
    formatter("en-US", {
      timeZone,
      year: "numeric",
      month: "2-digit",
      day: "2-digit",
      hour: "2-digit",
      minute: "2-digit",
      second: "2-digit",
      hourCycle: "h23",
      timeZoneName: "longOffset",
    })
      .formatToParts(date)
      .map(({ type, value }) => [type, value]),
  );
}

function language(tag) {
  try {
    return new Intl.Locale(tag).language;
  } catch {
    return undefined;
  }
}

// A page `lang` that names only a language (`en`) leaves the regional
// conventions to the browser's default locale when the languages match, since
// that locale includes the region the user chose in the OS, if the browser
// passes it on.
const locales = new Map();
let browserLanguage;

function localeFor(lang) {
  browserLanguage ??= language(
    new Intl.DateTimeFormat().resolvedOptions().locale,
  );

  if (!lang.includes("-") && language(lang) === browserLanguage) {
    return undefined;
  }

  for (const candidate of [lang, ...(navigator.languages || [])]) {
    try {
      return Intl.DateTimeFormat.supportedLocalesOf(candidate)[0] || candidate;
    } catch {
      // A tag that Intl rejects falls through to the next one.
    }
  }

  return undefined;
}

export function resolveLocale(el) {
  const lang = el.closest("[lang]")?.getAttribute("lang");
  if (!lang) return undefined;

  if (!locales.has(lang)) locales.set(lang, localeFor(lang));
  return locales.get(lang);
}

// Returns the instant and whether it is floating. A floating value (a date, a
// time of day, a date and time without offset) is formatted in UTC from its
// own fields, so that no zone shifts it.
export function parse(value) {
  let match = value.match(/^(\d{4,})-(\d\d)-(\d\d)$/);
  if (match) {
    const [, y, m, d] = match.map(Number);
    return { date: new Date(Date.UTC(y, m - 1, d)), floating: true };
  }

  match = value.match(/^(\d\d):(\d\d)(?::(\d\d)(?:\.(\d{1,3}))?)?$/);
  if (match) {
    const [, h, min, s = 0, ms = 0] = match.map((part) => Number(part || 0));
    return {
      date: new Date(Date.UTC(1970, 0, 1, h, min, s, ms)),
      floating: true,
    };
  }

  match = value.match(/^(\d{4,}-\d\d-\d\dT[\d:.]+)(Z|[+-]\d\d:\d\d)?$/);
  if (match) {
    const [, local, offset] = match;
    const date = new Date(offset ? value : `${local}Z`);
    if (Number.isNaN(date.getTime())) return null;
    return { date, floating: !offset, offset };
  }

  return null;
}

// The zone to format in: `undefined` for the viewer's, the server's zone or
// the value's offset for `server`, or a zone name.
export function targetZone(el, offset) {
  const zone = el.dataset.localizeZone;
  if (!zone || zone === "viewer") return undefined;
  if (zone !== "server") return zone;
  if (el.dataset.timezone) return el.dataset.timezone;
  return offset && offset !== "Z" ? offset : "UTC";
}

function resolveZone(el, parsed) {
  return parsed.floating ? "UTC" : targetZone(el, parsed.offset);
}

function optionValue(value) {
  if (value === "true") return true;
  if (value === "false") return false;
  if (/^\d+$/.test(value)) return Number(value);
  return value;
}

function styles(kind, style) {
  return Object.fromEntries(STYLE_KEYS[kind].map((key) => [key, style]));
}

function parts(el) {
  return Object.entries(el.dataset)
    .filter(([key]) => key.startsWith("localize") && !RESERVED.includes(key))
    .map(([key, value]) => [
      key.charAt(8).toLowerCase() + key.slice(9),
      optionValue(value),
    ]);
}

const clockParts = (el) =>
  Object.fromEntries(parts(el).filter(([key]) => CLOCK.includes(key)));

function options(el, kind) {
  const style = el.dataset.localizeStyle;
  const all = parts(el);

  // A style combines only with the clock options; the server allows no other.
  if (style || all.every(([key]) => CLOCK.includes(key))) {
    return { ...styles(kind, style || "medium"), ...Object.fromEntries(all) };
  }
  return Object.fromEntries(all);
}

function titleOptions(el, kind, style) {
  return { ...styles(kind, style), ...clockParts(el) };
}

// A floating value has no zone, so its text must not name one: the time
// styles that print the zone name fall back to `medium`.
function withoutZoneName(options) {
  const result = { ...options };
  delete result.timeZoneName;
  if (["long", "full"].includes(result.timeStyle)) result.timeStyle = "medium";
  return result;
}

// The numeric strftime directives, from the parts of the instant in the
// target zone. Name directives are left out, since Calendar.strftime/2 would
// write them in English on the server.
function formatPattern(pattern, date, timeZone, floating) {
  const parts = zoneParts(date, timeZone);

  const hour = Number(parts.hour);
  const offset = (parts.timeZoneName || "").replace(/^GMT/, "");
  const directives = {
    Y: parts.year,
    y: parts.year.slice(-2),
    m: parts.month,
    d: parts.day,
    H: parts.hour,
    I: String(hour % 12 || 12).padStart(2, "0"),
    M: parts.minute,
    S: parts.second,
    p: hour < 12 ? "AM" : "PM",
    z: floating ? "" : offset ? offset.replace(":", "") : "+0000",
    "%": "%",
  };

  return pattern.replace(/%(.)/g, (whole, directive) =>
    directive in directives ? directives[directive] : whole,
  );
}

// The absolute text and title of an element in the user's format, or null
// if its value cannot be read. Throws for an unknown zone or option.
export function absolute(el, kind) {
  const parsed = parse(el.getAttribute("datetime") || "");
  if (!parsed || !STYLE_KEYS[kind]) return null;

  const timeZone = resolveZone(el, parsed);
  const pattern = el.dataset.localizePattern;
  const locale = resolveLocale(el);

  const format = (shapePattern, shapeOptions) =>
    shapePattern
      ? formatPattern(shapePattern, parsed.date, timeZone, parsed.floating)
      : formatter(locale, {
          ...(parsed.floating ? withoutZoneName(shapeOptions) : shapeOptions),
          timeZone,
        }).format(parsed.date);

  // A title is a style or a pattern; a pattern has a `%`.
  const title = el.dataset.localizeTitle;

  return {
    text: format(pattern, options(el, kind)),
    title:
      title &&
      (title.includes("%")
        ? format(title)
        : format(null, titleOptions(el, kind, title))),
  };
}
