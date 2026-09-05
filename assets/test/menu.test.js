import { beforeEach, describe, expect, it, vi } from "vitest";
import Menu from "../js/hooks/menu.js";
import barFixture from "./fixtures/menu_bar.html?raw";
import fixture from "./fixtures/menu.html?raw";
import { mount, press, render } from "./hook.js";

const ITEMS =
  '[role="menuitem"], [role="menuitemcheckbox"], [role="menuitemradio"]';

const focused = () => document.activeElement.textContent.trim();

const tabIndexes = (el) =>
  Object.fromEntries(
    Array.from(el.querySelectorAll(ITEMS)).map((item) => [
      item.textContent.trim(),
      item.getAttribute("tabindex"),
    ]),
  );

describe("menu hook", () => {
  let el;

  const item = (name) =>
    Array.from(el.querySelectorAll(ITEMS)).find(
      (candidate) => candidate.textContent.trim() === name,
    );

  beforeEach(() => {
    el = render(fixture);
    mount(Menu, el);
  });

  it("is a single tab stop over every item, including nested groups", () => {
    // Wrap lines is a checkbox, Light and Dark are radios in a group. Mail
    // belongs to the submenu, so this menu does not touch it.
    expect(tabIndexes(el)).toEqual({
      Copy: "0",
      "Copy link": "-1",
      Paste: "-1",
      Mail: null,
      "Wrap lines": "-1",
      Light: "-1",
      Dark: "-1",
    });
  });

  it("moves down and up with the arrow keys", () => {
    item("Copy").focus();
    press(document.activeElement, "ArrowDown");
    expect(focused()).toBe("Copy link");

    press(document.activeElement, "ArrowUp");
    expect(focused()).toBe("Copy");
  });

  it("moves into a nested group", () => {
    item("Wrap lines").focus();
    press(document.activeElement, "ArrowDown");

    expect(focused()).toBe("Light");
  });

  it("wraps at both ends", () => {
    item("Copy").focus();
    press(document.activeElement, "ArrowUp");
    expect(focused()).toBe("Dark");

    press(document.activeElement, "ArrowDown");
    expect(focused()).toBe("Copy");
  });

  it("goes to the ends with Home and End", () => {
    item("Paste").focus();

    press(document.activeElement, "End");
    expect(focused()).toBe("Dark");

    press(document.activeElement, "Home");
    expect(focused()).toBe("Copy");
  });

  it("ignores the horizontal keys in a vertical menu", () => {
    item("Copy").focus();
    press(document.activeElement, "ArrowRight");

    expect(focused()).toBe("Copy");
  });

  it("moves to an item by typing its first letter", () => {
    item("Copy").focus();
    press(document.activeElement, "w");

    expect(focused()).toBe("Wrap lines");
  });

  it("matches more than one character within the timeout", () => {
    item("Copy").focus();
    press(document.activeElement, "d");
    press(document.activeElement, "a");

    // "da" matches Dark, where "d" alone had already moved there.
    expect(focused()).toBe("Dark");
  });

  it("starts a new search after the timeout", () => {
    vi.useFakeTimers();
    item("Copy").focus();

    press(document.activeElement, "p");
    expect(focused()).toBe("Paste");

    vi.advanceTimersByTime(600);
    press(document.activeElement, "l");

    expect(focused()).toBe("Light");
    vi.useRealTimers();
  });

  it("leaves a shortcut alone", () => {
    item("Copy").focus();
    document.activeElement.dispatchEvent(
      new window.KeyboardEvent("keydown", {
        key: "p",
        metaKey: true,
        bubbles: true,
        cancelable: true,
      }),
    );

    expect(focused()).toBe("Copy");
  });

  it("refines the search rather than advancing it", () => {
    item("Copy").focus();

    press(document.activeElement, "c");
    expect(focused()).toBe("Copy link");

    // "co" still matches the item it is on, so it stays there.
    press(document.activeElement, "o");
    expect(focused()).toBe("Copy link");
  });

  it("walks through the matches when the same letter repeats", () => {
    item("Copy").focus();

    press(document.activeElement, "c");
    expect(focused()).toBe("Copy link");

    press(document.activeElement, "c");
    expect(focused()).toBe("Copy");
  });

  it("leaves the items of a submenu to its own hook", () => {
    item("Paste").focus();
    press(document.activeElement, "ArrowDown");

    // Mail belongs to the nested menu, so this menu skips past it.
    expect(focused()).toBe("Wrap lines");
  });

  it("keeps the tab stop on the item the user focused", () => {
    item("Paste").focus();

    expect(tabIndexes(el).Paste).toBe("0");
  });
});

describe("menu hook, closing", () => {
  let el;

  beforeEach(() => {
    document.body.innerHTML =
      '<button id="opener" aria-controls="menu" aria-expanded="true">Actions</button>';
    document.body.insertAdjacentHTML("beforeend", fixture);
    el = document.getElementById("menu");
    mount(Menu, el);
  });

  it("closes on Escape and returns the focus to the button", () => {
    el.querySelector('[role="menuitem"]').focus();
    press(document.activeElement, "Escape");

    const button = document.getElementById("opener");

    expect(el.hasAttribute("hidden")).toBe(true);
    expect(button.getAttribute("aria-expanded")).toBe("false");
    expect(document.activeElement).toBe(button);
  });

  it("does not let Escape reach a dialog around the menu", () => {
    el.querySelector('[role="menuitem"]').focus();
    const event = new window.KeyboardEvent("keydown", {
      key: "Escape",
      bubbles: true,
      cancelable: true,
    });
    const reachedTheDocument = vi.fn();
    document.addEventListener("keydown", reachedTheDocument);

    document.activeElement.dispatchEvent(event);
    document.removeEventListener("keydown", reachedTheDocument);

    expect(event.defaultPrevented).toBe(true);
    expect(reachedTheDocument).not.toHaveBeenCalled();
  });
});

describe("menu bar hook", () => {
  let el;

  beforeEach(() => {
    el = render(barFixture);
    mount(Menu, el);
  });

  it("moves with the horizontal keys, since a menu bar runs across", () => {
    el.querySelector('[role="menuitem"]').focus();

    press(document.activeElement, "ArrowDown");
    expect(focused()).toBe("File");

    press(document.activeElement, "ArrowRight");
    expect(focused()).toBe("Edit");

    press(document.activeElement, "ArrowLeft");
    expect(focused()).toBe("File");
  });

  it("wraps at both ends", () => {
    el.querySelector('[role="menuitem"]').focus();
    press(document.activeElement, "ArrowLeft");

    expect(focused()).toBe("View");
  });
});
