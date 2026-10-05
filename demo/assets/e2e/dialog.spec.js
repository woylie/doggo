import { expect, test } from "@playwright/test";

import { openHarness } from "./helpers.js";

const isModal = (dialog) => dialog.evaluate((el) => el.matches(":modal"));

const moves = [
  {
    name: "in a keyed comprehension",
    opener: "Open the reorder modal",
    dialog: "#test-modal-reorder",
    control: "Reorder from inside",
    async moved(page) {
      await expect(page.locator("[id^=reorder-]").first()).toHaveId(
        "reorder-dialog",
      );
    },
  },
  {
    name: "in a live component",
    opener: "Open the modal in a component",
    dialog: "#test-modal-in-component",
    control: "Toggle the note from inside",
    async moved(page) {
      await expect(page.locator("#note")).toBeVisible();
    },
  },
];

test.describe("modal", () => {
  for (const move of moves) {
    test(`stays modal when a patch moves it ${move.name}`, async ({ page }) => {
      await openHarness(page);
      const opener = page.getByRole("button", { name: move.opener });
      const dialog = page.locator(move.dialog);
      const control = dialog.getByRole("button", { name: move.control });

      await opener.press("Enter");
      await expect(dialog).toBeVisible();
      await control.press("Enter");
      await move.moved(page);

      await expect.poll(() => isModal(dialog)).toBe(true);
      await expect(control).toBeFocused();

      await page.keyboard.press("Escape");
      await expect(dialog).toBeHidden();
      await expect(opener).toBeFocused();
    });
  }

  test("keeps a dialog opened over it on top when a patch moves it", async ({
    page,
  }) => {
    await openHarness(page);
    const lower = page.locator("#test-modal-reorder");
    const upper = page.locator("#test-modal-in-component");
    const control = upper.getByRole("button", {
      name: "Toggle the note from inside",
    });

    await page
      .getByRole("button", { name: "Open the reorder modal" })
      .press("Enter");
    await upper.evaluate((el) =>
      el.dispatchEvent(new CustomEvent("doggo:open", { bubbles: true })),
    );
    await expect.poll(() => isModal(upper)).toBe(true);
    await control.focus();

    await lower.evaluate((el) => {
      const item = el.parentElement;
      item.parentElement.append(item);
    });

    await expect.poll(() => isModal(lower)).toBe(true);
    await expect(control).toBeFocused();
    const box = await control.boundingBox();
    const hit = await page.evaluate(
      ({ x, y }) => document.elementFromPoint(x, y)?.closest("dialog")?.id,
      { x: box.x + box.width / 2, y: box.y + box.height / 2 },
    );
    expect(hit).toBe("test-modal-in-component");

    await page.keyboard.press("Escape");
    await expect(upper).toBeHidden();
    await page.keyboard.press("Escape");
    await expect(lower).toBeHidden();
    await expect(
      page.getByRole("button", { name: "Open the reorder modal" }),
    ).toBeFocused();
  });

  test("leaves a dialog opened with show() non-modal", async ({ page }) => {
    await openHarness(page);
    const dialog = page.locator("#test-modal-reorder");

    await page.getByRole("button", { name: "Open the reorder modal" }).click();
    await expect.poll(() => isModal(dialog)).toBe(true);

    await dialog.evaluate(async (el) => {
      el.close();
      el.show();
      document.body.append(document.createElement("p"));
      await new Promise((resolve) => setTimeout(resolve));
      document.body.append(document.createElement("p"));
      await new Promise((resolve) => setTimeout(resolve));
    });

    await expect(dialog).toBeVisible();
    await expect.poll(() => isModal(dialog)).toBe(false);
  });
});
