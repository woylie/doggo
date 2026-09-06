import { afterEach, beforeEach, describe, expect, it, vi } from "vitest";
import { initCarousel } from "../js/hooks/carousel.js";
import fixture from "../../test/fixtures/carousel.html?raw";
import { render } from "./dom.js";

const activeIdx = (el) => el.getAttribute("data-active-index");

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
});
