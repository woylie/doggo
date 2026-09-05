import { beforeEach, describe, expect, it } from "vitest";
import Tabs from "../js/hooks/tabs.js";
import fixture from "./fixtures/tabs.html?raw";
import { mount, press, render } from "./hook.js";

const selected = (el) =>
  Array.from(el.querySelectorAll('[role="tab"]')).findIndex(
    (tab) => tab.getAttribute("aria-selected") === "true",
  );

const tabOrder = (el) =>
  Array.from(el.querySelectorAll('[role="tab"]')).map((tab) =>
    tab.getAttribute("tabindex"),
  );

const visiblePanels = (el) =>
  Array.from(el.querySelectorAll('[role="tabpanel"]'))
    .filter((panel) => !panel.hasAttribute("hidden"))
    .map((panel) => panel.id);

describe("tabs hook", () => {
  let el;
  let hook;

  beforeEach(() => {
    el = render(fixture);
    hook = mount(Tabs, el);
    el.querySelector('[role="tab"]').focus();
  });

  it("moves to the next tab with ArrowRight", () => {
    press(document.activeElement, "ArrowRight");

    expect(selected(el)).toBe(1);
    expect(document.activeElement.id).toBe("tabs-tab-2");
    expect(visiblePanels(el)).toEqual(["tabs-panel-2"]);
  });

  it("wraps to the first tab from the last", () => {
    press(document.activeElement, "End");
    press(document.activeElement, "ArrowRight");

    expect(selected(el)).toBe(0);
    expect(document.activeElement.id).toBe("tabs-tab-1");
  });

  it("wraps to the last tab from the first", () => {
    press(document.activeElement, "ArrowLeft");

    expect(selected(el)).toBe(2);
    expect(document.activeElement.id).toBe("tabs-tab-3");
  });

  it("selects the first and the last tab with Home and End", () => {
    press(document.activeElement, "End");
    expect(selected(el)).toBe(2);

    press(document.activeElement, "Home");
    expect(selected(el)).toBe(0);
  });

  it("keeps exactly one tab in the tab order", () => {
    press(document.activeElement, "ArrowRight");

    expect(tabOrder(el)).toEqual(["-1", "0", "-1"]);
  });

  it("ignores keys it does not handle", () => {
    press(document.activeElement, "ArrowDown");

    expect(selected(el)).toBe(0);
    expect(document.activeElement.id).toBe("tabs-tab-1");
  });

  it("ignores keydowns outside the tab list", () => {
    press(el.querySelector('[role="tabpanel"]'), "ArrowRight");

    expect(selected(el)).toBe(0);
  });

  it("restores the selection after a patch", () => {
    press(el.querySelector("#tabs-tab-1"), "ArrowRight");

    // A patch re-renders the server's initial state.
    el.querySelector("#tabs-tab-1").setAttribute("aria-selected", "true");
    el.querySelector("#tabs-tab-2").setAttribute("aria-selected", "false");
    el.querySelector("#tabs-panel-2").setAttribute("hidden", "");
    el.querySelector("#tabs-panel-1").removeAttribute("hidden");

    hook.updated();

    expect(selected(el)).toBe(1);
    expect(visiblePanels(el)).toEqual(["tabs-panel-2"]);
  });

  it("clamps the restored selection when tabs are removed", () => {
    press(el.querySelector("#tabs-tab-1"), "End");

    el.querySelector("#tabs-tab-3").remove();
    el.querySelector("#tabs-panel-3").remove();
    hook.updated();

    expect(selected(el)).toBe(1);
  });
});
