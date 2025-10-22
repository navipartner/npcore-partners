import { expect, test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.skip()

test.describe("Edit Mode Bar tests", () => {
  test("user should be able to show/hide sale lines column", async ({
    page,
  }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
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
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Sale Lines" })
      .click();
      await page.frameLocator("iframe").getByLabel("Quantity").uncheck();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Sale Lines" })
      .click()
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Overwrite current layout" })
      .click();
    await page.waitForTimeout(5000);
    await removeLayout(page, key);
  });
  test("user should be able to update Totals columns", async ({
    page,
  }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
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
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Totals" })
      .click();
      await page.frameLocator('iframe').getByLabel('AmountExclVAT').uncheck();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Totals" })
      .click();
    await expect(
      page.frameLocator("iframe").getByText("Amount Excl VAT")
    ).not.toBeVisible();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Totals" })
      .click();
      await page.frameLocator('iframe').getByLabel('AmountExclVAT').check();
      await page.frameLocator('iframe').getByRole('button', { name: 'AmountExclVAT' }).getByRole('textbox').click();
      await page.frameLocator('iframe').getByRole('button', { name: 'AmountExclVAT' }).getByRole('textbox').fill("testing amount");
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Totals" })
      .click();
    await expect(
      page.frameLocator("iframe").getByText("testing amount")
    ).toBeVisible();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Overwrite current layout" })
      .click();
    await page.waitForTimeout(5000);
    await expect(
      page.frameLocator("iframe").getByText("testing amount")
    ).toBeVisible();
    await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
    await removeLayout(page, key);
  });
  test("user should be able to show/hide footer columns and update its name", async ({
    page,
  }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
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
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Footer" })
      .click();
      await page.frameLocator('iframe').getByRole('button', { name: 'SalespersonName' }).getByRole('textbox').click()
      await page.frameLocator('iframe').getByRole('button', { name: 'SalespersonName' }).getByRole('textbox').fill("testing footer");
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Footer", exact: true })
      .click();
    await expect(
      page.frameLocator("iframe").getByText("testing footer")
    ).toBeVisible();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Overwrite current layout" })
      .click();
    await page.frameLocator("iframe").locator(".ui-modal__body").isHidden();
    await expect(
      page.frameLocator("iframe").getByText("testing footer")
    ).toBeVisible();
    await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
    await removeLayout(page, key);
  });
  test("user should be able to show/hide product panel", async ({
    page,
  }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
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
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Product Panel" })
      .click();
    await page.frameLocator("iframe").getByLabel("Quantity").check();
    await page.frameLocator("iframe").getByLabel("Quantity").uncheck();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Product Panel" })
      .click();
    await expect(
      page
        .frameLocator("iframe")
        .locator("div")
        .filter({ hasText: /^Quantity$/ })
        .first()
    ).toBeHidden();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Product Panel" })
      .click();
    await page.frameLocator("iframe").getByLabel("Quantity").check();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Product Panel" })
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Overwrite current layout" })
      .click();
    await page.waitForTimeout(5000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Delete Line" })
      .click();
    await expect(
      page
        .frameLocator("iframe")
        .getByRole("cell", { name: "Small Draft Beer" })
    ).toBeHidden();
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Test Items" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Small Draft Beer" })
      .click();
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
      .getByRole("button", { name: "Cancel Sale" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: "Yes" })
      .first()
      .click();
    await page.waitForTimeout(2000);
    await removeLayout(page, key);
  });
});
