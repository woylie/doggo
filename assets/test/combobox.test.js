import { beforeEach, describe, expect, it } from "vitest";
import { initCombobox } from "../js/hooks/combobox.js";
import fixture from "../../test/fixtures/combobox.html?raw";
import groupedFixture from "../../test/fixtures/combobox_grouped.html?raw";
import freeTextFixture from "../../test/fixtures/combobox_free_text.html?raw";
import { press, render } from "./dom.js";

const input = (el) => el.querySelector('[role="combobox"]');
const listbox = (el) => el.querySelector('[role="listbox"]');
const hiddenInput = (el) => el.querySelector('input[type="hidden"]');

const shown = (el) =>
  Array.from(el.querySelectorAll('[role="option"]'))
    .filter((option) => !option.hidden)
    .map((option) => option.id);

const active = (el) => input(el).getAttribute("aria-activedescendant");

const selectedIds = (el) =>
  Array.from(el.querySelectorAll('[role="option"]'))
    .filter((option) => option.getAttribute("aria-selected") === "true")
    .map((option) => option.id);

const expanded = (el) => input(el).getAttribute("aria-expanded") === "true";

const freeText = (el) => el.querySelector("[data-free-text]");

const shownGroups = (el) =>
  Array.from(el.querySelectorAll('[role="group"]'))
    .filter((group) => !group.hidden)
    .map((group) => group.getAttribute("aria-labelledby"));

const shownSeparators = (el) =>
  Array.from(el.querySelectorAll("hr")).filter((hr) => !hr.hidden).length;

const type = (el, value) => {
  input(el).value = value;
  input(el).dispatchEvent(new window.Event("input", { bubbles: true }));
};

