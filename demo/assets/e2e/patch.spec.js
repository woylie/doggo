import { expect, test } from "@playwright/test";

import {
  openHarness,
  patches,
  patchesFromInsideDialog,
  resend,
  selectComponent,
  wrapInComprehension,
} from "./helpers.js";

const components = [
  {
    name: "modal",
    patches: patchesFromInsideDialog,
    async arrange(page) {
      await page.getByRole("button", { name: "Open modal" }).click();
      await expect(page.locator("#test-modal")).toBeVisible();
    },
    async assert(page) {
      await expect(page.locator("#test-modal")).toBeVisible();
      await expect(page.locator("#test-modal")).toHaveAttribute("open", "");
    },
  },
  {
    name: "alert_dialog",
    patches: patchesFromInsideDialog,
    async arrange(page) {
      await page.getByRole("button", { name: "Open alert dialog" }).click();
      await expect(page.locator("#test-alert-dialog")).toBeVisible();
    },
    async assert(page) {
      await expect(page.locator("#test-alert-dialog")).toHaveAttribute(
        "open",
        "",
      );
    },
  },
  {
    name: "carousel",
    async arrange(page) {
      await page.getByRole("tab", { name: "Slide 2" }).click();
      await expect(page.getByRole("tab", { name: "Slide 2" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    },
    async assert(page) {
      await expect(page.getByRole("tab", { name: "Slide 2" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
    },
  },
  {
    name: "tabs",
    async arrange(page) {
      await page.getByRole("tab", { name: "Second" }).click();
    },
    async assert(page) {
      await expect(page.getByRole("tab", { name: "Second" })).toHaveAttribute(
        "aria-selected",
        "true",
      );
      await expect(page.getByText("Second panel.")).toBeVisible();
    },
  },
  {
    name: "accordion",
    async arrange(page) {
      await page.getByRole("button", { name: "Section one" }).click();
      await expect(
        page.getByRole("button", { name: "Section one" }),
      ).toHaveAttribute("aria-expanded", "false");
    },
    async assert(page) {
      await expect(
        page.getByRole("button", { name: "Section one" }),
      ).toHaveAttribute("aria-expanded", "false");
    },
  },
  {
    name: "split_pane",
    async arrange(page) {
      const separator = page.getByRole("separator");
      await separator.focus();
      await page.keyboard.press("ArrowRight");
      await expect(separator).not.toHaveAttribute("aria-valuenow", "30");
    },
    async assert(page) {
      await expect(page.getByRole("separator")).not.toHaveAttribute(
        "aria-valuenow",
        "30",
      );
    },
  },
  {
    name: "disclosure_button",
    async arrange(page) {
      await page.getByRole("button", { name: "Toggle details" }).click();
      await expect(page.locator("#test-disclosure")).toBeVisible();
    },
    async assert(page) {
      await expect(page.locator("#test-disclosure")).toBeVisible();
      await expect(
        page.getByRole("button", { name: "Toggle details" }),
      ).toHaveAttribute("aria-expanded", "true");
    },
  },
  {
    name: "toggle_button",
    async arrange(page) {
      await page.getByRole("button", { name: "Toggle" }).click();
      await expect(
        page.getByRole("button", { name: "Toggle" }),
      ).toHaveAttribute("aria-pressed", "true");
    },
    async assert(page) {
      await expect(
        page.getByRole("button", { name: "Toggle" }),
      ).toHaveAttribute("aria-pressed", "true");
    },
  },
];

for (const component of components) {
  test.describe(component.name, () => {
    test.beforeEach(async ({ page }) => {
      await openHarness(page);
      await selectComponent(page, component.name);
    });

    for (const [kind, patch] of Object.entries(component.patches ?? patches)) {
      test(`keeps its state through ${kind}`, async ({ page }) => {
        await component.arrange(page);
        await patch(page);
        await component.assert(page);
      });
    }

    if (!component.patches) {
      test("keeps its state through a re-send while wrapped", async ({
        page,
      }) => {
        await wrapInComprehension(page);
        await component.arrange(page);

        await resend(page);
        await component.assert(page);
      });
    }
  });
}
