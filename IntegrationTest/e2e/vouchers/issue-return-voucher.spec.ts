import test, { expect, Locator } from "@playwright/test";
import { login } from "../fixtures/editorLogin";
import { removeLayout } from "../fixtures/removeLayout";

test.skip()

const maybeClick = async (loc: Locator, timeout = 3000) => {
  const first = loc.first();
  try {
    await first.waitFor({ state: "visible", timeout });
    await first.click();
    return true;
  } catch {
    return false;
  }
};

test("should complete payment successfully by ISSUE_RETURN_VCHR_2 action", async ({ page }, workerInfo) => {
  const key = `${Date.now()}-WORKER${workerInfo.parallelIndex}`;
  const salePersonCode = (workerInfo.parallelIndex + 1).toString();

  await login(
    page,
    salePersonCode,
    key,
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
  );

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
  const okDialogButton = frame.locator('#button-dialog-ok div');
  await okDialogButton.click();
  await page.waitForTimeout(3000);
  await okDialogButton.click();
  await frame
    .locator(".overlay")
    .first()
    .waitFor({ state: "hidden", timeout: 5000 });

  await frame
    .getByRole("cell", { name: "Bicycle" })
    .waitFor({ state: "visible", timeout: 8000 });
  await frame.getByRole("cell", { name: "Bicycle" }).click();

  const cellCount = frame.getByRole("cell", { name: "-1.00" });
  if ((await cellCount.count()) > 0 && (await cellCount.first().isVisible())) {
    await cellCount.first().click();
  }

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

  await frame
    .locator("div")
    .filter({
      hasText:
        /^No\.NameQtyUOMUnit PriceDisc\. %Disc\. Amt\.Amount Incl\. VAT$/,
    })
    .first()
    .click()
    .catch(() => {});

  await maybeClick(frame.getByText("Item Count0.00").first(), 2000);

  await removeLayout(page, key);
});
