import { FrameLocator, Page } from "@playwright/test";

export async function fillCaption(frame: FrameLocator, index: number, value: string) {
  const textbox = frame
    .locator("div")
    .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
    .getByRole("textbox")
    .nth(index);
  await textbox.click();
  await textbox.fill(value);
}

export async function openGearMenu(frame: FrameLocator) {
  await frame
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
}

export async function clickEditableButton(frame: FrameLocator, childPosition: number) {
  await frame
    .locator(
      `div:nth-child(${childPosition}) > .editable-button__content > .editable-button__button`
    )
    .first()
    .click();
}

export async function saveAndOverwriteLayout(frame: FrameLocator, page: Page) {
  await frame.getByRole("button", { name: "Save" }).click();
  await page.waitForTimeout(3000);
  await frame.getByRole("button", { name: "Overwrite current layout" }).click();
  await page.waitForTimeout(3000);
}
