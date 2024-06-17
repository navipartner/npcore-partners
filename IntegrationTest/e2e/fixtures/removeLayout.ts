import { Page } from "@playwright/test";

export const removeLayout = async (page: Page, uniqueKey: number) => {
  if (await page.getByText("does not exist anymore.").isVisible()) {
    await page.getByRole("button", { name: "OK" }).click();
  }
  await page.waitForTimeout(2000);
  if (await page.getByText("does not exist anymore.").isVisible()) {
    await page.getByRole("button", { name: "OK" }).click();
  }
  if (
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Delete Layout" })
      .isHidden()
  ) {
    await page
      .frameLocator("iframe")
      .getByRole("contentinfo")
      .locator('svg[data-icon="gear"]')
      .click();
  }
  await page.waitForTimeout(2000);
  await page
    .frameLocator("iframe")
    .locator(".react-select__indicator")
    .first()
    .click();

  await page.waitForTimeout(1000);
  if (
    await page
      .frameLocator("iframe")
      .getByText("Default [Classic1]")
      .nth(1)
      .isVisible()
  ) {
    await page
      .frameLocator("iframe")
      .getByText("Default [Classic1]")
      .nth(1)
      .click();
  } else {
    await page.frameLocator("iframe").getByText("Default [Classic1]").click();
  }
  await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
  await page.waitForTimeout(4000);
  await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
  await page
    .frameLocator("iframe")
    .locator(".react-select__indicator")
    .first()
    .click({ timeout: 10000 });
  await page.frameLocator("iframe").getByText(uniqueKey.toString()).click();
  await page
    .frameLocator("iframe")
    .getByRole("button", { name: "Delete Layout" })
    .click();
  await page.waitForTimeout(1000);
  await page
    .frameLocator("iframe")
    .locator("span")
    .filter({ hasText: "Yes" })
    .first()
    .click();
  await page.waitForTimeout(1000);
};
