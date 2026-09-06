import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { initCarousel } from "../js/hooks/carousel.js";
import fixture from "../../test/fixtures/carousel.html?raw";
import { render } from "./dom.js";

// happy-dom does no layout, so the slide in view cannot be derived from the
// boxes here. Auto rotation does not depend on that: it steps the index and
// the tests read it back.
const activeIdx = (el) => el.getAttribute("data-active-index");

const pointer = (el, type) =>
  el.dispatchEvent(new window.PointerEvent(type, { bubbles: true }));

describe("carousel hook", () => {
  let el;
  let hook;

  beforeEach(() => {
    vi.useFakeTimers();
    el = render(fixture);
    hook = initCarousel(el);
  });

  afterEach(() => {
    vi.useRealTimers();
  });

  it("advances on its own", () => {
    vi.advanceTimersByTime(5000);
    expect(activeIdx(el)).toBe("1");

    vi.advanceTimersByTime(5000);
    expect(activeIdx(el)).toBe("2");
  });

  it("stops rotating once destroyed", () => {
    hook.destroy();
    vi.advanceTimersByTime(20000);

    expect(activeIdx(el)).toBe("0");
  });

  it("does not resume under the pointer when a patch lands", () => {
    pointer(el, "pointerenter");
    hook.update();
    vi.advanceTimersByTime(20000);

    expect(activeIdx(el)).toBe("0");
  });

  it("does not resume while the focus is inside when a patch lands", () => {
    el.querySelector(".carousel-next").focus();
    hook.update();
    vi.advanceTimersByTime(20000);

    expect(activeIdx(el)).toBe("0");
  });

  it("resumes after the pointer leaves", () => {
    pointer(el, "pointerenter");
    pointer(el, "pointerleave");
    vi.advanceTimersByTime(5000);

    expect(activeIdx(el)).toBe("1");
  });
});
