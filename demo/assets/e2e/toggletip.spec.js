import { expect, test } from "@playwright/test";

import {
  openHarness,
  selectComponent,
  wrapInComprehension,
} from "./helpers.js";

const button = (page) =>
  page.getByRole("button", { name: "About the adoption fee" });
const panel = (page) => page.locator("#test-toggletip-panel");
const isOpen = (page) =>
  panel(page).evaluate((el) => el.matches(":popover-open"));

async function expanded(page) {
  const session = await page.context().newCDPSession(page);
  const { nodes } = await session.send("Accessibility.getFullAXTree");
  const node = nodes.find(
    (n) =>
      n.role?.value === "button" && n.name?.value === "About the adoption fee",
  );
  const property = node.properties?.find((p) => p.name === "expanded");
  return property?.value?.value;
}

test.describe("toggletip", () => {
  test.beforeEach(async ({ page }) => {
    await openHarness(page);
    await selectComponent(page, "toggletip");
  });

  test("reports the panel's state as expanded", async ({
    page,
    browserName,
  }) => {
    test.skip(browserName !== "chromium", "reads the tree through CDP");
    expect(await expanded(page)).toBe(false);
    await button(page).click();
    await expect(panel(page)).toBeVisible();
    expect(await expanded(page)).toBe(true);
  });

  test("announces the panel's text when it opens", async ({ page }) => {
    await button(page).click();
    await expect(page.locator("#test-toggletip [role='status']")).toContainText(
      "The fee covers vaccinations and a microchip.",
    );
    await button(page).click();
    await expect(page.locator("#test-toggletip [role='status']")).toHaveText(
      "",
    );
  });

  test("returns focus to the button on Escape from the panel", async ({
    page,
    browserName,
  }) => {
    await button(page).focus();
    await page.keyboard.press("Enter");
    await expect(panel(page)).toBeVisible();
    await page.keyboard.press(browserName === "webkit" ? "Alt+Tab" : "Tab");
    await expect(
      page.getByRole("link", { name: "How fees are used" }),
    ).toBeFocused();
    await page.keyboard.press("Escape");
    expect(await isOpen(page)).toBe(false);
    await expect(button(page)).toBeFocused();
  });

  test("closes on a click outside", async ({ page }) => {
    await button(page).click();
    await expect(panel(page)).toBeVisible();
    await page.getByRole("heading", { name: "toggletip" }).click();
    expect(await isOpen(page)).toBe(false);
  });

  test("places the panel next to the button", async ({ page }) => {
    await button(page).click();
    await expect(panel(page)).toBeVisible();
    const b = await button(page).boundingBox();
    const p = await panel(page).boundingBox();
    expect(Math.abs(p.y - (b.y + b.height))).toBeLessThan(40);
    expect(Math.abs(p.x - b.x)).toBeLessThan(40);
  });

  const push = (page, event) =>
    page.evaluate(
      (event) =>
        window.liveSocket.execJS(
          document.body,
          JSON.stringify([["push", { event }]]),
        ),
      event,
    );

  test("stays open through a patch", async ({ page }) => {
    await button(page).click();
    await expect(panel(page)).toBeVisible();
    const before = await page.locator("#tick").innerText();

    await push(page, "bump");

    await expect(page.locator("#tick")).not.toHaveText(before);
    expect(await isOpen(page)).toBe(true);
  });

  test("stays open through a re-send while wrapped", async ({ page }) => {
    await wrapInComprehension(page);
    await button(page).click();
    await expect(panel(page)).toBeVisible();

    await push(page, "resend");

    await expect(page.getByText("re-sends 1")).toBeVisible();
    expect(await isOpen(page)).toBe(true);
  });

  test("closes on Escape inside a dialog without closing the dialog", async ({
    page,
  }) => {
    await selectComponent(page, "modal");
    await page.getByRole("button", { name: "Open modal" }).click();
    await expect(page.locator("#test-modal")).toBeVisible();

    const inner = page.getByRole("button", { name: "About the modal" });
    await inner.click();
    await expect(page.locator("#test-modal-toggletip-panel")).toBeVisible();

    await page.keyboard.press("Escape");

    expect(
      await page
        .locator("#test-modal-toggletip-panel")
        .evaluate((el) => el.matches(":popover-open")),
    ).toBe(false);
    await expect(page.locator("#test-modal")).toHaveAttribute("open", "");
  });
});
