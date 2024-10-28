import { test } from "@playwright/test";

import { login } from "../../fixtures/mobileEditorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.describe("Mobile add and remove item from test 2", () => {
  test("should be able to add item, change quantity and remove", async ({
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
      .getByRole("button", { name: "Small Draft Beer" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "1 Sale" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Small Draft Beer$/ })
      .first()
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .locator(".item-counter > div:nth-child(4)")
      .click();
    await page.waitForTimeout(2000);
    await page
      .frameLocator("iframe")
      .locator(".item-counter > div:nth-child(2)")
      .click();
    await page.waitForTimeout(2000);
    await page.frameLocator("iframe").getByText("1").nth(2).click();
    await page.frameLocator("iframe").locator("#button6 div").click();
    await page.frameLocator("iframe").locator("#button-dialog-ok div").click();
    await page
    .frameLocator("iframe")
    .locator(".item-counter__button")
    .first()
    .click();
    await page.waitForTimeout(2000);
    await removeLayout(page, key);
  });
  test("should be able to search item, add and remove", async ({
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
      .getByRole("button", { name: "Sale", exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByTestId("MOBILE_BUTTON_OTHER.SEARCH")
      .click();
    await page
      .frameLocator("iframe")
      .getByTestId("search-input")
      .fill("brownie");
    await page
      .frameLocator("iframe")
      .getByTestId("search-input")
      .press("Enter");
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Item No\. 50010BrowniePrice: 90$/ })
      .first()
      .click();
    await page
      .locator('td').filter({ hasText: 'Br:PEANUTS Gm:40' })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "1 Sale" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Brownie$/ })
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator(".item-counter__button")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByTestId("MOBILE_BUTTON_OTHER.SEARCH")
      .click();
    await page.frameLocator("iframe").getByText("brownie").click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Item No\. 50010BrowniePrice: 90$/ })
      .first()
      .click();
    await page
      .locator('td').filter({ hasText: 'Br:PEANUTS Gm:40' })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "1 Sale" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Brownie$/ })
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator(".item-counter__button")
      .first()
      .click();
    await page.waitForTimeout(2000);
    await removeLayout(page, key);
  });
});
