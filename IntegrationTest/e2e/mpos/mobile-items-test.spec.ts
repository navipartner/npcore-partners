import { test } from "@playwright/test";
import assert from "assert";

import { mobileLogin } from "../fixtures/mobileLogin";

test.describe("Mobile add and remove item, search, payment test", () => {
  test("should be able to add item, open and delete item, search add and delete, add item and do single and multiple payment", async ({
    page,
  }) => {
    await mobileLogin(
      page,
      true,
      "4",
      process.env?.[`E2E_OLD_MPOS_USERNAME`],
      process.env?.[`E2E_OLD_MPOS_PASSWORD`]
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
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Items" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("#page-sale")
      .getByTestId("hamburger")
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Insert Customer$/ })
      .nth(2)
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
      .locator("#page-sale")
      .getByTestId("hamburger")
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Remove Customer$/ })
      .nth(2)
      .click();
    await page.waitForTimeout(2000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Items" })
      .click();
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
      .getByRole("button", { name: "Sale", exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .locator(".toolbar__option--search")
      .click();
    await page
      .frameLocator("iframe")
      .locator("#page-sale")
      .getByTestId("search-input")
      .fill("brownie");
    await page
      .frameLocator("iframe")
      .locator("#page-sale")
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
      .locator(".toolbar__option--search")
      .click();
    await page
      .frameLocator("iframe")
      .locator("#page-sale div")
      .filter({ hasText: "brownie" })
      .nth(3)
      .click();
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
      .getByRole("button", { name: "Payment" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Select payment option" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Cash" })
      .click();
    await page.waitForTimeout(1000);
    const buttonExists = await page.$('button:has-text("OK")');
    if (buttonExists) {
      await page.click('button:has-text("OK")');
    }
    await page.frameLocator("iframe").locator("#button-dialog-ok div").click();
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
    await page.frameLocator("iframe").getByText("Tiramisu Special").click();
    await page
      .frameLocator("iframe")
      .locator(".item-counter > div:nth-child(4)")
      .click();
    await page.waitForTimeout(1000);
    await page.frameLocator("iframe").getByTestId("expanded-item").click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Payment" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Select payment option" })
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Cash" })
      .click();
    await page.waitForTimeout(1000);
    if (buttonExists) {
      await page.click('button:has-text("OK")');
    }
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: "5" })
      .first()
      .click();
    await page.frameLocator("iframe").locator("#button-dialog-ok div").click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Add payment option" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Cash" })
      .click();
    await page.waitForTimeout(1000);
    const secondButtonExists = await page.$('button:has-text("OK")');
    if (secondButtonExists) {
      await page.click('button:has-text("OK")');
    }
    await page.frameLocator("iframe").locator("#button-dialog-ok div").click();
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
      .getByRole("button", { name: "Payment" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Select payment option" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Cash" })
      .click();
    await page.waitForTimeout(1000);
    const thirdButtonExists = await page.$('button:has-text("OK")');
    if (thirdButtonExists) {
      await page.click('button:has-text("OK")');
    }
    await page.frameLocator("iframe").locator("#button-dialog-ok div").click();
    await page.waitForTimeout(2000);
  });
});
