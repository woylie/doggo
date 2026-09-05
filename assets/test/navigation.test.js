import { describe, expect, it } from "vitest";
import {
  clamp,
  searchIndex,
  selectTab,
  setRovingTabindex,
  targetIndex,
} from "../js/navigation.js";
import { render } from "./dom.js";

describe("targetIndex", () => {
  it("steps forward and back", () => {
    expect(targetIndex("ArrowRight", 0, 3)).toBe(1);
    expect(targetIndex("ArrowLeft", 2, 3)).toBe(1);
  });

  it("wraps at both ends", () => {
    expect(targetIndex("ArrowRight", 2, 3)).toBe(0);
    expect(targetIndex("ArrowLeft", 0, 3)).toBe(2);
  });

  it("stops at both ends without wrap", () => {
    expect(targetIndex("ArrowRight", 2, 3, { wrap: false })).toBe(2);
    expect(targetIndex("ArrowLeft", 0, 3, { wrap: false })).toBe(0);
  });

  it("goes to the ends with Home and End", () => {
    expect(targetIndex("Home", 1, 3)).toBe(0);
    expect(targetIndex("End", 1, 3)).toBe(2);
  });

  it("uses the vertical keys when the orientation is vertical", () => {
    const vertical = { orientation: "vertical" };

    expect(targetIndex("ArrowDown", 0, 3, vertical)).toBe(1);
    expect(targetIndex("ArrowUp", 0, 3, vertical)).toBe(2);
    expect(targetIndex("ArrowRight", 0, 3, vertical)).toBe(null);
  });

  it("returns null for a key it does not handle", () => {
    expect(targetIndex("Enter", 0, 3)).toBe(null);
    expect(targetIndex("ArrowUp", 0, 3)).toBe(null);
  });
});

describe("clamp", () => {
  it("keeps an index inside the list", () => {
    expect(clamp(5, 3)).toBe(2);
    expect(clamp(-1, 3)).toBe(0);
    expect(clamp(1, 3)).toBe(1);
  });
});

describe("setRovingTabindex", () => {
  it("leaves one element in the tab order", () => {
    const el = render("<div><button>a</button><button>b</button></div>");
    const buttons = Array.from(el.querySelectorAll("button"));

    setRovingTabindex(buttons, 1);

    expect(buttons.map((b) => b.getAttribute("tabindex"))).toEqual(["-1", "0"]);
  });
});

describe("selectTab", () => {
  it("marks one tab selected and puts it in the tab order", () => {
    const el = render(
      '<div><button role="tab">a</button><button role="tab">b</button></div>',
    );
    const tabs = Array.from(el.querySelectorAll('[role="tab"]'));

    selectTab(tabs, 0);

    expect(tabs.map((t) => t.getAttribute("aria-selected"))).toEqual([
      "true",
      "false",
    ]);
    expect(tabs.map((t) => t.getAttribute("tabindex"))).toEqual(["0", "-1"]);
  });
});

describe("searchIndex", () => {
  const labels = ["Copy", "Cut", "Paste", "Print"];

  it("finds the next label starting with the search", () => {
    expect(searchIndex(labels, "p", 0)).toBe(2);
  });

  it("moves on to the next match when the search repeats", () => {
    expect(searchIndex(labels, "p", 2)).toBe(3);
  });

  it("wraps around", () => {
    expect(searchIndex(labels, "c", 2)).toBe(0);
  });

  it("matches more than one character", () => {
    expect(searchIndex(labels, "cu", 0)).toBe(1);
  });

  it("ignores case and surrounding space", () => {
    expect(searchIndex(["  Copy  "], "COP", 0)).toBe(0);
  });

  it("returns null when nothing matches", () => {
    expect(searchIndex(labels, "z", 0)).toBe(null);
  });
});
