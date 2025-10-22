import { expect, test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.skip()

test.describe("Top bar tests", () => {
  test("footer display tests", async ({ page }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
    const salePersonCode = (workerInfo.parallelIndex + 1).toString();
    await login(
      page,
      salePersonCode,
      key,
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
    );
    await expect(
      page
        .frameLocator("iframe")
        .getByRole("contentinfo")
        .locator('svg[data-icon="gear"]')
    ).toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await expect(
      page.frameLocator("iframe").getByRole("button", { name: "Sale Lines" })
    ).toBeVisible();
    await expect(
      page.frameLocator("iframe").getByRole("button", { name: "Totals" })
    ).toBeVisible();
    await expect(
      page.frameLocator("iframe").getByRole("button", { name: "Product Panel" })
    ).toBeVisible();
    await expect(
      page.frameLocator("iframe").getByRole("button", { name: "Footer" })
    ).toBeVisible();
    await expect(
      page.frameLocator("iframe").getByRole("button", { name: "Delete Layout" })
    ).toBeVisible();
    await expect(
      page.frameLocator("iframe").getByRole("button", { name: "New Layout" })
    ).toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Sale Lines" })
      .click();
    await expect(
      page.frameLocator("iframe").locator(".column-picker__filtering-tooltip")
    ).toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Sale Lines" })
      .click();
    await expect(
      page.frameLocator("iframe").locator(".column-picker__filtering-tooltip")
    ).toBeHidden();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Totals" })
      .click();
    await expect(
      page.frameLocator("iframe").locator(".column-picker__filtering-tooltip")
    ).toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Totals" })
      .click();
    await expect(
      page.frameLocator("iframe").locator(".column-picker__filtering-tooltip")
    ).toBeHidden();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Product Panel" })
      .click();
    await expect(
      page.frameLocator("iframe").locator(".column-picker__filtering-tooltip")
    ).toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Product Panel" })
      .click();
    await expect(
      page.frameLocator("iframe").locator(".column-picker__filtering-tooltip")
    ).toBeHidden();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Footer" })
      .click();
    await expect(
      page.frameLocator("iframe").locator(".column-picker__filtering-tooltip")
    ).toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Footer" })
      .click();
    await expect(
      page.frameLocator("iframe").locator(".column-picker__filtering-tooltip")
    ).toBeHidden();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Sale Lines" })
      .click();
    await expect(
      page.frameLocator("iframe").locator(".column-picker__filtering-tooltip")
    ).toBeVisible();
    await page.frameLocator("iframe").getByLabel("Small").check();
    await expect(
      page.frameLocator("iframe").locator(".pos-editor__edit-mode-warning")
    ).toBeVisible();
    await expect(
      page.frameLocator("iframe").getByRole("button", { name: "Clear" })
    ).toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Clear" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: "Yes" })
      .first()
      .click();
    await expect(
      page.frameLocator("iframe").locator(".pos-editor__edit-mode-warning")
    ).toBeHidden();
    await removeLayout(page, key);
  });
});
