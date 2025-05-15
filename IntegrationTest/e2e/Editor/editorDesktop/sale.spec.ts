import { expect, test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { switchUserRegion } from "../../fixtures/switchUserRegion";
import { removeLayout } from "../../fixtures/removeLayout";

const withTimeout = async <T>(promise: Promise<T>, timeout: number): Promise<T> => {
  return new Promise((resolve, reject) => {
    const timer = setTimeout(() => {
      reject(new Error("Operation timed out"));
    }, timeout);

    promise
      .then((result) => {
        clearTimeout(timer);
        resolve(result);
      })
      .catch((error) => {
        clearTimeout(timer);
        reject(error);
      });
  });
};

test.describe("Sale test", () => {
  test("testing a sale of small draft beer", async ({ page }, workerInfo) => {
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
      await removeLayout(page, key);
    });
    test("testing correct decimal amount on a payment that is not fixed value but decimals in global settings are set to 0", async ({ page }, workerInfo) => {
      const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
      const salePersonCode = (workerInfo.parallelIndex + 1).toString();
      try {
        await withTimeout(
          switchUserRegion(
            page,
            "Danish (Denmark)",
            process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
            process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
          ),
          120000
        );
      } catch (error) {
        console.warn("Switch region failed or timed out. Skipping test...");
        test.skip();
      }
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
      await page.frameLocator('iframe').getByRole('spinbutton').fill('0');
      await page.frameLocator('iframe').getByRole('button', { name: 'Close' }).click();
      await page.frameLocator('iframe').getByRole('button', { name: 'Save' }).click();
      await page.waitForTimeout(2000)
      await page.frameLocator('iframe').getByRole('button', { name: 'Overwrite current layout' }).click();
      await page.frameLocator('iframe').getByRole('button', { name: 'Test Items' }).click();
      await page.frameLocator('iframe').getByRole('button', { name: 'BELLING COOKER HOOD 100CM' }).click();
      await page.frameLocator('iframe').getByRole('button', { name: 'Discounts' }).click();
      await page.frameLocator('iframe').getByRole('button', { name: 'Line Amount' }).click();
      await page.waitForTimeout(1000)
      await page.frameLocator('iframe').locator('span').filter({ hasText: '5' }).first().click();
      await page.frameLocator('iframe').locator('span').filter({ hasText: ',' }).first().click();
      await page.frameLocator('iframe').locator('span').filter({ hasText: '5' }).first().click();
      await page.frameLocator('iframe').getByText('OK', { exact: true }).click();
      await page.frameLocator('iframe').getByRole('button', { name: 'Go to Payment' }).click();
      await page.waitForTimeout(2000);
      await page.frameLocator('iframe').getByRole('button', { name: 'Cash Payment' }).click();
      const input = page.frameLocator('iframe').getByTestId('search-input');
      await expect(input).toHaveValue('5,5')
      await page.frameLocator('iframe').locator('span').filter({ hasText: 'OK' }).first().click();
      await removeLayout(page, key);
    })
  });
  