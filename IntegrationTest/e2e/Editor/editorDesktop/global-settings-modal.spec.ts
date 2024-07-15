import { expect, test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.describe("Global settings modal tests", () => {
  test("testing render of global settings modal", async ({
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
    await page.frameLocator('iframe').locator('button:nth-child(16)').click();
    await page.waitForTimeout(2000);
    expect(
      page.frameLocator("iframe").getByText("Global Settings", { exact: true })
    ).toBeVisible();
    await page.frameLocator('iframe').locator('button:nth-child(16)').click();
    expect(
      page.frameLocator("iframe").getByText("Global Settings", { exact: true })
    ).not.toBeVisible();
    await page.frameLocator('iframe').locator('button:nth-child(16)').click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Close" })
      .click();
    await page.waitForTimeout(2000);
    expect(
      page.frameLocator("iframe").getByText("Global Settings", { exact: true })
    ).not.toBeVisible();
    await removeLayout(page, key);
  });
});
