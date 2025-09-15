import { Page } from "@playwright/test";

export const oldPosLogin = async (
  page: Page,
  shouldAuthenticate = true,
  salePersonCode: string,
  username?: string,
  password?: string
) => {
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
    await page.waitForTimeout(5000);
  }

  const loadingLocator = page
    .frameLocator("iframe")
    .getByText("Loading POS, please wait.", {
      exact: false,
    });
  const loadingVisible = await loadingLocator.isVisible();

  if (loadingVisible) {
    await page.reload();
    await page.waitForTimeout(5000);
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
  }

  await page.waitForTimeout(10000);
  await page
    .frameLocator("iframe")
    .getByText(salePersonCode, { exact: true })
    .isVisible();
  await page
    .frameLocator("iframe")
    .locator("span")
    .filter({ hasText: "1" })
    .first()
    .click();
  await page
    .frameLocator("iframe")
    .locator("span")
    .filter({ hasText: "OK" })
    .first()
    .click();
  await page.waitForTimeout(5000);

  const balancingText = page
    .frameLocator("iframe")
    .getByText("Confirm Bin Contents.");
  if (await balancingText.isVisible()) {
    await page.frameLocator("iframe").locator("#button-dialog-yes div").click();
  }

  const balancingInProgressText = page.getByText(
    "The POS Unit 03 is marked as being in balancing. Do you want to continue with balancing now?"
  );
  if (await balancingInProgressText.isVisible()) {
    const yesBtn = page.getByRole("button", { name: "Yes" });
    await yesBtn.click();
  }

  const unfinishedText = page.getByText(
    "There is an unfinished sale, do you want to resume it?"
  );
  await page.waitForTimeout(1000);
  if (await unfinishedText.isVisible()) {
    const noBtn = page.getByRole("button", { name: "No" });
    await noBtn.click();
  }
  await page.waitForTimeout(1000);
  const partialSaleText = page.getByText("This sale cannot be cancelled");
  if (await partialSaleText.isVisible()) {
    await page.getByRole("button", { name: "OK" }).click();
  }

  // Handle error messages and unfinished sales in a loop
  let retries = 3;
  while (retries-- > 0) {
    await page.waitForTimeout(1000);

    const somethingIsWrongText = page
      .frameLocator("iframe")
      .getByText("Something is wrong...");
    const changesToThePosSaleRecordCannotBeSaved = page
      .frameLocator("iframe")
      .getByText("The changes to the POS Sale");

    if (
      (await somethingIsWrongText.isVisible()) ||
      (await changesToThePosSaleRecordCannotBeSaved.isVisible())
    ) {
      const okBtn = page
        .frameLocator("iframe")
        .locator("#button-dialog-back")
        .first();

      await okBtn.waitFor({ state: "visible", timeout: 2000 });
      await okBtn.click({ timeout: 4000 });
      await page
        .frameLocator("iframe")
        .locator("text=Something is wrong..., text=The changes to the POS Sale")
        .first()
        .waitFor({ state: "hidden", timeout: 5000 });

      await page
        .frameLocator("iframe")
        .locator("span")
        .filter({ hasText: "1" })
        .first()
        .click();
      await page
        .frameLocator("iframe")
        .locator("span")
        .filter({ hasText: "OK" })
        .first()
        .click();
    }

    // Handle unfinished sale
    const unfinishedText = page.getByText(
      "There is an unfinished sale, do you want to resume it?"
    );
    if (await unfinishedText.isVisible()) {
      await page.getByRole("button", { name: "No" }).click();
    }

    // Handle cannot cancel sale
    const partialSaleText = page.getByText("This sale cannot be cancelled");
    if (await partialSaleText.isVisible()) {
      await page.getByRole("button", { name: "OK" }).click();
    }

    // If no dialogs appear, break the loop
    if (
      !(await somethingIsWrongText.isVisible()) &&
      !(await changesToThePosSaleRecordCannotBeSaved.isVisible()) &&
      !(await unfinishedText.isVisible()) &&
      !(await partialSaleText.isVisible())
    ) {
      break;
    }
  }
  await page.waitForTimeout(2000);
};
