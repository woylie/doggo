import { expect, test } from "@playwright/test";

import { openHarness, patches, selectComponent } from "./helpers.js";

const expanded = (page, id, value) =>
  expect(page.locator(`#${id}`)).toHaveAttribute("aria-expanded", value);

test.describe("tree", () => {
  test.beforeEach(async ({ page }) => {
    await openHarness(page);
    await selectComponent(page, "tree");
  });

  test("keeps an expanded branch expanded through a bump", async ({ page }) => {
    await page.locator("#tree-working > button").click();
    await expanded(page, "tree-working", "true");

    await patches.bump(page);
    await expanded(page, "tree-working", "true");
  });

  test("keeps a collapsed branch collapsed through a patch of a LiveComponent inside the tree", async ({
    page,
  }) => {
    await page.locator("#tree-herding > button").click();
    await expanded(page, "tree-herding", "false");

    await page
      .getByRole("button", { name: "Update the component inside the tree" })
      .click();
    await expect(page.getByText("Collie · component tick 1")).toBeAttached();
    await expanded(page, "tree-herding", "false");
  });

  test("keeps a collapsed branch collapsed through a patch of a LiveComponent around the tree", async ({
    page,
  }) => {
    await page.locator("#tree-toy > button").click();
    await expanded(page, "tree-toy", "false");

    await page
      .getByRole("button", { name: "Update the component around the tree" })
      .click();
    await expect(page.getByText("Pug · component tick 1")).toBeAttached();
    await expanded(page, "tree-toy", "false");
  });

  test("keeps the tab stop through a patch of a LiveComponent inside the tree", async ({
    page,
  }) => {
    await page.locator("#tree-herding").focus();
    await expect(page.locator("#tree-herding")).toHaveAttribute(
      "tabindex",
      "0",
    );

    await page
      .getByRole("button", { name: "Update the component inside the tree" })
      .click();
    await expect(page.getByText("Collie · component tick 1")).toBeAttached();
    await expect(page.locator("#tree-herding")).toHaveAttribute(
      "tabindex",
      "0",
    );
    await expect(
      page.locator('#test-tree [role="treeitem"][tabindex="0"]'),
    ).toHaveCount(1);
  });
});
