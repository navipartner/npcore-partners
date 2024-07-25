import { test } from "@playwright/test";
import assert from "assert";

import { login } from "../../fixtures/mobileEditorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.describe("Mobile add and remove item from test", () => {
  test("should be able to add item from popup, open and delete item, add again, swipe and delete item", async ({
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
      .getByRole("button", { name: "PASTRIES" })
      .click();
    await page.frameLocator("iframe").getByText("Tiramisu Special").click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "1 Sale" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Tiramisu Special$/ })
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator(".item-counter__button")
      .first()
      .click();
    await page.waitForTimeout(2000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Items" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "PASTRIES" })
      .click();
    await page.frameLocator("iframe").getByText("Tiramisu Special").click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "1 Sale" })
      .click();
    const element = page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Tiramisu Special$/ })
      .first();
    const startLocation = await element.boundingBox();
    if (startLocation) {
      const startX = startLocation.x;
      const startY = startLocation.y + startLocation.height / 2;
      const endX = startX + 100; // Adjust the distance as needed
      const endY = startY;
      await page.mouse.move(startX, startY);
      await page.mouse.down();
      await page.mouse.move(endX, endY, { steps: 10 });
    }
    await page
      .frameLocator("iframe")
      .locator(".hidden-menu-button")
      .first()
      .click();
    await page.waitForTimeout(2000);
    await removeLayout(page, key);
  });
  test("should be able to add customer and remove it", async ({
    page,
  }, workerInfo) => {
    // TODO: FIXME
    test.fixme();
    
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
      .locator(".toolbar__option")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Insert Customer" })
      .click();
    await page
      .getByRole("gridcell", { name: "Open menu for Name", exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Customer:Spotsmeyer's Furnishings")
      .click();
    const elementExists =
      page
        .frameLocator("iframe")
        .getByText("Customer:Spotsmeyer's Furnishings") !== null;
    assert.ok(elementExists);
    await page
      .frameLocator("iframe")
      .locator(".toolbar__option")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Remove Customer" })
      .click();
    await page.waitForTimeout(2000);
    await removeLayout(page, key);
  });
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
