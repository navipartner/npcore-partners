import { expect, test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.skip()

test.describe("Grid Options button tests", () => {
  test("Button is rendered and showing dropdown", async ({
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
      .getByText("Select grid to edit :")
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
    await page.frameLocator("iframe").getByText("Columns").click();
    await page.frameLocator("iframe").getByText("Rows").click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Reset Grid Values" })
      .isVisible();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByText("Select grid to edit :")
      .click();
    await page
      .frameLocator("iframe")
      .locator(".react-select__control")
      .first()
      .click();
    await page.waitForTimeout(5000);
    await page
      .frameLocator("iframe")
      .getByText("GRID_2", { exact: true })
      .click();
    await page.frameLocator("iframe").locator("#columnsNr").fill("04");
    await page.frameLocator("iframe").locator("#rowsNr").fill("04");
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Clear" })
      .click();
    await page.frameLocator("iframe").getByText("Yes").click();
    await removeLayout(page, key);
  });
  test("User is able to change number of rows and columns", async ({
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
      .getByText("Select grid to edit :")
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
    await page.frameLocator("iframe").locator("#columnsNr").fill("04");
    await page.frameLocator("iframe").locator("#rowsNr").fill("03");
    expect(
      page.frameLocator("iframe").getByRole("button", { name: "Logout" })
    ).toBeHidden();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Clear" })
      .click();
    await page.frameLocator("iframe").getByText("Yes").click();
    await removeLayout(page, key);
  });
});
