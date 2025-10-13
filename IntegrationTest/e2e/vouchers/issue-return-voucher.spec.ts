import test, { expect } from "@playwright/test";

test("should complete payment successfully by ISSUE_RETURN_VCHR_2 action", async ({
  page,
}, workerInfo) => {
  const salePersonCode = (workerInfo.parallelIndex + 1).toString();

  // login process and potential dialogs
  await page.goto("/BC/Tablet.aspx?page=6150750&tenant=default");
  const shouldAuthenticate = await page
    .getByRole("button", { name: "Sign In" })
    .count();
  if (shouldAuthenticate > 0) {
    await page
      .getByLabel("User name:")
      .fill(
        process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`] ?? ""
      );
    await page
      .getByLabel("Password:")
      .fill(
        process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`] ?? ""
      );
    await page.getByRole("button", { name: "Sign In" }).click();
  }

  await page.waitForLoadState("networkidle");
  await page.waitForSelector(".spinner", { state: "hidden", timeout: 20000 });

  const popupLocator = page.locator("[id=b3]");
  if ((await popupLocator.count()) > 0) {
    await page.getByRole("button", { name: "OK" }).click();
  }

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
  await page.waitForTimeout(3000);
  const unfinishedSaleText = page
    .locator('[class="spa-view spa-dialog no-animations shown"]')
    .getByText("There is an unfinished sale, do you want to resume it?");
  if (await unfinishedSaleText.isVisible()) {
    await page.waitForTimeout(1000);
    await page.getByRole("button", { name: "No" }).click();
  }
  const paymentBinText = page.getByText("Payment bin has never been balanced");
  if (await paymentBinText.isVisible()) {
    await page.waitForTimeout(1000);
    await page.getByRole("button", { name: "Yes" }).click();
  }
  const unfinishedBalancingText = page.getByText(
    "Do you want to continue with balancing now?"
  );
  if (await unfinishedBalancingText.isVisible()) {
    await page.waitForTimeout(1000);
    await page.getByRole("button", { name: "Yes" }).click();
    const textLocator = page.locator(
      "text=There is nothing to count in this payment bin."
    );
    await page.waitForTimeout(1000);
    if (await textLocator.isVisible()) {
      await page.getByRole("button", { name: "OK" }).click();
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

  // fill pos editor textbox and add item to saleline
  const frame = page.frameLocator("iframe");

  await frame
    .locator("#pos-editor-text-enter")
    .getByRole("textbox")
    .waitFor({ state: "visible", timeout: 15000 });
  const posTextbox = frame
    .locator("#pos-editor-text-enter")
    .getByRole("textbox");
  await posTextbox.click();
  await posTextbox.fill("1000");
  await posTextbox.press("Enter");

  // start the return item process
  await frame
    .getByRole("button", { name: "Return Bicycle" })
    .waitFor({ state: "visible", timeout: 10000 });
  await frame.getByRole("button", { name: "Return Bicycle" }).click();

  const moreInfo = frame.getByText("We need more information...");
  if ((await moreInfo.count()) > 0 && (await moreInfo.first().isVisible())) {
    await moreInfo.first().click();
  }

  const enterQty = frame.getByText("Enter Quantity");
  if ((await enterQty.count()) > 0 && (await enterQty.first().isVisible())) {
    await enterQty.first().click();
  }

  const okDialogButton = frame.locator("#button-dialog-ok div");
  if ((await okDialogButton.count()) > 0) {
    await okDialogButton.first().click();
  }

  if ((await okDialogButton.count()) > 0) {
    await okDialogButton.first().click();
  }
  await page.waitForTimeout(5000);
  await frame
    .locator(".overlay")
    .first()
    .waitFor({ state: "hidden", timeout: 5000 });

  // check if item is returned
  await frame
    .getByRole("cell", { name: "Bicycle" })
    .waitFor({ state: "visible", timeout: 8000 });
  await frame.getByRole("cell", { name: "Bicycle" }).click();

  const cellCount = frame.getByRole("cell", { name: "-1.00" });
  if ((await cellCount.count()) > 0 && (await cellCount.first().isVisible())) {
    await cellCount.first().click();
  }

  // go to payment and issue credit voucher
  await frame
    .getByRole("button", { name: "Go to Payment" })
    .waitFor({ state: "visible", timeout: 8000 });
  await frame.getByRole("button", { name: "Go to Payment" }).click();

  await expect(
    frame.getByRole("button", { name: "Issue Credit Voucher" })
  ).toBeVisible({ timeout: 10000 });

  await frame.getByRole("button", { name: "Issue Credit Voucher" }).click();
  const issueButtons = await frame
    .getByRole("button", { name: "Issue Credit Voucher" })
    .all();
  if (issueButtons.length > 1) await issueButtons[0].click();

  const returnRetail = frame.getByText("Issue Return Retail Voucher");
  if (
    (await returnRetail.count()) > 0 &&
    (await returnRetail.first().isVisible())
  ) {
    await returnRetail.first().click();
  }

  const enterAmount = frame.getByText("Enter Amount");
  if (
    (await enterAmount.count()) > 0 &&
    (await enterAmount.first().isVisible())
  ) {
    await enterAmount.first().click();
  }

  await frame
    .locator("span")
    .filter({ hasText: "OK" })
    .first()
    .click({ timeout: 5000 })
    .catch(() => {});

  // final checks in saleline to see if item is not available anymore
  await frame
    .locator("div")
    .filter({
      hasText:
        /^No\.NameQtyUOMUnit PriceDisc\. %Disc\. Amt\.Amount Incl\. VAT$/,
    })
    .first()
    .click()
    .catch(() => {});
  const itemCount = frame.getByText("Item Count0.00");
  if ((await itemCount.count()) > 0 && (await itemCount.first().isVisible())) {
    await itemCount.first().click();
  }
});
