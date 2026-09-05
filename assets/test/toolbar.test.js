import { beforeEach, describe, expect, it } from "vitest";
import Toolbar from "../js/hooks/toolbar.js";
import actionBarFixture from "./fixtures/action_bar.html?raw";
import toolbarFixture from "./fixtures/toolbar.html?raw";
import { mount, press, render } from "./hook.js";

const nameOf = (control) =>
  control.getAttribute("aria-label") || control.textContent.trim();

const tabIndexes = (el) =>
  Object.fromEntries(
    Array.from(el.querySelectorAll("button, input")).map((control) => [
      nameOf(control),
      control.getAttribute("tabindex"),
    ]),
  );

const focused = () => nameOf(document.activeElement);

describe("toolbar hook", () => {
  let el;
  let hook;

  const control = (name) =>
    Array.from(el.querySelectorAll("button, input")).find(
      (candidate) => nameOf(candidate) === name,
    );

  const focus = (name) => control(name).focus();

  beforeEach(() => {
    el = render(toolbarFixture);
    hook = mount(Toolbar, el);
  });

  it("puts only the first enabled control in the tab order", () => {
    expect(tabIndexes(el)).toEqual({
      Feed: "0",
      Walk: null, // disabled, so the hook never makes it a stop
      Note: "-1",
      Teach: "-1",
    });
  });

  it("moves across a group boundary and takes the tab stop with it", () => {
    focus("Feed");
    press(control("Feed"), "ArrowRight");

    expect(focused()).toBe("Note");
    expect(tabIndexes(el)).toEqual({
      Feed: "-1",
      Walk: null,
      Note: "0",
      Teach: "-1",
    });
  });

  it("skips disabled controls", () => {
    focus("Feed");
    press(control("Feed"), "ArrowLeft");

    // Walk is disabled, so the control before Feed is the last one, Teach.
    expect(focused()).toBe("Teach");
  });

  it("wraps at both ends", () => {
    focus("Feed");
    press(control("Feed"), "ArrowLeft");
    expect(focused()).toBe("Teach");

    press(control("Teach"), "ArrowRight");
    expect(focused()).toBe("Feed");
  });

  it("goes to the ends with Home and End", () => {
    focus("Teach");
    press(control("Teach"), "End");
    expect(focused()).toBe("Teach");

    press(control("Teach"), "Home");
    expect(focused()).toBe("Feed");
  });

  it("leaves the arrow keys to a text field", () => {
    focus("Note");
    press(control("Note"), "ArrowLeft");

    expect(focused()).toBe("Note");
  });

  it("uses the vertical keys when the toolbar is vertical", () => {
    el.setAttribute("aria-orientation", "vertical");
    focus("Feed");

    press(control("Feed"), "ArrowRight");
    expect(focused()).toBe("Feed");

    press(control("Feed"), "ArrowDown");
    expect(focused()).toBe("Note");
  });

  it("follows a control the user focused directly", () => {
    focus("Teach");

    expect(tabIndexes(el).Teach).toBe("0");
  });

  it("restores the tab stop after a patch", () => {
    focus("Teach");

    // A patch renders every control in the tab order again.
    el.querySelectorAll("button, input").forEach((candidate) =>
      candidate.removeAttribute("tabindex"),
    );
    hook.updated();

    expect(tabIndexes(el).Teach).toBe("0");
  });
});

describe("action bar hook", () => {
  let el;

  beforeEach(() => {
    el = render(actionBarFixture);
    mount(Toolbar, el);
  });

  it("is a single tab stop over its buttons", () => {
    expect(tabIndexes(el)).toEqual({ Edit: "0", Move: "-1", Archive: "-1" });
  });

  it("moves between the buttons with the arrow keys", () => {
    const edit = el.querySelector("button");
    edit.focus();
    press(edit, "ArrowRight");

    expect(focused()).toBe("Move");
  });
});
