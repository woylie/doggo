import { expect, test } from "@playwright/test";

import { openHarness, selectComponent } from "./helpers.js";

test.beforeEach(async ({ page }) => {
  await openHarness(page);
  await selectComponent(page, "carousel");
});

test("scrolls the slides by keyboard", async ({ page }) => {
  const container = page.locator("#test-carousel .carousel-items-container");
  await container.focus();

  const before = await container.evaluate((el) => el.scrollLeft);
  await page.keyboard.press("ArrowRight");

  await expect
    .poll(() => container.evaluate((el) => el.scrollLeft))
    .toBeGreaterThan(before);
});

test("marks the focused scroll container", async ({ page }) => {
  const container = page.locator("#test-carousel .carousel-items-container");
  await container.focus();

  const outlineStyle = await container.evaluate(
    (el) => getComputedStyle(el).outlineStyle,
  );
  expect(outlineStyle).toBe("solid");
});
