import { beforeEach, describe, expect, it } from "vitest";
import { initAccordion } from "../js/hooks/accordion.js";
import fixture from "./fixtures/accordion.html?raw";
import { press, render } from "./dom.js";

const focused = () => document.activeElement.textContent.trim();

const tabIndexes = (el) =>
  Array.from(el.querySelectorAll("button")).map((header) =>
    header.getAttribute("tabindex"),
  );

describe("accordion hook", () => {
  let el;

  const header = (name) =>
    Array.from(el.querySelectorAll("button")).find(
      (button) => button.textContent.trim() === name,
    );

  beforeEach(() => {
    el = render(fixture);
    initAccordion(el);
  });

  it("moves to the next header with Down", () => {
    header("Golden Retriever").focus();
    press(document.activeElement, "ArrowDown");

    expect(focused()).toBe("Siberian Husky");
  });

  it("moves to the previous header with Up", () => {
    header("Dachshund").focus();
    press(document.activeElement, "ArrowUp");

    expect(focused()).toBe("Siberian Husky");
  });

  it("wraps at both ends", () => {
    header("Dachshund").focus();
    press(document.activeElement, "ArrowDown");
    expect(focused()).toBe("Golden Retriever");

    press(document.activeElement, "ArrowUp");
    expect(focused()).toBe("Dachshund");
  });

  it("goes to the ends with Home and End", () => {
    header("Siberian Husky").focus();

    press(document.activeElement, "End");
    expect(focused()).toBe("Dachshund");

    press(document.activeElement, "Home");
    expect(focused()).toBe("Golden Retriever");
  });

  it("leaves every header in the tab order", () => {
    header("Golden Retriever").focus();
    press(document.activeElement, "ArrowDown");

    // An accordion is not a single tab stop, unlike a tab list or a toolbar.
    expect(tabIndexes(el)).toEqual([null, null, null]);
  });

  it("stops the arrow keys from scrolling the page", () => {
    header("Golden Retriever").focus();
    const event = new window.KeyboardEvent("keydown", {
      key: "ArrowDown",
      bubbles: true,
      cancelable: true,
    });

    document.activeElement.dispatchEvent(event);

    expect(event.defaultPrevented).toBe(true);
  });

  it("ignores the horizontal keys", () => {
    header("Golden Retriever").focus();
    press(document.activeElement, "ArrowRight");

    expect(focused()).toBe("Golden Retriever");
  });

  it("ignores keydowns outside a header", () => {
    const panel = el.querySelector('[role="region"]');
    press(panel, "ArrowDown");

    expect(document.activeElement).toBe(document.body);
  });

  it("leaves the headers of a nested accordion alone", () => {
    const panel = el.querySelector('[role="region"]');
    panel.innerHTML =
      '<div id="inner" phx-hook="Doggo.Accordion">' +
      '<h3><button aria-expanded="true">Inner</button></h3></div>';

    header("Golden Retriever").focus();
    press(document.activeElement, "ArrowDown");

    expect(focused()).toBe("Siberian Husky");
  });
});
