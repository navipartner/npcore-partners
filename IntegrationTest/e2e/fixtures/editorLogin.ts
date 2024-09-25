import { Page } from "@playwright/test";

export const login = async (
  page: Page,
  salePersonCode: string,
  uniqueLayoutKey: string,
  username?: string,
  password?: string
) => {
  await page.goto("/BC/Tablet.aspx?page=6150750&tenant=default");
  const shouldAuthenticate = await page.getByRole("button", { name: "Sign In" }).count();
  if (shouldAuthenticate > 0) {
    await page.getByLabel("User name:").fill(username ?? "");
    await page.getByLabel("Password:").fill(password ?? "");
    await page.getByRole("button", { name: "Sign In" }).click();
  }
  await page.waitForLoadState("networkidle");
  await page.waitForSelector(".spinner", { state: "hidden" });
  const popupLocator = page.locator("[id=b3]");
  if ((await popupLocator.count()) > 0) {
    await page.getByRole("button", { name: "OK" }).click();
  }
  await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
  await page
    .frameLocator("iframe")
    .getByRole("button", { name: "New Layout" })
    .click();
    await page.frameLocator('iframe').getByRole('button', { name: 'Copy Existing Layout' }).click();
    await page.frameLocator('iframe').locator('.new-layout-modal__content-inner > .select > .css-b62m3t-container > .react-select__control > .react-select__indicators').click();
    await page.frameLocator('iframe').getByText('E2E Base layout', { exact: true }).click();
    await page.frameLocator('iframe').getByRole('textbox').nth(3).fill(`E2E Testing ${uniqueLayoutKey}`);
  await page
    .frameLocator("iframe")
    .getByRole("button", { name: "Create", exact: true })
    .click();
  await page.waitForSelector(".new-layout-modal", { state: "hidden" });
  await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
  await page
    .frameLocator("iframe")
    .getByText(salePersonCode, { exact: true })
    .click();
  await page.frameLocator("iframe").getByText("OK", { exact: true }).click();
  const agreeOnBalancingQty = page
    .frameLocator("iframe")
    .getByText("Do you agree?");

  if (await agreeOnBalancingQty.isVisible()) {
    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Yes", exact: true })
      .click();
  }
  await page.waitForTimeout(6000);
  const balancingText = page
    .frameLocator("iframe")
    .getByText("Confirm Bin Contents.");
  if (await balancingText.isVisible()) {
    await page.frameLocator("iframe").locator("#button-dialog-yes div").click();
  }
  await page.waitForTimeout(1000);
  const unfinishedSaleText = page
    .locator('[class="spa-view spa-dialog no-animations shown"]')
    .getByText("There is an unfinished sale, do you want to resume it?");
  if (await unfinishedSaleText.isVisible()) {
    await page.waitForTimeout(1000);
    await page.getByRole("button", { name: "No" }).click();
  }
  const unfinishedBalancingText = page.getByText(
    "Do you want to continue with balancing now?"
  );
  if (await unfinishedBalancingText.isVisible()) {
    await page.waitForTimeout(1000);
    await page.getByRole("button", { name: "Yes" }).click();
    const textLocator = page.locator('text=There is nothing to count in this payment bin.');
    await page.waitForTimeout(1000);
  if (await textLocator.isVisible()) {
    await page.getByRole('button', { name: 'OK' }).click();
  } else {
    await page
    .frameLocator("iframe")
    .getByRole("button", { name: "Cancel" })
    .click();
    await page
    .frameLocator("iframe")
    .locator("span")
    .filter({ hasText: "Yes" })
    .first()
    .click();
  }
    await page.waitForTimeout(1000);
    await page
      .frameLocator("iframe")
      .getByText(salePersonCode, { exact: true })
      .click();
    await page.frameLocator("iframe").getByText("OK", { exact: true }).click();
  }
  if (await agreeOnBalancingQty.isVisible()) {
    await page.frameLocator("iframe").locator("#button-dialog-yes div").click();
  }
  await page.waitForTimeout(2000);
};
