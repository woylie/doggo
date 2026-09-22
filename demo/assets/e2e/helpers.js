import { expect } from "@playwright/test";

const tick = (page) => page.locator("#tick");

export async function openHarness(page) {
  await page.goto("/patch-test");
  await page.waitForFunction(() => window.liveSocket?.isConnected());
}

export async function selectComponent(page, value) {
  await expect(async () => {
    await page.locator("#component").selectOption(value);
    await expect(page.getByRole("heading", { level: 2 })).toHaveText(value, {
      timeout: 1000,
    });
  }).toPass({ timeout: 15000 });
}

export const patches = {
  async bump(page) {
    const before = Number(await tick(page).innerText());
    await page.getByRole("button", { name: "Bump" }).click();
    await expect(tick(page)).toHaveText(String(before + 1));
  },

  async bumpFromOutside(page) {
    await page.getByRole("button", { name: "Move tick outside" }).click();
    await expect(page.getByText("tick inside components false")).toBeVisible();
    await patches.bump(page);
  },

  async roundTrip(page) {
    await page.getByRole("button", { name: "Round trip" }).click();
    await page.waitForTimeout(100);
  },
};

export const patchesFromInsideDialog = {
  async bumpFromInside(page) {
    const before = Number(await tick(page).innerText());
    await page.getByRole("button", { name: "Bump from inside" }).click();
    await expect(tick(page)).toHaveText(String(before + 1));
  },

  async resendFromInside(page) {
    await page.getByRole("button", { name: "Re-send from inside" }).click();
  },
};

export async function wrapInComprehension(page) {
  await page.getByRole("button", { name: "Wrap in a comprehension" }).click();
  await expect(page.getByText("wrapped true")).toBeVisible();
}

export async function resend(page) {
  await page.getByRole("button", { name: "Re-send" }).click();
  await expect(page.getByText("re-sends 1")).toBeVisible();
}
