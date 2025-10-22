import { test } from "@playwright/test";
import assert from "assert";

import { login } from "../../fixtures/mobileEditorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.skip()

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
      await page.waitForTimeout(2000);
      const customerText =  await page.getByRole('gridcell', { name: 'Open menu for No. 01121212' }).isVisible();
  
        if (customerText) {
          await page.getByRole('gridcell', { name: 'Open menu for No. 01121212' }).click();
        } 
       else {
        await page.locator('td').filter({ hasText: '01121212' }).click();
      }
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
});