describe("combobox hook", () => {
  let el;
  let hook;

  beforeEach(() => {
    el = render(fixture);
    hook = initCombobox(el);
    input(el).focus();
  });

  it("starts closed with the server's selection", () => {
    expect(expanded(el)).toBe(false);
    expect(listbox(el).hidden).toBe(true);
    expect(input(el).value).toBe("Siberian Husky");
    expect(hiddenInput(el).value).toBe("husky");
    expect(active(el)).toBe(null);
    expect(selectedIds(el)).toEqual(["breed-selector-option-2"]);
  });

  it("opens on the current value, the way a native select does", () => {
    press(input(el), "ArrowDown");

    expect(expanded(el)).toBe(true);
    expect(active(el)).toBe("breed-selector-option-2");
  });

  it("opens on the current value with ArrowUp too", () => {
    press(input(el), "ArrowUp");

    expect(expanded(el)).toBe(true);
    expect(active(el)).toBe("breed-selector-option-2");
  });

  it("opens on the first option when there is no value", () => {
    el = render(fixture);
    hiddenInput(el).value = "";
    input(el).value = "";
    hook = initCombobox(el);
    input(el).focus();

    press(input(el), "ArrowDown");
    expect(active(el)).toBe("breed-selector-option-1");
  });

  it("opens on the last option with ArrowUp when there is no value", () => {
    el = render(fixture);
    hiddenInput(el).value = "";
    input(el).value = "";
    hook = initCombobox(el);
    input(el).focus();

    press(input(el), "ArrowUp");
    expect(active(el)).toBe("breed-selector-option-3");
  });

  it("marks the active option as selected while browsing", () => {
    press(input(el), "ArrowDown");
    press(input(el), "ArrowUp");

    expect(active(el)).toBe("breed-selector-option-1");
    expect(selectedIds(el)).toEqual(["breed-selector-option-1"]);
  });

  it("goes back to marking the committed value when the listbox closes", () => {
    press(input(el), "ArrowDown");
    press(input(el), "ArrowUp");
    press(input(el), "Escape");

    expect(active(el)).toBe(null);
    expect(selectedIds(el)).toEqual(["breed-selector-option-2"]);
    expect(hiddenInput(el).value).toBe("husky");
  });

  it("opens without moving on Alt+ArrowDown", () => {
    input(el).dispatchEvent(
      new window.KeyboardEvent("keydown", {
        key: "ArrowDown",
        altKey: true,
        bubbles: true,
        cancelable: true,
      }),
    );

    expect(expanded(el)).toBe(true);
    expect(active(el)).toBe(null);
  });

  it("wraps at the start", () => {
    press(input(el), "ArrowDown");
    press(input(el), "ArrowUp");
    press(input(el), "ArrowUp");

    expect(active(el)).toBe("breed-selector-option-3");
  });

  it("wraps at the end", () => {
    press(input(el), "ArrowDown");
    press(input(el), "ArrowDown");
    press(input(el), "ArrowDown");

    expect(active(el)).toBe("breed-selector-option-1");
  });

  // key handling should not disturb text editing
  it("leaves Home, End and the caret keys to the input", () => {
    press(input(el), "ArrowDown");

    for (const key of ["Home", "End", "ArrowLeft", "ArrowRight", "Backspace"]) {
      const event = new window.KeyboardEvent("keydown", {
        key,
        bubbles: true,
        cancelable: true,
      });
      input(el).dispatchEvent(event);

      expect(event.defaultPrevented).toBe(false);
    }

    expect(active(el)).toBe("breed-selector-option-2");
    expect(expanded(el)).toBe(true);
  });

  it("selects the active option with Enter", () => {
    press(input(el), "ArrowDown");
    press(input(el), "ArrowUp");
    press(input(el), "Enter");

    expect(expanded(el)).toBe(false);
    expect(input(el).value).toBe("Golden Retriever");
    expect(hiddenInput(el).value).toBe("golden");
    expect(selectedIds(el)).toEqual(["breed-selector-option-1"]);
  });

  it("fires an input event on the hidden field when selecting", () => {
    let fired = 0;
    hiddenInput(el).addEventListener("input", () => fired++);

    press(input(el), "ArrowDown");
    press(input(el), "Enter");

    expect(fired).toBe(1);
  });

  it("re-reads the value the server rendered on update", () => {
    hiddenInput(el).value = "golden";
    hook.update();

    expect(selectedIds(el)).toEqual(["breed-selector-option-1"]);

    press(input(el), "ArrowDown");
    expect(active(el)).toBe("breed-selector-option-1");
  });

  it("selects the active option with Tab without blocking the key", () => {
    press(input(el), "ArrowDown");

    const event = new window.KeyboardEvent("keydown", {
      key: "Tab",
      bubbles: true,
      cancelable: true,
    });
    input(el).dispatchEvent(event);

    expect(event.defaultPrevented).toBe(false);
    expect(hiddenInput(el).value).toBe("husky");
  });

  it("selects on click", () => {
    press(input(el), "ArrowDown");
    el.querySelector("#breed-selector-option-3").click();

    expect(hiddenInput(el).value).toBe("Dachshund");
    expect(input(el).value).toBe("Dachshund");
    expect(expanded(el)).toBe(false);
  });

  it("filters the options as the user types", () => {
    type(el, "retr");

    expect(expanded(el)).toBe(true);
    expect(shown(el)).toEqual(["breed-selector-option-1"]);
  });

  it("filters case-insensitively and on any part of the label", () => {
    type(el, "HUSK");

    expect(shown(el)).toEqual(["breed-selector-option-2"]);
  });

  it("shows every option again once a selection is made", () => {
    type(el, "retr");
    press(input(el), "ArrowDown");
    press(input(el), "Enter");
    press(input(el), "ArrowDown");

    expect(shown(el)).toEqual([
      "breed-selector-option-1",
      "breed-selector-option-2",
      "breed-selector-option-3",
    ]);
  });

  it("closes when nothing matches", () => {
    type(el, "poodle");

    expect(shown(el)).toEqual([]);
    expect(expanded(el)).toBe(false);
  });

  it("restores the committed value on Escape while open", () => {
    press(input(el), "ArrowDown");
    press(input(el), "ArrowUp");
    press(input(el), "Enter");
    type(el, "husk");
    press(input(el), "Escape");

    expect(expanded(el)).toBe(false);
    expect(input(el).value).toBe("Golden Retriever");
    expect(hiddenInput(el).value).toBe("golden");
  });

  it("restores the committed value on Escape after a search matched nothing", () => {
    press(input(el), "ArrowDown");
    press(input(el), "Enter");
    type(el, "xyz");

    expect(expanded(el)).toBe(false);

    press(input(el), "Escape");

    expect(input(el).value).toBe("Siberian Husky");
    expect(hiddenInput(el).value).toBe("husky");

    // And a second press still clears, so the two stages survive.
    press(input(el), "Escape");

    expect(input(el).value).toBe("");
    expect(hiddenInput(el).value).toBe("");
  });

  it("reopens after the restore, without having lost the value", () => {
    press(input(el), "ArrowDown");
    press(input(el), "Enter");
    type(el, "xyz");
    press(input(el), "Escape");
    press(input(el), "ArrowDown");

    expect(expanded(el)).toBe(true);
    expect(hiddenInput(el).value).toBe("husky");
  });

  it("clears the value on Escape while closed", () => {
    press(input(el), "Escape");

    expect(input(el).value).toBe("");
    expect(hiddenInput(el).value).toBe("");
    expect(selectedIds(el)).toEqual([]);
  });

  describe("Escape and what encloses the combobox", () => {
    const escape = (target) => {
      const event = new window.KeyboardEvent("keydown", {
        key: "Escape",
        bubbles: true,
        cancelable: true,
      });
      target.dispatchEvent(event);
      return event;
    };

    it("keeps the key when it closed the listbox", () => {
      press(input(el), "ArrowDown");

      expect(escape(input(el)).defaultPrevented).toBe(true);
    });

    it("keeps the key when it cleared the value", () => {
      expect(escape(input(el)).defaultPrevented).toBe(true);
    });

    it("lets the key through when there is nothing to clear", () => {
      press(input(el), "Escape");
      expect(input(el).value).toBe("");

      const event = escape(input(el));
      expect(event.defaultPrevented).toBe(false);
    });

    it("does not stop the key from reaching an enclosing dialog", () => {
      press(input(el), "Escape");

      let reached = 0;
      document.body.addEventListener("keydown", () => reached++);
      escape(input(el));

      expect(reached).toBe(1);
    });
  });

  it("toggles with the button and keeps the focus in the input", () => {
    const button = el.querySelector("button");

    button.click();
    expect(expanded(el)).toBe(true);
    expect(document.activeElement).toBe(input(el));

    button.click();
    expect(expanded(el)).toBe(false);
  });

  it("reports the state on the toggle button as well as the input", () => {
    const button = el.querySelector("button");
    expect(button.getAttribute("aria-expanded")).toBe("false");

    press(input(el), "ArrowDown");
    expect(button.getAttribute("aria-expanded")).toBe("true");

    press(input(el), "Escape");
    expect(button.getAttribute("aria-expanded")).toBe("false");
  });

  it("keeps the focus in the input when the listbox is clicked", () => {
    press(input(el), "ArrowDown");

    const event = new window.MouseEvent("mousedown", {
      bubbles: true,
      cancelable: true,
    });
    listbox(el).dispatchEvent(event);

    expect(event.defaultPrevented).toBe(true);
  });

  it("closes when the focus leaves the component", () => {
    press(input(el), "ArrowDown");
    expect(expanded(el)).toBe(true);

    input(el).dispatchEvent(
      new window.FocusEvent("focusout", { bubbles: true, relatedTarget: null }),
    );

    expect(expanded(el)).toBe(false);
    expect(active(el)).toBe(null);
  });

  describe("a value that is not among options", () => {
    beforeEach(() => {
      el = render(fixture);
      input(el).value = "Corgi";
      hiddenInput(el).value = "Corgi";
      hook = initCombobox(el);
      input(el).focus();
    });

    it("marks no option selected", () => {
      expect(selectedIds(el)).toEqual([]);
    });

    it("shows every option, since the value is not a search term", () => {
      press(input(el), "ArrowDown");

      expect(shown(el)).toEqual([
        "breed-selector-option-1",
        "breed-selector-option-2",
        "breed-selector-option-3",
      ]);
    });

    it("opens on the first option, having no value to land on", () => {
      press(input(el), "ArrowDown");

      expect(active(el)).toBe("breed-selector-option-1");
    });

    it("restores the value on Escape after typing over it", () => {
      type(el, "husk");
      press(input(el), "Escape");

      expect(input(el).value).toBe("Corgi");
      expect(hiddenInput(el).value).toBe("Corgi");
    });
  });

  describe("after a patch", () => {
    it("picks up options the server replaced", () => {
      press(input(el), "ArrowDown");

      listbox(el).innerHTML = `
        <li id="breed-selector-option-1" role="option" aria-selected="false" data-value="corgi">
          <span>Welsh Corgi</span>
        </li>`;
      hook.update();

      expect(shown(el)).toEqual(["breed-selector-option-1"]);
      expect(active(el)).toBe(null);

      press(input(el), "ArrowDown");
      press(input(el), "Enter");
      expect(hiddenInput(el).value).toBe("corgi");
    });

    it("closes when the server leaves nothing to show", () => {
      press(input(el), "ArrowDown");
      expect(expanded(el)).toBe(true);

      listbox(el).innerHTML = "";
      hook.update();

      expect(expanded(el)).toBe(false);
    });

    it("reopens the listbox a patch closed", () => {
      press(input(el), "ArrowDown");

      listbox(el).hidden = true;
      input(el).setAttribute("aria-expanded", "false");
      hook.update();

      expect(listbox(el).hidden).toBe(false);
      expect(input(el).getAttribute("aria-expanded")).toBe("true");
    });

    it("picks up a value the server changed while unfocused", () => {
      input(el).blur();
      input(el).value = "Golden Retriever";
      hiddenInput(el).value = "golden";
      hook.update();

      input(el).focus();
      press(input(el), "ArrowDown");

      expect(shown(el)).toEqual([
        "breed-selector-option-1",
        "breed-selector-option-2",
        "breed-selector-option-3",
      ]);
      expect(selectedIds(el)).toEqual(["breed-selector-option-1"]);

      press(input(el), "Escape");

      expect(input(el).value).toBe("Golden Retriever");
      expect(hiddenInput(el).value).toBe("golden");
    });

    it("keeps what the user typed when the input has the focus", () => {
      type(el, "gold");
      hook.update();

      expect(input(el).value).toBe("gold");

      press(input(el), "Escape");

      expect(input(el).value).toBe("Siberian Husky");
    });

    it("leaves a closed listbox closed", () => {
      hook.update();

      expect(listbox(el).hidden).toBe(true);
      expect(input(el).getAttribute("aria-expanded")).toBe("false");
    });
  });

  describe("readonly and disabled", () => {
    const build = (attr) => {
      el = render(fixture);
      input(el)[attr] = true;
      hook = initCombobox(el);
      input(el).focus();
    };

    for (const attr of ["readOnly", "disabled"]) {
      it(`does not open on ArrowDown when ${attr}`, () => {
        build(attr);
        press(input(el), "ArrowDown");

        expect(expanded(el)).toBe(false);
        expect(active(el)).toBe(null);
      });

      it(`does not open from the toggle button when ${attr}`, () => {
        build(attr);
        el.querySelector("button").click();

        expect(expanded(el)).toBe(false);
      });

      it(`does not select on click when ${attr}`, () => {
        build(attr);
        el.querySelector("#breed-selector-option-1").click();

        expect(hiddenInput(el).value).toBe("husky");
      });
    }
  });

  describe("server filtering", () => {
    beforeEach(() => {
      el = render(fixture);
      el.dataset.filter = "server";
      hook = initCombobox(el);
      input(el).focus();
    });

    it("does not filter the options on the client side", () => {
      type(el, "poodle");

      expect(shown(el)).toEqual([
        "breed-selector-option-1",
        "breed-selector-option-2",
        "breed-selector-option-3",
      ]);
      expect(expanded(el)).toBe(true);
    });

    it("keeps the listbox open for a term that matches nothing", () => {
      type(el, "poodle");

      expect(expanded(el)).toBe(true);
    });

    it("restores the display value on Escape", () => {
      type(el, "poodle");
      press(input(el), "Escape");

      expect(input(el).value).toBe("Siberian Husky");
      expect(hiddenInput(el).value).toBe("husky");
    });

    it("selects on click", () => {
      type(el, "poodle");
      el.querySelector("#breed-selector-option-1").click();

      expect(hiddenInput(el).value).toBe("golden");
      expect(input(el).value).toBe("Golden Retriever");
    });
  });

  describe("disabled options", () => {
    beforeEach(() => {
      el = render(fixture);
      el.querySelector("#breed-selector-option-2").setAttribute(
        "aria-disabled",
        "true",
      );
      hook = initCombobox(el);
      input(el).focus();
    });

    it("stays visible", () => {
      expect(el.querySelector("#breed-selector-option-2").hidden).toBe(false);
    });

    it("is unreachable by the arrows in either direction", () => {
      press(input(el), "ArrowDown");

      const visited = [active(el)];

      for (let i = 0; i < 3; i++) {
        press(input(el), "ArrowDown");
        visited.push(active(el));
      }

      expect(visited).toEqual([
        "breed-selector-option-1",
        "breed-selector-option-3",
        "breed-selector-option-1",
        "breed-selector-option-3",
      ]);
    });

    it("is not selected by a click", () => {
      press(input(el), "ArrowDown");
      el.querySelector("#breed-selector-option-2").click();

      expect(hiddenInput(el).value).toBe("husky");
      expect(expanded(el)).toBe(true);
    });
  });
  describe("grouped options", () => {
    beforeEach(() => {
      el = render(groupedFixture);
      hook = initCombobox(el);
      input(el).focus();
    });

    it("opens on the current value across the groups", () => {
      press(input(el), "ArrowDown");

      expect(active(el)).toBe("breed-selector-option-4");
      expect(selectedIds(el)).toEqual(["breed-selector-option-4"]);
    });

    it("moves from one group into the next, skipping the disabled option", () => {
      press(input(el), "ArrowDown");

      const visited = [active(el)];

      for (let i = 0; i < 3; i++) {
        press(input(el), "ArrowDown");
        visited.push(active(el));
      }

      expect(visited).toEqual([
        "breed-selector-option-4",
        "breed-selector-option-1",
        "breed-selector-option-3",
        "breed-selector-option-4",
      ]);
    });

    it("collapses a group whose every option is filtered out", () => {
      type(el, "retriever");

      expect(shown(el)).toEqual([
        "breed-selector-option-1",
        "breed-selector-option-2",
      ]);
      expect(shownGroups(el)).toEqual(["breed-selector-group-1"]);
    });

    it("keeps the group of a match", () => {
      type(el, "dachs");

      expect(shownGroups(el)).toEqual(["breed-selector-group-2"]);
    });

    it("brings a collapsed group back when the term is cleared", () => {
      type(el, "dachs");
      type(el, "");

      expect(shownGroups(el)).toEqual([
        "breed-selector-group-1",
        "breed-selector-group-2",
      ]);
    });

    it("hides the separators while filtering", () => {
      expect(shownSeparators(el)).toBe(1);

      type(el, "dachs");
      expect(shownSeparators(el)).toBe(0);

      type(el, "");
      expect(shownSeparators(el)).toBe(1);
    });

    it("leaves groups and separators to the server when it filters", () => {
      el = render(groupedFixture);
      el.dataset.filter = "server";
      hook = initCombobox(el);
      input(el).focus();

      type(el, "dachs");

      expect(shownSeparators(el)).toBe(1);
      expect(shownGroups(el)).toEqual([
        "breed-selector-group-1",
        "breed-selector-group-2",
      ]);
    });

    it("selects an option inside a group on click", () => {
      press(input(el), "ArrowDown");
      el.querySelector("#breed-selector-option-3").click();

      expect(hiddenInput(el).value).toBe("dachshund");
      expect(input(el).value).toBe("Dachshund");
    });
  });
  describe("free text", () => {
    beforeEach(() => {
      el = render(freeTextFixture);
      hook = initCombobox(el);
      input(el).focus();
    });

    it("is hidden until the term is not an option", () => {
      expect(freeText(el).hidden).toBe(true);

      type(el, "Corgi");

      expect(freeText(el).hidden).toBe(false);
      expect(freeText(el).querySelector("span + span").textContent).toBe(
        "Corgi",
      );
    });

    it("stays hidden when the term matches an option exactly", () => {
      type(el, "Dachshund");

      expect(freeText(el).hidden).toBe(true);
    });

    it("stays hidden for an empty term", () => {
      type(el, "");

      expect(freeText(el).hidden).toBe(true);
    });

    it("keeps the listbox open for a term that matches nothing", () => {
      type(el, "Corgi");

      expect(expanded(el)).toBe(true);
      expect(shown(el)).toEqual(["breed-selector-option-free-text"]);
    });

    it("submits the typed term and takes no selection", () => {
      type(el, "Corgi");
      press(input(el), "ArrowDown");
      press(input(el), "Enter");

      expect(hiddenInput(el).value).toBe("Corgi");
      expect(input(el).value).toBe("Corgi");
      expect(selectedIds(el)).toEqual([]);
    });

    it("submits the typed term on click", () => {
      type(el, "Corgi");
      freeText(el).click();

      expect(hiddenInput(el).value).toBe("Corgi");
    });

    it("restores the typed term on a later Escape", () => {
      type(el, "Corgi");
      press(input(el), "ArrowDown");
      press(input(el), "Enter");

      type(el, "husk");
      press(input(el), "Escape");

      expect(input(el).value).toBe("Corgi");
      expect(hiddenInput(el).value).toBe("Corgi");
    });

    it("is offered while the server filters too", () => {
      el = render(freeTextFixture);
      el.dataset.filter = "server";
      hook = initCombobox(el);
      input(el).focus();

      type(el, "Corgi");

      expect(freeText(el).hidden).toBe(false);
    });
  });
  describe("required tracks the value, not the search term", () => {
    const build = () => {
      el = render(fixture);
      input(el).required = true;
      hiddenInput(el).value = "";
      input(el).value = "";
      hook = initCombobox(el);
      input(el).focus();
    };

    it("is invalid with nothing selected", () => {
      build();

      expect(input(el).checkValidity()).toBe(false);
    });

    it("leaves an empty input to the browser's own message", () => {
      build();

      expect(input(el).validity.valueMissing).toBe(true);
      expect(input(el).validity.customError).toBe(false);
    });

    it("borrows the browser's message for an unselected list", () => {
      build();
      type(el, "Corgi");

      const select = document.createElement("select");
      select.required = true;

      expect(input(el).validity.customError).toBe(true);
      expect(input(el).validationMessage).toBe(select.validationMessage);
    });

    it("stays invalid for a term that selects nothing", () => {
      build();
      type(el, "Corgi");

      expect(input(el).checkValidity()).toBe(false);
    });

    it("becomes valid once an option is selected", () => {
      build();
      press(input(el), "ArrowDown");
      press(input(el), "Enter");

      expect(input(el).checkValidity()).toBe(true);
      expect(input(el).validationMessage).toBe("");
    });

    it("leaves the required attribute to the server", () => {
      build();

      input(el).required = false;
      hook.update();

      expect(input(el).required).toBe(false);
      expect(input(el).checkValidity()).toBe(true);

      input(el).required = true;
      hook.update();

      expect(input(el).required).toBe(true);
      expect(input(el).checkValidity()).toBe(false);
    });

    it("follows a value the server sends on update", () => {
      build();
      expect(input(el).checkValidity()).toBe(false);

      hiddenInput(el).value = "husky";
      input(el).value = "Siberian Husky";
      hook.update();

      expect(input(el).checkValidity()).toBe(true);
    });

    it("leaves a combobox that is not required alone", () => {
      el = render(fixture);
      hiddenInput(el).value = "";
      input(el).value = "";
      hook = initCombobox(el);

      expect(input(el).required).toBe(false);
      expect(input(el).checkValidity()).toBe(true);
    });
  });
  it("marks only the first option holding the value", () => {
    el = render(fixture);
    el.querySelector("#breed-selector-option-3").dataset.value = "husky";
    hook = initCombobox(el);

    expect(selectedIds(el)).toEqual(["breed-selector-option-2"]);
  });
});
