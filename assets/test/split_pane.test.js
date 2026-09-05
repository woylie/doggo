import { beforeEach, describe, expect, it } from "vitest";
import { initSplitPane } from "../js/hooks/split_pane.js";
import fixture from "./fixtures/split_pane.html?raw";
import { press, render } from "./dom.js";

// happy-dom does not lay the page out, so the box the hook measures against is
// the test's own.
const layout = (el, box) => {
  el.getBoundingClientRect = () => ({ left: 0, top: 0, ...box });
};

const pointer = (el, type, coordinates) =>
  el.dispatchEvent(
    new window.PointerEvent(type, {
      pointerId: 1,
      bubbles: true,
      cancelable: true,
      ...coordinates,
    }),
  );

const positionOf = (el) => ({
  property: el.style.getPropertyValue("--split-pane-position"),
  ariaValueNow: el
    .querySelector('[role="separator"]')
    .getAttribute("aria-valuenow"),
});

describe("split pane hook", () => {
  let el;
  let hook;
  let separator;

  beforeEach(() => {
    el = render(fixture);
    hook = initSplitPane(el);
    separator = el.querySelector('[role="separator"]');
  });

  it("applies the position the component rendered", () => {
    expect(positionOf(el)).toEqual({ property: "40%", ariaValueNow: "40" });
  });

  it("moves by one percent with an arrow key", () => {
    press(separator, "ArrowRight");
    expect(positionOf(el)).toEqual({ property: "41%", ariaValueNow: "41" });

    press(separator, "ArrowLeft");
    expect(positionOf(el)).toEqual({ property: "40%", ariaValueNow: "40" });
  });

  it("moves by ten percent when Shift is held", () => {
    separator.dispatchEvent(
      new window.KeyboardEvent("keydown", {
        key: "ArrowRight",
        shiftKey: true,
        bubbles: true,
        cancelable: true,
      }),
    );

    expect(positionOf(el).ariaValueNow).toBe("50");
  });

  it("goes to the limits with Home and End", () => {
    press(separator, "End");
    expect(positionOf(el).ariaValueNow).toBe("80");

    press(separator, "Home");
    expect(positionOf(el).ariaValueNow).toBe("20");
  });

  it("stops at the limits rather than passing them", () => {
    press(separator, "End");
    press(separator, "ArrowRight");
    expect(positionOf(el).ariaValueNow).toBe("80");

    press(separator, "Home");
    press(separator, "ArrowLeft");
    expect(positionOf(el).ariaValueNow).toBe("20");
  });

  it("comes back from a minimum it did not collapse to itself", () => {
    press(separator, "ArrowRight");
    press(separator, "Home");

    press(separator, "Enter");

    expect(positionOf(el).ariaValueNow).toBe("41");
  });

  it("stays put on Enter when it has never been anywhere else", () => {
    const collapsed = render(
      fixture.replace('aria-valuenow="40"', 'aria-valuenow="20"'),
    );
    initSplitPane(collapsed);

    press(collapsed.querySelector('[role="separator"]'), "Enter");

    expect(positionOf(collapsed).ariaValueNow).toBe("20");
  });

  it("collapses with Enter and comes back to where it was", () => {
    press(separator, "ArrowRight");
    expect(positionOf(el).ariaValueNow).toBe("41");

    press(separator, "Enter");
    expect(positionOf(el).ariaValueNow).toBe("20");

    press(separator, "Enter");
    expect(positionOf(el).ariaValueNow).toBe("41");
  });

  it("uses the vertical keys when the separator is horizontal", () => {
    separator.setAttribute("aria-orientation", "horizontal");

    press(separator, "ArrowRight");
    expect(positionOf(el).ariaValueNow).toBe("40");

    press(separator, "ArrowDown");
    expect(positionOf(el).ariaValueNow).toBe("41");
  });

  it("ignores keys it does not handle", () => {
    press(separator, "PageUp");

    expect(positionOf(el).ariaValueNow).toBe("40");
  });

  it("stops the arrow keys from scrolling the page", () => {
    const event = new window.KeyboardEvent("keydown", {
      key: "ArrowRight",
      bubbles: true,
      cancelable: true,
    });

    separator.dispatchEvent(event);

    expect(event.defaultPrevented).toBe(true);
  });

  it("follows the pointer along the axis of the separator", () => {
    layout(el, { width: 200, height: 100 });

    pointer(separator, "pointerdown");
    pointer(separator, "pointermove", { clientX: 150, clientY: 90 });

    expect(positionOf(el).ariaValueNow).toBe("75");
  });

  it("follows the other axis when the separator is horizontal", () => {
    separator.setAttribute("aria-orientation", "horizontal");
    layout(el, { width: 200, height: 100 });

    pointer(separator, "pointerdown");
    pointer(separator, "pointermove", { clientX: 150, clientY: 90 });

    expect(positionOf(el).ariaValueNow).toBe("80");
  });

  it("keeps the pointer within the limits", () => {
    layout(el, { width: 200, height: 100 });

    pointer(separator, "pointerdown");
    pointer(separator, "pointermove", { clientX: 400 });

    expect(positionOf(el).ariaValueNow).toBe("80");
  });

  it("ignores the pointer until it is pressed on the separator", () => {
    layout(el, { width: 200, height: 100 });

    pointer(separator, "pointermove", { clientX: 150 });

    expect(positionOf(el).ariaValueNow).toBe("40");
  });

  it("applies the position again after a patch", () => {
    press(separator, "End");

    // A patch renders the size the server knows about.
    el.style.removeProperty("--split-pane-position");
    separator.setAttribute("aria-valuenow", "40");
    hook.update();

    expect(positionOf(el)).toEqual({ property: "80%", ariaValueNow: "80" });
  });
});
