import { test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.describe("Edit Mode Bar tests 2", () => {
  test("user should be able to update product quantity", async ({
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
      .getByRole("button", { name: "Test Items" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Small Draft Beer" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Increase Quantity By 1 Small" })
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Change Quantity Small Draft" })
      .click();
    await page.frameLocator("iframe").locator("#button10 div").click();
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: "OK" })
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Decrease Quantity By 1 Small" })
      .click();

    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Delete Line" })
      .click();
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Cancel Sale" })
      .click();
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: "Yes" })
      .first()
      .click();
    await page.waitForTimeout(3000);
    await removeLayout(page, key);
  });
  test("user should be able to update grids columns", async ({
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
      .locator('svg[data-icon="gear"]')
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Grids" })
      .click();
    await page
      .frameLocator("iframe")
      .locator(".react-select__control")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("GRID_1", { exact: true })
      .click();
    await page.frameLocator("iframe").locator("#columnsNr").click();
    await page.frameLocator("iframe").locator("#columnsNr").fill("6");
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(30) > .editable-button__content > .editable-button__button"
      )
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Edit", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Cancel", exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Clear" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: "Yes" })
      .first()
      .click();
    await removeLayout(page, key);
  });
  test("user should be able to control edit mode bar security", async ({
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
      .locator('svg[data-icon="gear"]')
      .click();
    await page.frameLocator("iframe").locator("button:nth-child(16)").click();
    await page
      .frameLocator("iframe")
      .locator(
        ".flex > div > .select > .css-b62m3t-container > .react-select__control"
      )
      .click();

    await page
      .frameLocator("iframe")
      .getByText("SUPERVISOR", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Close" })
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
    await page.waitForTimeout(5000);
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await page.frameLocator("iframe").getByText("9", { exact: true }).click();
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: "OK" })
      .first()
      .click();
    await page.frameLocator("iframe").locator("button:nth-child(16)").click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({
        hasText:
          /^Authorization Password requirements for opening edit mode : SUPERVISOR$/,
      })
      .locator("svg")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Close" })
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
    await page.frameLocator("iframe").locator(".ui-modal__body").isHidden();
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await removeLayout(page, key);
  });
});
