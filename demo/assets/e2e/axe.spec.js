import { readdirSync } from "node:fs";
import { join } from "node:path";

import AxeBuilder from "@axe-core/playwright";
import { expect, test } from "@playwright/test";

const storybookDir = new URL("../../storybook", import.meta.url).pathname;

const storyPaths = (dir = storybookDir, prefix = "") =>
  readdirSync(dir, { withFileTypes: true }).flatMap((entry) =>
    entry.isDirectory()
      ? storyPaths(join(dir, entry.name), `${prefix}${entry.name}/`)
      : entry.name.endsWith(".story.exs")
        ? [`${prefix}${entry.name.replace(/\.story\.exs$/, "")}`]
        : [],
  );

// A story page renders every variation of a component at once. Landmarks
// in a story can therefore share a page and a name.
const known = {
  "data/accordion": ["landmark-unique"],
  "layout/app_bar": ["landmark-no-duplicate-banner", "landmark-unique"],
  "layout/drawer": ["landmark-unique"],
  "layout/page_header": ["landmark-no-duplicate-banner", "landmark-unique"],
  "media/carousel": ["landmark-unique"],
  "feedback/callout": ["landmark-unique"],
  "navigation/bottom_navigation": ["landmark-unique"],
  "navigation/navbar": ["landmark-unique"],
  "navigation/steps": ["landmark-unique"],
  "navigation/vertical_nav": ["landmark-unique"],
};

for (const story of storyPaths()) {
  test(`${story} has no axe violations`, async ({ page }) => {
    await page.goto(`/storybook/${story}`);
    await page.locator(".psb-sandbox").first().waitFor();

    const { violations } = await new AxeBuilder({ page })
      .include(".psb-sandbox")
      .analyze();

    expect(violations.map((v) => v.id).sort()).toEqual(known[story] ?? []);
  });
}
