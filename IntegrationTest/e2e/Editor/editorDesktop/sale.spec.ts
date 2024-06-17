import { expect, test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.describe("Sale test", () => {
  test("testing a sale of small draft beer", async ({ page }, workerInfo) => {
    const key = new Date().getTime();
    const salePersonCode = (workerInfo.parallelIndex + 1).toString();
    await login(
      page,
      salePersonCode,
      key,
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
    );
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Test Items" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Small Draft Beer" })
      .click();
    await expect(
      page
        .frameLocator("iframe")
        .getByRole("cell", { name: "Small Draft Beer" })
    ).toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Delete Line" })
      .click();
    await expect(
      page
        .frameLocator("iframe")
        .getByRole("cell", { name: "Small Draft Beer" })
    ).toBeHidden();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Test Items" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Small Draft Beer" })
      .click();
    await expect(
      page
        .frameLocator("iframe")
        .getByRole("cell", { name: "Small Draft Beer" })
    ).toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Go to Payment" })
      .click();
    await page.waitForTimeout(2000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Cash Payment" })
      .click();
    await page.frameLocator("iframe").locator("#button6 div").click();
    await page.frameLocator("iframe").locator("#button13 div").click();
    await page.frameLocator("iframe").locator("#button-dialog-ok div").click();
    await expect(
      page
        .frameLocator("iframe")
        .locator("div")
        .filter({ hasText: /^Last Sale$/ })
    ).toBeVisible();
    await expect(
      page.frameLocator("iframe").getByText("Total 35")
    ).toBeVisible();
    await expect(
      page.frameLocator("iframe").getByText("Total Paid50")
    ).toBeVisible();
    await expect(
      page.frameLocator("iframe").getByText("Change -15")
    ).toBeVisible();
    await removeLayout(page, key);
  });
});
