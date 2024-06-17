import { test } from "@playwright/test";

import { login } from "../fixtures/editorLogin";
import { removeLayout } from "../fixtures/removeLayout";

test.describe("Balancing v4 test", () => {
  test("User should be able to do balancing by entering amounts in inputs", async ({
    page,
  }, workerInfo) => {
    const key = new Date().getTime();
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
      .getByRole("button", { name: "Other functions" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "End Of Day Balancing (Balance V4)" })
      .click();
    await page.waitForTimeout(2000);
    await page
      .frameLocator("iframe")
      .locator(
        ".balance-counting__coin-count-modal-trigger > .number-input-wrapper > .number-input-wrapper__main > .number-input-wrapper__input > .number-input"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator("#view-balance")
      .getByText("1", { exact: true })
      .click();
    await page.frameLocator("iframe").locator("div:nth-child(11)").click();
    await page.frameLocator("iframe").locator("div:nth-child(11)").click();
    await page.frameLocator("iframe").locator("div:nth-child(11)").click();
    await page.frameLocator("iframe").locator("div:nth-child(11)").click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({
        hasText:
          /^Bank DepositBank Deposit Amount Bank Deposit Bin CodeBank Deposit Reference$/,
      })
      .getByTestId("number-input")
      .click();
    await page
      .frameLocator("iframe")
      .locator("#view-balance")
      .getByText("1", { exact: true })
      .click();
    await page.frameLocator("iframe").locator("div:nth-child(11)").click({
      clickCount: 3,
    });
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({
        hasText:
          /^Move To BinMove to Bin Amount Move to Bin No\.Move to Bin Trans\. ID$/,
      })
      .getByTestId("number-input")
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({
        hasText:
          /^Bank DepositBank Deposit Amount BankBank Deposit Bin CodeBank Deposit Reference$/,
      })
      .getByRole("textbox")
      .nth(1)
      .press("Control+a");
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({
        hasText:
          /^Bank DepositBank Deposit Amount BankBank Deposit Bin CodeBank Deposit Reference$/,
      })
      .getByRole("textbox")
      .nth(1)
      .fill("Deposit reference");
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({
        hasText:
          /^Bank DepositBank Deposit Amount BankBank Deposit Bin CodeBank Deposit Reference$/,
      })
      .getByRole("textbox")
      .first()
      .fill("10,00");
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({
        hasText:
          /^Move To BinMove to Bin Amount Move to Bin No\.Move to Bin Trans\. ID$/,
      })
      .getByRole("textbox")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator("#view-balance")
      .getByText("2", { exact: true })
      .click();
    await page.frameLocator("iframe").locator("div:nth-child(11)").dblclick();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: /Finalize/i })
      .click();
    const kButton = page
      .frameLocator("iframe")
      .getByRole("button", { name: /\[\d+\] K/, exact: true })
      .nth(1);
    if (await kButton.isVisible()) {
      await kButton.click();

      await page
        .frameLocator("iframe")
        .locator(
          ".balance-counting__coin-count-modal-trigger > .number-input-wrapper > .number-input-wrapper__main > .number-input-wrapper__input > .number-input"
        )
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("#view-balance")
        .getByText("1", { exact: true })
        .click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").dblclick();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page
        .frameLocator("iframe")
        .locator("div")
        .filter({
          hasText:
            /^Bank DepositBank Deposit Amount Bank Deposit Bin CodeBank Deposit Reference$/,
        })
        .getByRole("textbox")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("#view-balance")
        .getByText("2", { exact: true })
        .click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").dblclick();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page
        .frameLocator("iframe")
        .locator("div")
        .filter({
          hasText:
            /^Move To BinMove to Bin Amount Move to Bin No\.Move to Bin Trans\. ID$/,
        })
        .getByRole("textbox")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("#view-balance")
        .getByText("5", { exact: true })
        .click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").dblclick();
      await page
        .frameLocator("iframe")
        .getByRole("button", { name: /Finalize/i })
        .click();
    }
    const sekButton = page
      .frameLocator("iframe")
      .getByRole("button", { name: /\[\d+\] SEK/, exact: true });
    if (await sekButton.isVisible()) {
      await sekButton.click();
      await page
        .frameLocator("iframe")
        .locator(
          ".balance-counting__coin-count-modal-trigger > .number-input-wrapper > .number-input-wrapper__main > .number-input-wrapper__input > .number-input"
        )
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("#view-balance")
        .getByText("1", { exact: true })
        .click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").dblclick();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page
        .frameLocator("iframe")
        .locator("div")
        .filter({
          hasText:
            /^Bank DepositBank Deposit Amount Bank Deposit Bin CodeBank Deposit Reference$/,
        })
        .getByRole("textbox")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("#view-balance")
        .getByText("2", { exact: true })
        .click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").dblclick();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page
        .frameLocator("iframe")
        .locator("div")
        .filter({
          hasText:
            /^Move To BinMove to Bin Amount Move to Bin No\.Move to Bin Trans\. ID$/,
        })
        .getByRole("textbox")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("#view-balance")
        .getByText("5", { exact: true })
        .click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").dblclick();
      await page
        .frameLocator("iframe")
        .getByRole("button", { name: /Finalize/i })
        .click();
    }
    const usdButton = page
      .frameLocator("iframe")
      .getByRole("button", { name: /\[\d+\] USD/, exact: true });
    if (await usdButton.isVisible()) {
      await usdButton.click();

      await page
        .frameLocator("iframe")
        .locator(
          ".balance-counting__coin-count-modal-trigger > .number-input-wrapper > .number-input-wrapper__main > .number-input-wrapper__input > .number-input"
        )
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("#view-balance")
        .getByText("1", { exact: true })
        .click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page
        .frameLocator("iframe")
        .locator("div")
        .filter({
          hasText:
            /^Bank DepositBank Deposit Amount Bank Deposit Bin CodeBank Deposit Reference$/,
        })
        .getByRole("textbox")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("#view-balance")
        .getByText("1", { exact: true })
        .click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page
        .frameLocator("iframe")
        .locator("div")
        .filter({
          hasText:
            /^Move To BinMove to Bin Amount Move to Bin No\.Move to Bin Trans\. ID$/,
        })
        .getByRole("textbox")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("#view-balance")
        .getByText("1", { exact: true })
        .click();
      await page.frameLocator("iframe").locator("div:nth-child(11)").click();
      await page
        .frameLocator("iframe")
        .locator(
          ".balance-counting__coin-count-modal-trigger > button:nth-child(2)"
        )
        .click();
      await page
        .frameLocator("iframe")
        .locator(".ui-text-input__input-element")
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator(".ui-text-input__input-element")
        .first()
        .fill("this is a balancing comment");
      await page
        .frameLocator("iframe")
        .getByRole("button", { name: "OK" })
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
    await removeLayout(page, key);
  });
  test("User should be able to do balancing by entering coins amount", async ({
    page,
  }, workerInfo) => {
    const key = new Date().getTime();
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
      .getByRole("button", { name: "Other functions" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "End Of Day Balancing (Balance V4)" })
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
      .click();
    await page
      .frameLocator("iframe")
      .getByTestId("counting-numpad-wrapper")
      .getByTestId("numpad-input-button-1")
      .click();
    await page
      .frameLocator("iframe")
      .locator(".number-input__numpad > div:nth-child(11)")
      .first()
      .click();
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
    const sekButton = page
      .frameLocator("iframe")
      .getByRole("button", { name: /\[\d+\] SEK/ });
    if (await sekButton.isVisible()) {
      await page
        .frameLocator("iframe")
        .getByRole("button", { name: /\[\d+\] SEK/ })
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
        .click();
      await page
        .frameLocator("iframe")
        .getByTestId("counting-numpad-wrapper")
        .getByTestId("numpad-input-button-1")
        .click();
      await page
        .frameLocator("iframe")
        .locator(".number-input__numpad > div:nth-child(11)")
        .first()
        .click();
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
      await page
        .frameLocator("iframe")
        .getByRole("button", { name: /\[\d+\] K/ })
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
        .click();
      await page
        .frameLocator("iframe")
        .getByTestId("counting-numpad-wrapper")
        .getByTestId("numpad-input-button-1")
        .click();
      await page
        .frameLocator("iframe")
        .locator(".number-input__numpad > div:nth-child(11)")
        .first()
        .click();
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
      await page
        .frameLocator("iframe")
        .getByRole("button", { name: /\[\d+\] USD/ })
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
        .click();
      await page
        .frameLocator("iframe")
        .getByTestId("counting-numpad-wrapper")
        .getByTestId("numpad-input-button-1")
        .click();
      await page
        .frameLocator("iframe")
        .locator(".number-input__numpad > div:nth-child(11)")
        .first()
        .click();
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
    await removeLayout(page, key);
  });
});
