import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { initToggletip } from "../js/hooks/toggletip.js";
import fixture from "../../test/fixtures/toggletip.html?raw";
import { render } from "./dom.js";

// happy-dom does not open popovers, so the tests dispatch the toggle event a
// browser fires when the panel opens or closes.
const toggle = (panel, newState) => {
  const event = new window.Event("toggle");
  event.newState = newState;
  panel.dispatchEvent(event);
};

describe("initToggletip", () => {
  let el;
  let panel;
  let status;
  let hook;

  beforeEach(() => {
    vi.useFakeTimers();
    el = render(fixture);
    panel = el.querySelector("[popover]");
    status = el.querySelector('[role="status"]');
    hook = initToggletip(el);
  });

  afterEach(() => {
    vi.useRealTimers();
    vi.restoreAllMocks();
  });

  it("announces the panel's text when it opens", () => {
    toggle(panel, "open");

    expect(status.textContent).toBe("The fee covers vaccinations.");
  });

  it("empties the status when the panel closes", () => {
    toggle(panel, "open");
    toggle(panel, "closed");

    expect(status.textContent).toBe("");
  });

  it("empties the status after the announcement", () => {
    toggle(panel, "open");
    vi.advanceTimersByTime(1000);

    expect(status.textContent).toBe("");
  });

  it("cuts a long text", () => {
    panel.textContent = "a".repeat(300);
    toggle(panel, "open");

    expect(status.textContent).toBe(`${"a".repeat(250)}…`);
  });

  it("stops announcing after destroy", () => {
    hook.destroy();
    toggle(panel, "open");

    expect(status.textContent).toBe("");
  });

  describe("without anchor positioning", () => {
    beforeEach(() => {
      vi.spyOn(window, "CSS", "get").mockReturnValue({ supports: () => false });
      el.querySelector("button").getBoundingClientRect = () => ({
        left: 40,
        right: 60,
        bottom: 100,
      });
    });

    it("places the panel below the button before it opens", () => {
      const event = new window.Event("beforetoggle");
      event.newState = "open";
      panel.dispatchEvent(event);

      expect(panel.style.getPropertyValue("inset-block-start")).toBe("100px");
      expect(panel.style.getPropertyValue("inset-inline-start")).toBe("40px");
    });

    it("measures from the right on a right-to-left page", () => {
      el.dir = "rtl";
      el.style.direction = "rtl";
      const event = new window.Event("beforetoggle");
      event.newState = "open";
      panel.dispatchEvent(event);

      expect(panel.style.getPropertyValue("inset-inline-start")).toBe(
        `${window.innerWidth - 60}px`,
      );
    });
  });
});
