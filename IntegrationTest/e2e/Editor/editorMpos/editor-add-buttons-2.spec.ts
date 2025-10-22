import { test } from "@playwright/test";

import { login } from "../../fixtures/mobileEditorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.skip()

test.describe("Mobile add and remove editable buttons test 2", () => {
  test("should be able to add button to items and then clear it", async ({
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
    await page.waitForTimeout(1000);
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
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "A", exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Clear", { exact: true })
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
    await page.waitForTimeout(2000);
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator("div")
      .nth(1)
      .click();
    await removeLayout(page, key);
  });
});


