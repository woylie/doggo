import { describe, expect, it } from "vitest";
import { localizeTimes } from "../js/localize.js";
import { render } from "./dom.js";

const flush = () => new Promise((resolve) => setTimeout(resolve, 0));

const intl = (locale, options, date) =>
  new Intl.DateTimeFormat(locale, options).format(new Date(date));

describe("localizeTimes", () => {
  describe("with a page language", () => {
    const render24 = (lang) =>
      render(`
        <time lang="${lang}" datetime="18:30:00" data-localize="time"
          data-localize-style="short">x</time>
      `);

    it("uses the browser locale if only the language is given and matches", () => {
      const browser = new Intl.DateTimeFormat().resolvedOptions().locale;
      const el = render24(new Intl.Locale(browser).language);

      localizeTimes(el);

      expect(el.textContent).toBe(
        intl(
          undefined,
          { timeStyle: "short", timeZone: "UTC" },
          "1970-01-01T18:30:00Z",
        ),
      );
    });

    it("uses the page locale if it names a region", () => {
      const el = render24("en-GB");

      localizeTimes(el);

      expect(el.textContent).toBe(
        intl(
          "en-GB",
          { timeStyle: "short", timeZone: "UTC" },
          "1970-01-01T18:30:00Z",
        ),
      );
    });

    it("uses the page locale if the language differs", () => {
      const el = render24("ja");

      localizeTimes(el);

      expect(el.textContent).toBe(
        intl(
          "ja",
          { timeStyle: "short", timeZone: "UTC" },
          "1970-01-01T18:30:00Z",
        ),
      );
    });
  });

  it("formats a style with an hour cycle", () => {
    const el = render(`
      <time lang="en-US" datetime="18:30:00" data-localize="time"
        data-localize-style="short" data-localize-hour-cycle="h23">x</time>
    `);

    localizeTimes(el);

    expect(el.textContent).toBe(
      intl(
        "en-US",
        { timeStyle: "short", hourCycle: "h23", timeZone: "UTC" },
        "1970-01-01T18:30:00Z",
      ),
    );
  });

  it("formats a style in the server zone", () => {
    const el = render(`
      <time lang="en-GB" datetime="2023-12-27T18:30:21Z" data-localize="datetime"
        data-localize-style="long" data-localize-zone="server"
        data-timezone="Asia/Tokyo">2023-12-27 18:30:21Z</time>
    `);

    localizeTimes(el);

    expect(el.textContent).toBe(
      intl(
        "en-GB",
        { dateStyle: "long", timeStyle: "long", timeZone: "Asia/Tokyo" },
        "2023-12-27T18:30:21Z",
      ),
    );
  });

  it("formats options in a named zone", () => {
    const el = render(`
      <time lang="de" datetime="2023-12-27T18:30:21Z" data-localize="date"
        data-localize-weekday="short" data-localize-day="numeric"
        data-localize-month="long" data-localize-zone="Asia/Tokyo">x</time>
    `);

    localizeTimes(el);

    expect(el.textContent).toBe(
      intl(
        "de",
        {
          weekday: "short",
          day: "numeric",
          month: "long",
          timeZone: "Asia/Tokyo",
        },
        "2023-12-27T18:30:21Z",
      ),
    );
  });

  it("formats a pattern in the zone", () => {
    const el = render(`
      <time datetime="2023-12-27T18:30:21Z" data-localize="datetime"
        data-localize-pattern="%Y-%m-%d %H:%M %z" data-localize-zone="Asia/Tokyo">x</time>
    `);

    localizeTimes(el);

    expect(el.textContent).toBe("2023-12-28 03:30 +0900");
  });

  it("formats a 12-hour pattern", () => {
    const el = render(`
      <time datetime="18:05:00" data-localize="time"
        data-localize-pattern="%I:%M %p">x</time>
    `);

    localizeTimes(el);

    expect(el.textContent).toBe("06:05 PM");
  });

  it("does not shift a floating value", () => {
    const el = render(`
      <time lang="en-US" datetime="2023-12-27" data-localize="date"
        data-localize-zone="Pacific/Kiritimati">x</time>
    `);

    localizeTimes(el);

    expect(el.textContent).toBe(
      intl("en-US", { dateStyle: "medium", timeZone: "UTC" }, "2023-12-27"),
    );
  });

  it("leaves the zone name out for a floating value", () => {
    const el = render(`
      <time lang="en-US" datetime="18:30:21" data-localize="time"
        data-localize-style="full">x</time>
    `);

    localizeTimes(el);

    expect(el.textContent).toBe(
      intl(
        "en-US",
        { timeStyle: "medium", timeZone: "UTC" },
        "1970-01-01T18:30:21Z",
      ),
    );
  });

  it("writes the title style", () => {
    const el = render(`
      <time lang="en-US" datetime="2023-12-27T18:30:21Z" data-localize="datetime"
        data-localize-style="short" data-localize-zone="UTC"
        data-localize-title="full" title="server">x</time>
    `);

    localizeTimes(el);

    expect(el.getAttribute("title")).toBe(
      intl(
        "en-US",
        { dateStyle: "full", timeStyle: "full", timeZone: "UTC" },
        "2023-12-27T18:30:21Z",
      ),
    );
  });

  it("writes the title pattern", () => {
    const el = render(`
      <time datetime="2023-12-27T18:30:21Z" data-localize="datetime"
        data-localize-style="short" data-localize-zone="Asia/Tokyo"
        data-localize-title="%Y-%m-%d %H:%M" title="server">x</time>
    `);

    localizeTimes(el);

    expect(el.getAttribute("title")).toBe("2023-12-28 03:30");
  });

  it("leaves the title without a title shape", () => {
    const el = render(`
      <time lang="en-US" datetime="2023-12-27T18:30:21Z" data-localize="datetime"
        data-localize-style="short" title="server">x</time>
    `);

    localizeTimes(el);

    expect(el.getAttribute("title")).toBe("server");
  });

  it("leaves the server text for an unknown zone", () => {
    const el = render(`
      <time datetime="2023-12-27T18:30:21Z" data-localize="datetime"
        data-localize-zone="Mars/Olympus">server</time>
    `);

    localizeTimes(el);

    expect(el.textContent).toBe("server");
  });

  it("leaves the server text without a datetime attribute", () => {
    const el = render(`<time data-localize="date">server</time>`);

    localizeTimes(el);

    expect(el.textContent).toBe("server");
  });

  describe("after a patch", () => {
    it("formats restored server text again", async () => {
      const el = render(`
        <div><time datetime="2023-12-27T18:30:21Z" data-localize="datetime"
          data-localize-pattern="%H:%M" data-localize-zone="UTC">server</time></div>
      `);

      localizeTimes(el);
      const time = el.querySelector("time");
      expect(time.textContent).toBe("18:30");

      time.textContent = "server";
      await flush();

      expect(time.textContent).toBe("18:30");
    });

    it("formats an added element", async () => {
      const el = render(`<div></div>`);

      localizeTimes(el);
      el.insertAdjacentHTML(
        "beforeend",
        `<time datetime="2023-12-27T18:30:21Z" data-localize="datetime"
          data-localize-pattern="%H:%M" data-localize-zone="UTC">server</time>`,
      );
      await flush();

      expect(el.querySelector("time").textContent).toBe("18:30");
    });

    it("formats again when the datetime changes", async () => {
      const el = render(`
        <div><time datetime="2023-12-27T18:30:21Z" data-localize="datetime"
          data-localize-pattern="%H:%M" data-localize-zone="UTC">server</time></div>
      `);

      localizeTimes(el);
      el.querySelector("time").setAttribute("datetime", "2023-12-27T09:15:00Z");
      await flush();

      expect(el.querySelector("time").textContent).toBe("09:15");
    });
  });
});
