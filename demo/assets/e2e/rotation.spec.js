import { expect, test } from "@playwright/test";

import { openHarness, selectComponent } from "./helpers.js";

const dot = (page, n) => page.getByRole("tab", { name: `Slide ${n}` });
const selected = (page, n) =>
  expect(dot(page, n)).toHaveAttribute("aria-selected", "true");

test.beforeEach(async ({ page }) => {
  await page.clock.install();
  await openHarness(page);
  await selectComponent(page, "carousel");
});

test("rotates to the next slide on its own", async ({ page }) => {
  await selected(page, 1);

  await page.clock.runFor(5000);
  await selected(page, 2);

  await page.clock.runFor(5000);
  await selected(page, 3);
});

test("wraps to the first slide", async ({ page }) => {
  await page.clock.runFor(15000);
  await selected(page, 1);
});

test("stops and resumes with the pause control", async ({ page }) => {
  const control = page.getByRole("button", { name: /slide show/ });

  await control.click();
  await page.clock.runFor(15000);
  await selected(page, 1);

  await control.click();
  // Pointer is still on the button; rotation does not resume under it
  await page.mouse.move(0, 0);
  await page.clock.runFor(5000);
  await selected(page, 2);
});
