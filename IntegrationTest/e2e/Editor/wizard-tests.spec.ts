import { expect, test } from "@playwright/test";

import { login } from "../fixtures/editorLogin";
import { removeLayout } from "../fixtures/removeLayout";

test.describe("Wizard modal tests", () => {
  test("testing wizard modal render", async ({ page }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
    const salePersonCode = (workerInfo.parallelIndex + 1).toString();
    await login(
      page,
      salePersonCode,
      key,
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
    );
    await page.frameLocator("iframe").locator('svg[data-icon="gear"]').click();
    await page.frameLocator("iframe").locator("button:nth-child(16)").click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Attractions$/ })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Continue" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^english$/ })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Continue" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Attraction 1$/ })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Continue" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Continue" })
      .click();
    await page.waitForTimeout(1000);
    await expect(
      page.frameLocator("iframe").getByText("Choose Category")
    ).not.toBeVisible();
    await expect(
      page.frameLocator("iframe").getByRole("button", { name: "Close Wizard" })
    ).not.toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Overwrite current layout" })
      .click();
    await page.waitForTimeout(3000);
    await removeLayout(page, key);
  });
});
