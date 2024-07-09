import { test } from "@playwright/test";

import { login } from "../../fixtures/mobileEditorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.describe("Mobile payment flow", () => {
  test("should be able to do single and multy payment", async ({
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
      .getByRole("button", { name: "Payment" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Select payment" })
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
    await page.waitForTimeout(2000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Payment" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Select payment" })
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
      .getByRole("button", { name: "Select payment" })
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
    await removeLayout(page, key);
  });
});
