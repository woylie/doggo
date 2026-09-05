import { beforeEach, describe, expect, it } from "vitest";
import MenuButton from "../js/hooks/menu_button.js";
import menuFixture from "./fixtures/menu.html?raw";
import { mount, press, render } from "./hook.js";

describe("menu button hook", () => {
  let button;
  let menu;

  beforeEach(() => {
    render(
      '<div><button id="opener" aria-controls="menu" aria-haspopup="true" ' +
        'aria-expanded="false">Actions</button></div>',
    );
    document.body.insertAdjacentHTML("beforeend", menuFixture);
    button = document.getElementById("opener");
    menu = document.getElementById("menu");
    menu.setAttribute("hidden", "");
    mount(MenuButton, button);
  });

  it("opens on Down and focuses the first item", () => {
    button.focus();
    press(button, "ArrowDown");

    expect(menu.hasAttribute("hidden")).toBe(false);
    expect(button.getAttribute("aria-expanded")).toBe("true");
    expect(document.activeElement.textContent.trim()).toBe("Copy");
  });

  it("opens on Up and focuses the last item", () => {
    button.focus();
    press(button, "ArrowUp");

    expect(menu.hasAttribute("hidden")).toBe(false);
    expect(document.activeElement.textContent.trim()).toBe("Dark");
  });

  it("leaves other keys alone", () => {
    button.focus();
    press(button, "ArrowRight");

    expect(menu.hasAttribute("hidden")).toBe(true);
    expect(button.getAttribute("aria-expanded")).toBe("false");
  });

  it("does nothing when the menu it controls is missing", () => {
    button.setAttribute("aria-controls", "nowhere");
    button.focus();
    press(button, "ArrowDown");

    expect(button.getAttribute("aria-expanded")).toBe("false");
  });
});
