import { expect, test } from "@playwright/test";

import { openHarness, selectComponent } from "./helpers.js";

const button = (page) => page.getByRole("button", { name: "Actions" });
const menu = (page) => page.locator("#test-menu");
const wrapLines = (page) =>
  menu(page).locator('[role="menuitemcheckbox"]', { hasText: "Wrap lines" });

test.describe("menu_button", () => {
  test.beforeEach(async ({ page }) => {
    await openHarness(page);
    await selectComponent(page, "menu_button");
  });

  test("closes the menu and focuses the button on Enter", async ({ page }) => {
    await button(page).click();
    await expect(menu(page)).toBeVisible();

    await page.getByRole("menuitem", { name: "Adopt" }).focus();
    await page.keyboard.press("Enter");

    await expect(page.locator("#chosen")).toHaveText("Chosen: Adopt");
    await expect(menu(page)).toBeHidden();
    await expect(button(page)).toHaveAttribute("aria-expanded", "false");
    await expect(button(page)).toBeFocused();
  });

  test("closes the menu and focuses the button on Space", async ({ page }) => {
    await button(page).click();
    await expect(menu(page)).toBeVisible();

    await page.getByRole("menuitem", { name: "Adopt" }).focus();
    await page.keyboard.press(" ");

    await expect(page.locator("#chosen")).toHaveText("Chosen: Adopt");
    await expect(menu(page)).toBeHidden();
    await expect(button(page)).toHaveAttribute("aria-expanded", "false");
    await expect(button(page)).toBeFocused();
  });

  test("lets a click-away binding fire when an item is chosen", async ({
    page,
  }) => {
    await button(page).click();
    await page.getByRole("menuitem", { name: "Foster" }).click();
    await expect(page.locator("#chosen")).toHaveText("Chosen: Foster");

    await expect(page.locator("#clicked-away")).toHaveText("Clicked away: 2");
  });

  test("opens the menu again after an item is chosen", async ({ page }) => {
    await button(page).click();
    await page.getByRole("menuitem", { name: "Foster" }).click();
    await expect(page.locator("#chosen")).toHaveText("Chosen: Foster");

    await button(page).click();

    await expect(menu(page)).toBeVisible();
    await expect(button(page)).toHaveAttribute("aria-expanded", "true");
  });

  test.describe("when opened with the keyboard", () => {
    test("keeps the menu open when a checkbox item is toggled", async ({
      page,
    }) => {
      await button(page).press("ArrowDown");
      await expect(menu(page)).toBeVisible();

      const item = wrapLines(page);
      await item.focus();
      await page.keyboard.press("Enter");
      await expect(item).toHaveAttribute("aria-checked", "true");

      await expect(menu(page)).toBeVisible();
      await expect(button(page)).toHaveAttribute("aria-expanded", "true");
    });

    test("keeps the menu open if Escape closed it before", async ({ page }) => {
      await button(page).click();
      await page.keyboard.press("Escape");
      await expect(menu(page)).toBeHidden();

      await button(page).press("ArrowDown");
      await expect(menu(page)).toBeVisible();

      const item = wrapLines(page);
      await item.focus();
      await page.keyboard.press("Enter");
      await expect(item).toHaveAttribute("aria-checked", "true");

      await expect(menu(page)).toBeVisible();
      await expect(button(page)).toHaveAttribute("aria-expanded", "true");
      await expect(item).toBeFocused();
    });
  });

  test("keeps the menu open when a checkbox item is toggled", async ({
    page,
  }) => {
    await button(page).click();
    await wrapLines(page).click();
    await expect(wrapLines(page)).toHaveAttribute("aria-checked", "true");

    await expect(menu(page)).toBeVisible();
  });
});
