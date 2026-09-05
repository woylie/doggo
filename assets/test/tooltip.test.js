import { beforeEach, describe, expect, it, vi } from "vitest";
import { initTooltip } from "../js/hooks/tooltip.js";
import fixture from "./fixtures/tooltip.html?raw";
import { render } from "./dom.js";

// The hook calls `el.matches(":hover")` and `el.matches(":focus-within")` to
// find out whether the tooltip is currently shown, since that is what the CSS
// decides it on. happy-dom has no pointer and implements neither pseudo-class,
// so this replaces `matches` with the answers a test wants it to give.
function pretend(el, { hover = false, focus = false } = {}) {
  el.matches = (selector) =>
    (selector === ":hover" && hover) || (selector === ":focus-within" && focus);
}

// The hook clears a dismissal on the next tick, after the browser has settled
// the focus and the pointer.
const tick = () => new Promise((resolve) => setTimeout(resolve, 0));

const pressEscape = () =>
  window.dispatchEvent(
    new window.KeyboardEvent("keydown", { key: "Escape", bubbles: true }),
  );

const dismissed = (el) => el.hasAttribute("data-dismissed");

describe("tooltip hook", () => {
  let el;
  let hook;

  beforeEach(() => {
    el = render(fixture);
    hook = initTooltip(el);
  });

  it("dismisses a tooltip shown by focus", () => {
    pretend(el, { focus: true });
    pressEscape();

    expect(dismissed(el)).toBe(true);
  });

  it("dismisses a tooltip shown by hover, where the focus is elsewhere", () => {
    pretend(el, { hover: true });
    pressEscape();

    expect(dismissed(el)).toBe(true);
  });

  it("does nothing when the tooltip is not shown", () => {
    pretend(el, {});
    pressEscape();

    expect(dismissed(el)).toBe(false);
  });

  it("does not swallow Escape when the tooltip is not shown", () => {
    pretend(el, {});
    const event = new window.KeyboardEvent("keydown", {
      key: "Escape",
      bubbles: true,
    });
    const stopped = vi.spyOn(event, "stopPropagation");

    window.dispatchEvent(event);

    expect(stopped).not.toHaveBeenCalled();
  });

  it("swallows Escape when it dismisses, so a dialog stays open", () => {
    pretend(el, { focus: true });
    const event = new window.KeyboardEvent("keydown", {
      key: "Escape",
      bubbles: true,
    });
    const stopped = vi.spyOn(event, "stopPropagation");

    window.dispatchEvent(event);

    expect(stopped).toHaveBeenCalled();
  });

  it("ignores other keys", () => {
    pretend(el, { focus: true });
    window.dispatchEvent(
      new window.KeyboardEvent("keydown", { key: "a", bubbles: true }),
    );

    expect(dismissed(el)).toBe(false);
  });

  it("shows the tooltip again when the focus leaves and returns", async () => {
    pretend(el, { focus: true });
    pressEscape();
    expect(dismissed(el)).toBe(true);

    pretend(el, {});
    el.dispatchEvent(new window.FocusEvent("focusout", { bubbles: true }));
    await tick();

    expect(dismissed(el)).toBe(false);
  });

  it("shows the tooltip again when the pointer leaves and returns", async () => {
    pretend(el, { hover: true });
    pressEscape();

    pretend(el, {});
    el.dispatchEvent(new window.Event("pointerleave"));
    await tick();

    expect(dismissed(el)).toBe(false);
  });

  it("stays dismissed when the pointer leaves but the focus stays", async () => {
    pretend(el, { focus: true, hover: true });
    pressEscape();
    expect(dismissed(el)).toBe(true);

    pretend(el, { focus: true });
    el.dispatchEvent(new window.Event("pointerleave"));
    await tick();

    expect(dismissed(el)).toBe(true);
  });

  it("stays dismissed when the focus leaves but the pointer stays", async () => {
    pretend(el, { focus: true, hover: true });
    pressEscape();

    pretend(el, { hover: true });
    el.dispatchEvent(new window.FocusEvent("focusout", { bubbles: true }));
    await tick();

    expect(dismissed(el)).toBe(true);
  });

  it("stops listening when the element is destroyed", () => {
    hook.destroy();
    pretend(el, { focus: true });
    pressEscape();

    expect(dismissed(el)).toBe(false);
  });
});
