import { Page } from "@playwright/test";

export const login = async (
  page: Page,
  salePersonCode: string,
  uniqueLayoutKey?: string,
  username?: string,
  password?: string
) => {
  await page.goto("/BC/Tablet.aspx?page=6150750&tenant=default");
  await page.getByLabel("User name:").fill(username ?? "");
  await page.getByLabel("Password:").fill(password ?? "");
  await page.getByRole("button", { name: "Sign In" }).click();
  await page.waitForLoadState("networkidle");
  await page.waitForSelector(".spinner", { state: "hidden" });
  const popupLocator = page.locator("[id=b3]");
  if ((await popupLocator.count()) > 0) {
    await page.getByRole("button", { name: "OK" }).click();
  }
  const agreeOnBalancingQty = page
    .frameLocator("iframe")
    .getByText("Do you agree?");

  if (await agreeOnBalancingQty.isVisible()) {
    await page.frameLocator("iframe").locator("#button-dialog-yes div").click();
  }
  await page.waitForTimeout(5000);
  await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
  await page
    .frameLocator("iframe")
    .getByRole("button", { name: "New Layout" })
    .click();
  await page.waitForTimeout(500);
  await page
    .frameLocator("iframe")
    .getByRole("button", { name: "New Layout" })
    .nth(1)
    .click();
  await page.waitForTimeout(500);
  await page
    .frameLocator("iframe")
    .locator(".ui-text-input__input-element")
    .click();
  await page
    .frameLocator("iframe")
    .locator(".ui-text-input__input-element")
    .fill(`E2E Testing ${uniqueLayoutKey}`);
  await page
    .frameLocator("iframe")
    .locator("label")
    .filter({ hasText: "Mobile LayoutDesktop Layout" })
    .locator("label")
    .click();
  await page
    .frameLocator("iframe")
    .getByRole("button", { name: "Create", exact: true })
    .click();
  await page.waitForTimeout(5000);

  await page.waitForSelector(".new-layout-modal", { state: "hidden" });
  await page.waitForTimeout(1000);
  await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
  await page.waitForTimeout(3000);
  await page
    .frameLocator("iframe")
    .getByText(salePersonCode, { exact: true })
    .click();
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
    const noBtn = await page.getByRole("button", { name: "No" });
    await noBtn.click();
  }
  const unfinishedBalancingText = page.getByText(
    "Do you want to continue with balancing now?"
  );
  if (await unfinishedBalancingText.isVisible()) {
    await page.waitForTimeout(1000);
    await page.getByRole("button", { name: "Yes" }).click();
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
    await page.waitForTimeout(5000);
    await page
      .frameLocator("iframe")
      .getByText(salePersonCode, { exact: true })
      .click();
    await page.frameLocator("iframe").locator("div:nth-child(12)").click();
    await page.waitForTimeout(5000);
  }

  if (await agreeOnBalancingQty.isVisible()) {
    await page.frameLocator("iframe").locator("#button-dialog-yes div").click();
  }
  await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
  await page.waitForTimeout(1000);
  await page
    .frameLocator("iframe")
    .getByRole("contentinfo")
    .locator('svg[data-icon="gear"]')
    .click();
  await page.waitForTimeout(3000);
};
