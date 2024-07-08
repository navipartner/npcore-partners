import { test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.describe("Edit Mode Bar tests", () => {
  test("should be able to create editable button, copy and paste", async ({
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
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(6) > .editable-button__content > .editable-button__button"
      )
      .first()
      .click();

    await page.frameLocator("iframe").getByText("Edit").click();
    await page.frameLocator("iframe").getByText("Color").click();
    await page.frameLocator("iframe").getByTitle("#FF0000").click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(2)
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .first()
      .fill("e2e test");
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(1)
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(1)
      .fill("e2e test2");
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(2)
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(2)
      .fill("e2etesting3");
    await page
      .frameLocator("iframe")
      .getByText("VariablesPlease select an action")
      .click();
    await page.frameLocator("iframe").getByText("Icon").click();
    await page.frameLocator("iframe").locator(".select__indicator").click();
    await page
      .frameLocator("iframe")
      .locator("#react-select-10-option-0 div")
      .filter({ hasText: "0" })
      .locator("div")
      .click();
    await page.frameLocator("iframe").getByText("Icon").click();
    await page.frameLocator("iframe").getByText("Image").click();
    await page
      .frameLocator("iframe")
      .getByRole("tooltip", { name: "Please provide link" })
      .getByRole("textbox")
      .fill("https://picsum.photos/200");
    await page.frameLocator("iframe").getByText("Tooltip").click();
    await page
      .frameLocator("iframe")
      .getByRole("tooltip", { name: "Please provide tooltip" })
      .getByRole("textbox")
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("tooltip", { name: "Please provide tooltip" })
      .getByRole("textbox")
      .fill("testing");
    await page
      .frameLocator("iframe")
      .getByText("Tooltip", { exact: true })
      .click();
    await page.frameLocator("iframe").getByText("Enabled").click();
    await page
      .frameLocator("iframe")
      .getByLabel("Only with selected line")
      .check();
    await page
      .frameLocator("iframe")
      .getByLabel("Only when items in sale")
      .check();
    await page.waitForTimeout(2000);
    await page.frameLocator("iframe").getByLabel("Disabled").check();
    await page.frameLocator("iframe").getByLabel("Enabled").check();
    await page.frameLocator("iframe").getByText("Enabled").first().click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: /^e2e test(.*)$/ })
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Test Items" })
      .click();
    await page.frameLocator("iframe").getByText("Copy").click();
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(7) > .editable-button__content > .editable-button__button"
      )
      .click();
    await page.frameLocator("iframe").getByText("Paste").click();
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
    await page.waitForTimeout(3000);
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Test Items" })
      .nth(1)
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Close" })
      .click();
    await removeLayout(page, key);
  });

  test("should be able to add action", async ({ page }, workerInfo) => {
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
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(6) > .editable-button__content > .editable-button__button"
      )
      .first()
      .click();
    await page.frameLocator("iframe").getByText("Edit").click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .first()
      .fill("testing popup");
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(1)
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(1)
      .fill("e2e");
    await page.waitForTimeout(1000);

    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(2) > .css-b62m3t-container > .react-select__control"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Open Popup Menu", { exact: true })
      .click();

    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Popup Menu IDSelect an id \.\.\.orEnter new id$/ })
      .locator("svg")
      .click();
    await page
      .frameLocator("iframe")
      .getByText("item-addon", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "testing popup e2e" })
      .click();

    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(3) > .select > .css-b62m3t-container > .react-select__control"
      )
      .click();
    await page
      .frameLocator("iframe")
      .getByText("CUR-SALESP", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(2000);
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
      .getByRole("button", { name: "testing popup e2e" })
      .click();
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: /^1$/ })
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator("span")
      .filter({ hasText: "OK" })
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Close" })
      .click();
    //    second step
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(7) > .editable-button__content > .editable-button__button"
      )
      .click();
    await page.frameLocator("iframe").getByText("Edit").click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .first()
      .fill("test last");
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(1)
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(1)
      .fill("this");
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(2) > .css-b62m3t-container > .react-select__control"
      )
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .getByText("Open Nested Menu", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({
        hasText: /^Open Nested Menu IDSelect an id \.\.\.orEnter new id$/,
      })
      .locator("svg")
      .click();
    await page
      .frameLocator("iframe")
      .getByText("posinfo", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "test last this" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(2000);

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
      .getByRole("button", { name: "test last this" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Back" })
      .click();

    // third button

    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
    await page
      .frameLocator("iframe")
      .locator(
        "div:nth-child(8) >.editable-button__content > .editable-button__button"
      )
      .click();
    await page.frameLocator("iframe").getByText("Edit").click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .first()
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .first()
      .fill("testing login action");
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "testing login action" })
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
      .getByText("Change View", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .locator("div")
      .filter({ hasText: /^VariablesPage Type$/ })
      .locator("svg")
      .click();
    await page
      .frameLocator("iframe")
      .getByText("login", { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Save" })
      .click();
    await page.waitForTimeout(2000);
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
      .getByRole("button", { name: "testing login action" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Setup" })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Close" })
      .click();
    await page
      .frameLocator("iframe")
      .getByText(salePersonCode, { exact: true })
      .click();
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "OK" })
      .click();
    await removeLayout(page, key);
  });
});
