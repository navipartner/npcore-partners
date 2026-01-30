import { test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";
import {
  fillCaption,
  openGearMenu,
  clickEditableButton,
  saveAndOverwriteLayout,
} from "./helpers";

test.describe("Edit Mode Bar tests 2", () => {
  test("should add popup menu action to editable button", async ({ page }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
    const salePersonCode = (workerInfo.parallelIndex + 1).toString();

    await login(
      page,
      salePersonCode,
      key,
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
    );

    const frame = page.frameLocator("iframe");

    await openGearMenu(frame);
    await clickEditableButton(frame, 6);
    await frame.getByText("Edit").click();

    await fillCaption(frame, 0, "testing popup");
    await fillCaption(frame, 1, "e2e");

    await page.waitForTimeout(1000);
    await frame
      .locator(
        "div:nth-child(2) > .css-b62m3t-container > .react-select__control"
      )
      .first()
      .click();
    await frame.getByText("Open Popup Menu", { exact: true }).click();

    await frame
      .locator("div")
      .filter({ hasText: /^Popup Menu IDSelect an id \.\.\.orEnter new id$/ })
      .locator("svg")
      .click();
    await frame.getByText("item-addon", { exact: true }).click();
    await frame.getByRole("button", { name: "testing popup e2e" }).click();

    await frame
      .locator(
        "div:nth-child(3) > .select > .css-b62m3t-container > .react-select__control"
      )
      .click();
    await frame.getByText("SUPERVISOR", { exact: true }).click();
    await frame.getByRole("button", { name: "Save" }).click();
    await page.waitForTimeout(2000);

    await saveAndOverwriteLayout(frame, page);

    await frame.getByRole("button", { name: "testing popup e2e" }).click();
    await frame.locator("span").filter({ hasText: "9" }).first().click();
    await frame.locator("span").filter({ hasText: "OK" }).first().click();
    await frame.getByRole("button", { name: "Close" }).click();

    await removeLayout(page, key);
  });

  test("should add nested menu action to editable button", async ({ page }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
    const salePersonCode = (workerInfo.parallelIndex + 1).toString();

    await login(
      page,
      salePersonCode,
      key,
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
    );

    const frame = page.frameLocator("iframe");

    await openGearMenu(frame);
    await page.waitForTimeout(10000);
    await clickEditableButton(frame, 7);
    await frame.getByText("Edit").click();

    await fillCaption(frame, 0, "test last");
    await page.waitForTimeout(1000);
    await fillCaption(frame, 1, "this");

    await frame
      .locator(
        "div:nth-child(2) > .css-b62m3t-container > .react-select__control"
      )
      .first()
      .click();
    await frame.getByText("Open Nested Menu", { exact: true }).click();
    await frame
      .locator("div")
      .filter({
        hasText: /^Open Nested Menu IDSelect an id \.\.\.orEnter new id$/,
      })
      .locator("svg")
      .click();
    await frame.getByText("posinfo", { exact: true }).click();
    await frame.getByRole("button", { name: "test last this" }).click();
    await frame.getByRole("button", { name: "Save" }).click();
    await page.waitForTimeout(2000);

    await saveAndOverwriteLayout(frame, page);

    await frame.getByRole("button", { name: "test last this" }).click();
    await frame.getByRole("button", { name: "Back" }).click();

    await removeLayout(page, key);
  });

  test("should add change view action to editable button", async ({ page }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
    const salePersonCode = (workerInfo.parallelIndex + 1).toString();

    await login(
      page,
      salePersonCode,
      key,
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
    );

    const frame = page.frameLocator("iframe");

    await openGearMenu(frame);
    await page.waitForTimeout(10000);
    await clickEditableButton(frame, 8);
    await frame.getByText("Edit").click();

    await fillCaption(frame, 0, "testing login action");

    await frame.getByRole("button", { name: "testing login action" }).click();
    await frame
      .locator(
        "div:nth-child(2) > .css-b62m3t-container > .react-select__control"
      )
      .first()
      .click();
    await frame.getByText("Change View", { exact: true }).click();
    await frame
      .locator("div")
      .filter({ hasText: /^VariablesPage Type$/ })
      .locator("svg")
      .click();
    await frame.getByText("login", { exact: true }).click();
    await frame.getByRole("button", { name: "Save" }).click();
    await page.waitForTimeout(2000);

    await saveAndOverwriteLayout(frame, page);

    await frame.getByRole("button", { name: "testing login action" }).click();
    await frame.getByRole("button", { name: "Setup" }).click();
    await frame.getByRole("button", { name: "Close" }).click();
    await frame.getByText(salePersonCode, { exact: true }).click();
    await frame.getByRole("button", { name: "OK" }).click();

    await removeLayout(page, key);
  });
});
