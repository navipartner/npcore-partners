import { test } from "@playwright/test";

import { login } from "../fixtures/mobileEditorLogin";
import { mobileLogin } from "../fixtures/mobileLogin";
import { removeLayout } from "../fixtures/removeLayout";

const createBalancingButtonAndDoASale = async (page) => {
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator("svg")
      .click();
    await page.waitForTimeout(1000);
    const balancingText = page
    .frameLocator("iframe")
    .getByText("Confirm Bin Contents.");
  if (await balancingText.isVisible()) {
    await page.frameLocator("iframe").locator("#button-dialog-yes div").click();
  }
    await page
      .frameLocator("iframe")
      .getByTestId("MOBILE_BUTTON_VIEW.COLUMNS")
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(7) > .editable-button__content > .editable-button__button"
      )
      .first()
      .click();
    await page.frameLocator("iframe").getByText("Edit").click();
    await page.frameLocator("iframe").getByRole("textbox").nth(2).click();
    await page
      .frameLocator("iframe")
      .getByRole("textbox")
      .nth(2)
      .fill("balancing");
      await page
      .frameLocator("iframe")
      .getByRole("textbox")
      .nth(2)
      .click()
    await page
      .frameLocator("iframe")
      .getByRole("heading", { name: "Variables" })
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(2) > .css-b62m3t-container > .react-select__control > .react-select__indicators > .react-select__indicator > .css-8mmkcg"
      )
      .first()
      .click();
    await page.frameLocator("iframe").getByText("Other", { exact: true }).click();
    await page.waitForTimeout(1000)
    const searchInput = await page.getByLabel('Search POS Actions').isVisible()
    if(searchInput) {
      await page.getByLabel('Search POS Actions').click();
      await page.getByLabel('Search POS Actions').fill("balance");
      } else {
        await page.getByLabel('Untitled field').click();
        await page.getByLabel('Untitled field')
          .fill("balance");
    }
      const button = await page
      .getByRole("button", { name: "Open menu for Code BALANCE_V4" }).isVisible()
      const gridCell = await page.getByRole('gridcell', { name: 'Code, BALANCE_V4' }).isVisible()
      if(button) {
        await page
      .getByRole("button", { name: "Open menu for Code BALANCE_V4" }).click()
      } else if(gridCell) {
        await page.getByRole('gridcell', { name: 'Code, BALANCE_V4' }).click();
      } else {
        await page.locator('td').filter({ hasText: 'Balance the POS at the end of' }).click();
      }
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(2000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Overwrite current layout" })
      .click();
    await page.waitForTimeout(10000);
    await page.frameLocator('iframe').getByRole('button', { name: 'Small draft beer' }).click();
    await page.frameLocator('iframe').getByRole('button', { name: 'Payment' }).click();
    await page.frameLocator('iframe').getByRole('button', { name: 'Select payment' }).click();
    await page.frameLocator('iframe').getByRole('button', { name: 'Cash' }).click();
    await page.frameLocator("iframe").locator("#button-dialog-ok div").click();
    await page.waitForTimeout(10000);
  };

test.describe("Balancing v4 mobile test 2", () => {
  test("User should be able to do balancing by entering coins amount", async ({
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
    await createBalancingButtonAndDoASale(page);
    await mobileLogin(
      page,
      false,
      salePersonCode,
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
    );
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "balancing" })
      .click();
    await page
      .frameLocator("iframe")
      .getByTestId("counting-settings-button")
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Please select font size: / })
      .locator("svg")
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Small", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Close" })
      .click();
    await page
      .frameLocator("iframe")
      .locator(".balance-counting__coin-count-modal-trigger > button")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(14) > .ui-table__row > div:nth-child(2) > .number-input-wrapper > .number-input-wrapper__main > .number-input-wrapper__input > .number-input"
      )
      .fill("10");
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^DraftClose$/ })
      .getByRole("button", { name: "Close" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: /Finalize/i })
      .click();

    const kButton = page
      .frameLocator("iframe")
      .getByRole("button", { name: /\[\d+\] K/ });
    if (await kButton.isVisible()) {
      await kButton.click();
      await page
        .frameLocator("iframe")
        .locator(".balance-counting__coin-count-modal-trigger > button")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator(
          "div:nth-child(14) > .ui-table__row > div:nth-child(2) > .number-input-wrapper > .number-input-wrapper__main > .number-input-wrapper__input > .number-input"
        )
        .fill("10");
      await page
        .frameLocator("iframe")
        .locator("div")
        .filter({ hasText: /^DraftClose$/ })
        .getByRole("button", { name: "Close" })
        .click();
      await page
        .frameLocator("iframe")
        .getByRole("button", { name: /Finalize/i })
        .click();
    }
    const sekButton = page
      .frameLocator("iframe")
      .getByRole("button", { name: /\[\d+\] SEK/ });
    if (await sekButton.isVisible()) {
      await sekButton.click();
      await page
        .frameLocator("iframe")
        .locator(".balance-counting__coin-count-modal-trigger > button")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator(
          "div:nth-child(14) > .ui-table__row > div:nth-child(2) > .number-input-wrapper > .number-input-wrapper__main > .number-input-wrapper__input > .number-input"
        )
        .fill("10");
      await page
        .frameLocator("iframe")
        .locator("div")
        .filter({ hasText: /^DraftClose$/ })
        .getByRole("button", { name: "Close" })
        .click();
      await page
        .frameLocator("iframe")
        .getByRole("button", { name: /Finalize/i })
        .click();
    }
    const usdButton = page
      .frameLocator("iframe")
      .getByRole("button", { name: /\[\d+\] USD/ });
    if (await usdButton.isVisible()) {
      await usdButton.click();
      await page
        .frameLocator("iframe")
        .locator(".balance-counting__coin-count-modal-trigger > button")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator(
          "div:nth-child(14) > .ui-table__row > div:nth-child(2) > .number-input-wrapper > .number-input-wrapper__main > .number-input-wrapper__input > .number-input"
        )
        .fill("10");
      await page
        .frameLocator("iframe")
        .locator("div")
        .filter({ hasText: /^DraftClose$/ })
        .getByRole("button", { name: "Close" })
        .click();
      await page
        .frameLocator("iframe")
        .getByRole("button", { name: /Finalize/i })
        .click();
    }
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Complete Balancing" })
      .click();
    await page.setViewportSize({ width: 1075, height: 720 });
    await page.goto("/BC/Tablet.aspx?page=6150750&tenant=default");
    const popupLocator = page.locator("[id=b3]");
    if ((await popupLocator.count()) > 0) {
      await page.getByRole("button", { name: "OK" }).click();
    }
    await page.waitForTimeout(5000);
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator("svg")
      .click();
    await removeLayout(page, key);
  });
});
