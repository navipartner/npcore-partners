import { Page } from "@playwright/test";

export const restaurantLogin = async (
  page: Page,
  shouldAuthenticate = true
) => {
  await page.goto("/");
  await page
    .getByRole("link", {
      name: /https:\/\/([a-zA-Z0-9.-]+)\.dynamics-retail\.net\/BC\/SignIn\?ReturnUrl=BC\/Tablet\.aspx\?page=6150750&tenant=default/,
    })
    .click();
  if (shouldAuthenticate) {
    await page.getByLabel("User name:").fill(process.env.E2E_USERNAME ?? "");
    await page.getByLabel("Password:").fill(process.env.E2E_PASSWORD ?? "");
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
  await page.frameLocator("iframe").getByText("1", { exact: true }).click();
  await page.frameLocator("iframe").getByText("OK", { exact: true }).click();
  await page.waitForTimeout(4000);

  const balancingText = page
    .frameLocator("iframe")
    .getByText("Confirm Bin Contents.");
  if (await balancingText.isVisible()) {
    await page.frameLocator("iframe").locator("#button-dialog-yes div").click();
  }
  const unfinishedText = page.getByText(
    "There is an unfinished sale, do you want to resume it?"
  );
  await page.waitForTimeout(1000);
  if (await unfinishedText.isVisible()) {
    const noBtn = page.getByRole("button", { name: "No" });
    await noBtn.click();
  }
  await page.waitForTimeout(2000);
};
