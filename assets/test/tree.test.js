import { beforeEach, describe, expect, it } from "vitest";
import { initTree } from "../js/hooks/tree.js";
import fixture from "./fixtures/tree.html?raw";
import { press, render } from "./dom.js";

// An item's own label: not the items nested inside it, and not the caret.
const labelOf = (item) =>
  item.querySelector(":scope > span").textContent.trim();

const focused = () => labelOf(document.activeElement);

const visible = (el) =>
  Array.from(el.querySelectorAll('[role="treeitem"]'))
    .filter((item) => !item.closest('[role="group"][hidden]'))
    .map(labelOf);

describe("tree hook", () => {
  let el;
  let hook;

  const item = (label) =>
    Array.from(el.querySelectorAll('[role="treeitem"]')).find(
      (candidate) => labelOf(candidate) === label,
    );

  beforeEach(() => {
    el = render(fixture);
    hook = initTree(el);
  });

  it("skips the items of a collapsed branch", () => {
    // Working is collapsed, so Boxer and Great Dane are not in the sequence.
    expect(visible(el)).toEqual([
      "Sporting",
      "Golden Retriever",
      "Irish Setter",
      "Working",
      "Poodle",
    ]);
  });

  it("is a single tab stop over the visible items", () => {
    const tabIndexes = Array.from(el.querySelectorAll('[role="treeitem"]')).map(
      (i) => i.getAttribute("tabindex"),
    );

    // Every item is written, hidden ones included, so that a collapse cannot
    // leave a stale tab stop behind.
    expect(tabIndexes).toEqual(["0", "-1", "-1", "-1", "-1", "-1", "-1"]);
  });

  it("moves down through the visible items, into an expanded branch", () => {
    item("Sporting").focus();
    press(document.activeElement, "ArrowDown");

    expect(focused()).toBe("Golden Retriever");
  });

  it("moves down past a collapsed branch", () => {
    item("Working").focus();
    press(document.activeElement, "ArrowDown");

    expect(focused()).toBe("Poodle");
  });

  it("expands a collapsed branch with Right, then walks into it", () => {
    item("Working").focus();

    press(document.activeElement, "ArrowRight");
    expect(focused()).toBe("Working");
    expect(visible(el)).toContain("Boxer");

    press(document.activeElement, "ArrowRight");
    expect(focused()).toBe("Boxer");
  });

  it("collapses an expanded branch with Left, then walks out", () => {
    item("Sporting").focus();

    press(document.activeElement, "ArrowLeft");
    expect(visible(el)).not.toContain("Golden Retriever");

    // Sporting is collapsed now and has no parent, so Left does nothing more.
    press(document.activeElement, "ArrowLeft");
    expect(focused()).toBe("Sporting");
  });

  it("moves to the parent with Left from a child", () => {
    item("Irish Setter").focus();
    press(document.activeElement, "ArrowLeft");

    expect(focused()).toBe("Sporting");
  });

  it("does nothing on Right at a leaf", () => {
    item("Poodle").focus();
    press(document.activeElement, "ArrowRight");

    expect(focused()).toBe("Poodle");
  });

  it("goes to the ends with Home and End", () => {
    item("Golden Retriever").focus();

    press(document.activeElement, "End");
    expect(focused()).toBe("Poodle");

    press(document.activeElement, "Home");
    expect(focused()).toBe("Sporting");
  });

  it("moves to an item by typing", () => {
    item("Sporting").focus();
    press(document.activeElement, "p");

    expect(focused()).toBe("Poodle");
  });

  it("searches the visible items only", () => {
    item("Sporting").focus();
    // Boxer is inside the collapsed branch, so typing "b" finds nothing.
    press(document.activeElement, "b");

    expect(focused()).toBe("Sporting");
  });

  it("toggles a branch when its label is clicked", () => {
    item("Working").querySelector(":scope > button").click();
    expect(visible(el)).toContain("Boxer");

    item("Working").querySelector(":scope > button").click();
    expect(visible(el)).not.toContain("Boxer");
  });

  it("takes the tab stop when a branch is clicked", () => {
    item("Working").querySelector(":scope > button").click();

    expect(item("Working").getAttribute("tabindex")).toBe("0");
  });

  it("leaves a click on a leaf alone", () => {
    const leaf = item("Golden Retriever");

    expect(leaf.querySelector(":scope > button")).toBe(null);

    leaf.querySelector(":scope > span").click();

    // A leaf has no branch state, so a click must not invent any.
    expect(leaf.hasAttribute("aria-expanded")).toBe(false);
  });

  it("leaves a click on the label to the caller", () => {
    // Only the caret toggles, so a click on the label is free for selection.
    item("Sporting").querySelector(":scope > span").click();

    expect(visible(el)).toContain("Golden Retriever");
  });

  it("toggles the branch that was clicked, not its parent", () => {
    item("Working").querySelector(":scope > button").click();
    item("Sporting").querySelector(":scope > button").click();

    // Sporting collapsed; Working stayed open.
    expect(visible(el)).not.toContain("Golden Retriever");
    expect(visible(el)).toContain("Boxer");
  });

  it("never leaves the tab stop on a hidden item", () => {
    // Walk into the branch so that a child holds the tab stop, then collapse
    // the branch from its parent.
    item("Golden Retriever").focus();
    item("Sporting").focus();
    press(document.activeElement, "ArrowLeft");

    const stops = Array.from(el.querySelectorAll('[role="treeitem"]')).filter(
      (candidate) => candidate.getAttribute("tabindex") === "0",
    );

    expect(stops.map(labelOf)).toEqual(["Sporting"]);
    expect(stops[0].closest('[role="group"][hidden]')).toBe(null);
  });

  it("keeps a branch the user expanded open after a patch", () => {
    item("Working").focus();
    press(document.activeElement, "ArrowRight");
    expect(visible(el)).toContain("Boxer");

    // A patch renders the server's state again: Working collapsed.
    const working = item("Working");
    working.setAttribute("aria-expanded", "false");
    working.querySelector('[role="group"]').setAttribute("hidden", "");
    hook.update();

    expect(visible(el)).toContain("Boxer");
  });
});
