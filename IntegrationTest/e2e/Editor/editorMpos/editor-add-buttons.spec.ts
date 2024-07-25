import { test } from "@playwright/test";

import { login } from "../../fixtures/mobileEditorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.describe("Mobile add and remove editable buttons", () => {
  test("should be able to add new button to mobile items, and drawer, asign it an item action, add item to sale and delete it", async ({
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
      .getByRole("contentinfo")
      .locator("svg")
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(6) > .editable-button__content > .editable-button__button"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Edit", { exact: true })
      .click();
    await page.frameLocator("iframe").getByRole("textbox").nth(2).click();
    await page
      .frameLocator("iframe")
      .getByRole("textbox")
      .nth(2)
      .fill("e2e test button");
    await page.frameLocator("iframe").getByRole("textbox").nth(2).click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(2) > .css-b62m3t-container > .react-select__control"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Add Item to Order", { exact: true })
      .click();
    await page.waitForTimeout(1000);
    await page
      .getByRole("button", { name: "Open menu for No. 1000", exact: true })
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
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
      .getByRole("button", { name: "e2e test button" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "1 Sale" })
      .click();
    await page.frameLocator("iframe").getByText("Bicycle").click();
    await page
      .frameLocator("iframe")
      .locator(".item-counter__button")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator("svg")
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .locator(".toolbar__option")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(5) > .editable-button__content > .editable-button__button"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Edit", { exact: true })
      .click();
    await page.frameLocator("iframe").getByRole("textbox").nth(2).click();
    await page
      .frameLocator("iframe")
      .getByRole("textbox")
      .nth(2)
      .fill("e2e test button");
    await page.frameLocator("iframe").getByRole("textbox").nth(2).click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(2) > .css-b62m3t-container > .react-select__control"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Add Item to Order", { exact: true })
      .click();
    await page.waitForTimeout(1000);
    await page
      .getByRole("button", { name: "Open menu for No. 1000", exact: true })
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
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
      .getByRole("button", { name: "e2e test button" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "1 Sale" })
      .click();
    await page.frameLocator("iframe").getByText("Bicycle").click();
    await page
      .frameLocator("iframe")
      .locator(".item-counter__button")
      .first()
      .click();
    await removeLayout(page, key);
  });
  test("should be able to add new button to sale item, asign it an item action and execute action on sale item", async ({
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
      .getByRole("contentinfo")
      .locator("svg")
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Sale", exact: true })
      .click();
    await page.waitForTimeout(10000);

    await page
      .frameLocator("iframe")
      .locator(
        ".data-grid__editable-menu > div > .editable-button-grid > div > .editable-button__content > .editable-button__button"
      )
      .first()
      .click();

    await page
      .frameLocator("iframe")
      .getByText("Clear", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        ".data-grid__editable-menu > div > .editable-button-grid > div > .editable-button__content > .editable-button__button"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Edit", { exact: true })
      .click();

    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(2) > .css-b62m3t-container > .react-select__control"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Other", { exact: true })
      .click();
    await page.waitForTimeout(3000);

    await page.getByRole("textbox", { name: "Search POS Actions" }).click();
    await page
      .getByRole("textbox", { name: "Search POS Actions" })
      .fill("discount");
    await page
      .getByRole("button", { name: "Open menu for Code DISCOUNT" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("heading", { name: "Variables" })
      .locator("path")
      .click();
    await page.frameLocator('iframe').locator('div').filter({ hasText: /^Discount TypeDiscount TypeOption\.\.\.$/ }).getByRole('button').click();
    await page.frameLocator('iframe').getByRole('button', { name: '... TotalAmount' }).click();
    await page.frameLocator('iframe').locator('button.ui-button.ui-button--medium.ui-button--primary:has-text("Save")').click();
    await page.frameLocator("iframe").getByText("Icon").click();
    await page.frameLocator("iframe").locator(".select__indicator").click();
    await page
      .frameLocator("iframe")
      .locator("#react-select-10-option-0 div")
      .filter({ hasText: "0" })
      .locator("div")
      .click();
    await page.frameLocator("iframe").getByTitle("#800080").click();
    await page.frameLocator("iframe").getByText("Icon").click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .nth(1)
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
      .getByRole("button", { name: "Items" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Small draft beer" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "1 Sale" })
      .click();
    const element = await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Small Draft Beer$/ })
      .first();
    const startLocation = await element.boundingBox();
    if (startLocation) {
      const startX = startLocation.x;
      const startY = startLocation.y + startLocation.height / 2;
      const endX = startX - 300;
      const endY = startY;
      await page.mouse.move(startX, startY);
      await page.mouse.down();
      await page.mouse.move(endX, endY, { steps: 10 });
    }
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Small Draft Beer1Quantity35totalTotal35$/ })
      .getByRole("button")
      .first()
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: "5" })
      .first()
      .click();
    await page.frameLocator("iframe").locator("#button-dialog-ok div").click();
    await page.waitForTimeout(1000);
    if (startLocation) {
      const startX = startLocation.x;
      const startY = startLocation.y + startLocation.height / 2;
      const endX = startX + 100;
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
    await removeLayout(page, key);
  });
  test("should be able to add 5 buttons to items and then clear them", async ({
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
      .locator("svg")
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(6) > .editable-button__content > .editable-button__button"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Edit", { exact: true })
      .click();
    await page.frameLocator("iframe").getByRole("textbox").nth(2).click();
    await page.frameLocator("iframe").getByRole("textbox").nth(2).fill("A");
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(7) > .editable-button__content > .editable-button__button"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Edit", { exact: true })
      .click();
    await page.frameLocator("iframe").getByRole("textbox").nth(2).click();
    await page.frameLocator("iframe").getByRole("textbox").nth(2).fill("B");
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .nth(1)
      .click();
    await page.waitForTimeout(3000);
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "A", exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Clear", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "B", exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Clear", { exact: true })
      .click();
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
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator("div")
      .nth(1)
      .click();
    await removeLayout(page, key);
  });
});
