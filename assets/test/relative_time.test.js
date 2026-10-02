import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { relativeTimes } from "../js/relative_time.js";
import { render } from "./dom.js";

const NOW = new Date("2026-09-30T12:00:00Z");

const relative = (attrs, text = "server") =>
  render(`<div lang="en-US"><time ${attrs}>${text}</time></div>`).querySelector(
    "time",
  );

const at = (seconds) => new Date(NOW.getTime() + seconds * 1000).toISOString();

describe("relativeTimes", () => {
  beforeEach(() => {
    vi.useFakeTimers();
    vi.setSystemTime(NOW);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("writes the relative text and keeps the server text as title", () => {
    const el = relative(
      `datetime="${at(-3 * 3600)}" data-relative="datetime"`,
      "2026-09-30 09:00:00Z",
    );

    relativeTimes(el.parentElement);

    expect(el.textContent).toBe("3 hours ago");
    expect(el.title).toBe("2026-09-30 09:00:00Z");
  });

  it("writes now under a minute", () => {
    const el = relative(`datetime="${at(-20)}" data-relative="datetime"`);

    relativeTimes(el.parentElement);

    expect(el.textContent).toBe("now");
  });

  it("writes a future value", () => {
    const el = relative(`datetime="${at(600)}" data-relative="datetime"`);

    relativeTimes(el.parentElement);

    expect(el.textContent).toBe("in 10 minutes");
  });

  it("writes the short format", () => {
    const el = relative(
      `datetime="${at(-3 * 3600)}" data-relative="datetime" data-relative-format="short"`,
    );

    relativeTimes(el.parentElement);

    expect(el.textContent).toBe("3 hr. ago");
  });

  it("writes yesterday for a date", () => {
    const el = relative(
      `datetime="2026-09-29" data-relative="date" data-localize-zone="UTC"`,
    );

    relativeTimes(el.parentElement);

    expect(el.textContent).toBe("yesterday");
  });

  it("writes yesterday for a date in the server zone", () => {
    const el = relative(
      `datetime="2026-09-30" data-relative="date" data-localize-zone="server" data-timezone="Pacific/Kiritimati"`,
    );

    relativeTimes(el.parentElement);

    expect(el.textContent).toBe("yesterday");
  });

  it("writes days with numeric always", () => {
    const el = relative(
      `datetime="2026-09-29" data-relative="date" data-relative-numeric="always" data-localize-zone="UTC"`,
    );

    relativeTimes(el.parentElement);

    expect(el.textContent).toBe("1 day ago");
  });

  it("clamps a value slightly in the future with tense past", () => {
    const el = relative(
      `datetime="${at(30)}" data-relative="datetime" data-relative-tense="past"`,
    );

    relativeTimes(el.parentElement);

    expect(el.textContent).toBe("now");
  });

  it("corrects the clock with the server time", () => {
    const el = relative(
      `datetime="${at(-3600)}" data-relative="datetime" data-relative-now="${at(3600)}"`,
    );

    relativeTimes(el.parentElement);

    expect(el.textContent).toBe("2 hours ago");
  });

  describe("with a threshold", () => {
    it("keeps the server text past it", () => {
      const el = relative(
        `datetime="${at(-3 * 86400)}" data-relative="datetime" data-relative-threshold="86400"`,
        "2026-09-27",
      );

      relativeTimes(el.parentElement);

      expect(el.textContent).toBe("2026-09-27");
    });

    it("writes the localized absolute value past it", () => {
      const el = relative(
        `datetime="${at(-3 * 86400)}" data-relative="datetime" data-relative-threshold="86400"
         data-localize="datetime" data-localize-pattern="%Y-%m-%d" data-localize-zone="UTC"`,
      );

      relativeTimes(el.parentElement);

      expect(el.textContent).toBe("2026-09-27");
    });
  });

  describe("with sync", () => {
    it("updates the text as time passes", async () => {
      const el = relative(
        `datetime="${at(-90)}" data-relative="datetime" data-relative-sync="true"`,
      );

      relativeTimes(el.parentElement);
      expect(el.textContent).toBe("1 minute ago");

      await vi.advanceTimersByTimeAsync(60 * 1000);

      expect(el.textContent).toBe("2 minutes ago");
    });

    it("does not update inside an opt-out", async () => {
      const el = relative(
        `datetime="${at(-90)}" data-relative="datetime" data-relative-sync="true"`,
      );
      el.parentElement.setAttribute("data-relative-sync", "false");

      relativeTimes(el.parentElement.parentElement);
      await vi.advanceTimersByTimeAsync(60 * 1000);

      expect(el.textContent).toBe("1 minute ago");
    });

    it("does not update inside a live region", async () => {
      const el = relative(
        `datetime="${at(-90)}" data-relative="datetime" data-relative-sync="true"`,
      );
      el.parentElement.setAttribute("aria-live", "polite");

      relativeTimes(el.parentElement);
      await vi.advanceTimersByTimeAsync(60 * 1000);

      expect(el.textContent).toBe("1 minute ago");
    });
  });

  it("does not update without sync", async () => {
    const el = relative(`datetime="${at(-90)}" data-relative="datetime"`);

    relativeTimes(el.parentElement);
    await vi.advanceTimersByTimeAsync(60 * 1000);

    expect(el.textContent).toBe("1 minute ago");
  });

  it("converts restored server text again", async () => {
    const el = relative(`datetime="${at(-90)}" data-relative="datetime"`);

    relativeTimes(el.parentElement);
    el.textContent = "patched";
    await vi.advanceTimersByTimeAsync(0);

    expect(el.textContent).toBe("1 minute ago");
    expect(el.title).toBe("patched");
  });

  it("writes the absolute value for printing", () => {
    const el = relative(`datetime="${at(-90)}" data-relative="datetime"`);

    relativeTimes(el.parentElement);
    window.dispatchEvent(new Event("beforeprint"));
    expect(el.textContent).toBe("server");

    window.dispatchEvent(new Event("afterprint"));
    expect(el.textContent).toBe("1 minute ago");
  });
});
