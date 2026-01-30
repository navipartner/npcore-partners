import { test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";
import {
  fillCaption,
  openGearMenu,
  clickEditableButton,
  saveAndOverwriteLayout,
} from "./helpers";

test.describe("Edit Mode Bar tests", () => {
  test("should create editable button with custom styling, icon, image, tooltip, conditional visibility, then copy and paste it", async ({
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

    const frame = page.frameLocator("iframe");

    await openGearMenu(frame);
    await clickEditableButton(frame, 6);

    await frame.getByText("Edit").click();
    await frame.getByText("Color").click();
    await frame.locator('.custom-color-picker__palette-color').first().click();

    // Fill caption textboxes
    await frame
      .locator("div")
      .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
      .getByRole("textbox")
      .nth(2)
      .click();
    await fillCaption(frame, 0, "e2e test");
    await fillCaption(frame, 1, "e2e test2");
    await fillCaption(frame, 2, "e2etesting3");

    await frame.getByText("VariablesPlease select an action").click();
    await frame.getByText("Icon").click();
    await frame.locator(".select__indicator").click();
    await frame
      .locator("#react-select-10-option-0 div")
      .filter({ hasText: "0" })
      .locator("div")
      .click();
    await frame.getByText("Icon").click();
    await frame.getByText("Image").click();
    await frame
      .getByRole("tooltip", { name: "Please provide link" })
      .getByRole("textbox")
      .fill("https://picsum.photos/200");
    await frame.getByText("Tooltip").click();
    await frame
      .getByRole("tooltip", { name: "Please provide tooltip" })
      .getByRole("textbox")
      .click();
    await frame
      .getByRole("tooltip", { name: "Please provide tooltip" })
      .getByRole("textbox")
      .fill("testing");
    await frame.getByText("Tooltip", { exact: true }).click();
    await frame.getByText("Enabled").click();
    await frame.getByLabel("Only with selected line").check();
    await frame.getByLabel("Only when items in sale").check();
    await page.waitForTimeout(2000);
    await frame.getByLabel("Disabled").check();
    await frame.getByLabel("Enabled").check();
    await frame.getByText("Enabled").first().click();
    await frame.getByRole("button", { name: /^e2e test(.*)$/ }).click();
    await page.waitForTimeout(1000);
    await frame.getByRole("button", { name: "Save" }).click();
    await page.waitForTimeout(1000);
    await frame.getByRole("button", { name: "Test Items" }).click();

    // Copy button
    await frame.getByText("Copy").click();
    await page.waitForTimeout(1000);

    // Paste to new button
    await clickEditableButton(frame, 7);
    await frame.getByText("Paste").click();
    await page.waitForTimeout(1000);

    await saveAndOverwriteLayout(frame, page);

    await frame.getByRole("button", { name: "Test Items" }).nth(1).click();
    await frame.getByRole("button", { name: "Close" }).click();

    await removeLayout(page, key);
  });
});
