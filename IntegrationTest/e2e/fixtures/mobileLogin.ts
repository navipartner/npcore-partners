import { Page } from "@playwright/test";

export const mobileLogin = async (
  page: Page,
  shouldAuthenticate = true,
  salePersonCode: string,
  username?: string,
  password?: string
) => {
  await page.setViewportSize({ width: 475, height: 720 });
  await page.goto("/BC/Tablet.aspx?page=6150750&tenant=default");
  if (shouldAuthenticate) {
    await page.getByLabel("User name:").fill(username ?? "");
    await page.getByLabel("Password:").fill(password ?? "");
    await page.getByRole("button", { name: "Sign In" }).click();
  }
  await page.waitForLoadState("networkidle");
  await page.waitForSelector(".spinner", { state: "hidden" });
  await page.waitForTimeout(5000);
  const popupLocator = page.locator("div").filter({
    hasText: /Caution: Your program license expires in \d+ days\.OK/,
  });
  const popupExists = await popupLocator.count();
  if (popupExists > 0) {
    await page.getByRole("button", { name: "OK" }).click();
  }
  await page.waitForTimeout(10000);
  const pageElementLoaded = await page
  .frameLocator("iframe")
  .getByText(salePersonCode, { exact: true }).isVisible()
  if(pageElementLoaded) {
    await page
    .frameLocator("iframe")
    .getByText(salePersonCode, { exact: true })
    .click();
  } else {
    await page.goto("/BC/Tablet.aspx?page=6150750&tenant=default");
    await page
    .frameLocator("iframe")
    .getByText(salePersonCode, { exact: true })
    .click();
  }
  await page.frameLocator("iframe").locator("div:nth-child(12)").click();
  await page.waitForTimeout(4000);
  const balancingText = page
    .frameLocator("iframe")
    .getByText("Confirm Bin Contents.");
  if (await balancingText.isVisible()) {
    await page.frameLocator("iframe").locator("#button-dialog-yes div").click();
  }
  const unfinishedText = await page.getByText(
    "There is an unfinished sale, do you want to resume it?"
  );
  await page.waitForTimeout(1000);
  if (await unfinishedText.isVisible()) {
    const noBtn = page.getByRole("button", { name: "No" });
    await noBtn.click();
  }
  await page.waitForTimeout(1000);
  const partialSaleText = page.getByText('This sale cannot be cancelled');
  if (await partialSaleText.isVisible()) {
    await page.getByRole('button', { name: 'OK' }).click();
  }
  await page.waitForTimeout(2000);
};
