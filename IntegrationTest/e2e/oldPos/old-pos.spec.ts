import { test, expect } from "@playwright/test";
import { oldPosLogin } from "../fixtures/oldPosLogin";

test.describe("Old POS test", () => {
  test("should be able to add item, change quantity, delete item and cancel sale", async ({
    page,
  }) => {
    await oldPosLogin(
      page,
      true,
      "Salesperson Code",
      process.env?.[`E2E_OLD_MPOS_USERNAME`],
      process.env?.[`E2E_OLD_MPOS_PASSWORD`]
    );

    const frame = page.frameLocator("iframe");

    const testItemsBtn = () =>
      frame.locator("div[id^='button']", { hasText: "Test Items" }).first();
    const salePanel = frame.locator("#sale-panel1-grid1");

    // Focus input, type code and submit
    const codeInput = frame.locator("#sale-panel2-text1").getByRole("textbox");
    await expect(codeInput).toBeVisible({ timeout: 5000 });
    await codeInput.click();
    await codeInput.fill("1000");
    await codeInput.press("Enter");

    // Check if item is available in the sale list
    const bicycleCell = frame.getByRole("cell", { name: "Bicycle" });
    await expect(bicycleCell).toBeVisible({ timeout: 5000 });
    await bicycleCell.locator("span").first().click();

    // Add Large Draft Beer
    await expect(testItemsBtn()).toBeVisible({ timeout: 5000 });
    await testItemsBtn().click();

    const largeBeer = frame
      .locator("span", { hasText: "Large Draft Beer" })
      .first();
    await expect(largeBeer).toBeVisible({ timeout: 10000 });
    await largeBeer.click();

    await expect(
      salePanel.getByRole("cell", { name: "Large Draft Beer" })
    ).toBeVisible({
      timeout: 5000,
    });

    // Change Quantity for Large Draft Beer
    const changeQtyBtn = frame
      .locator("div[id^='button']", { hasText: "Change Quantity Large Draft" })
      .first();
    await expect(changeQtyBtn).toBeVisible({ timeout: 5000 });
    await changeQtyBtn.click();

    await frame.locator("span", { hasText: /^2$/ }).first().click();
    const okBtn = frame.locator("div[id^='button']", { hasText: "OK" }).first();
    await expect(okBtn).toBeVisible({ timeout: 5000 });
    await okBtn.click();
    await page.waitForTimeout(5000);

    // Delete the line
    const deleteLineBtn = frame
      .locator("div[id^='button']", { hasText: "Delete Line Large Draft Beer" })
      .first();
    await expect(deleteLineBtn).toBeVisible({ timeout: 5000 });
    await deleteLineBtn.click();
    await page.waitForTimeout(5000);
    await expect(salePanel.getByText("Large Draft Beer")).not.toBeVisible({
      timeout: 10000,
    });

    // Cancel Sale
    const cancelSaleBtn = frame
      .locator("div[id^='button']", { hasText: "Cancel Sale" })
      .first();
    await expect(cancelSaleBtn).toBeVisible({ timeout: 5000 });
    await cancelSaleBtn.click();

    // Confirm dialog appears
    const confirmText = frame.getByText("Are you sure you want to");
    await expect(confirmText).toBeVisible({ timeout: 5000 });

    const yesBtn = frame
      .locator("div[id^='button']", { hasText: "Yes" })
      .first();
    await expect(yesBtn).toBeVisible({ timeout: 5000 });
    await yesBtn.click();

    // Sale panel contains no items after cancel
    await expect(salePanel.getByText("Large Draft Beer")).not.toBeVisible({
      timeout: 5000,
    });
    await expect(salePanel.getByText("Bicycle")).not.toBeVisible({
      timeout: 5000,
    });
  });
  test("should be able to do single payment", async ({ page }) => {
    await oldPosLogin(
      page,
      true,
      "Salesperson Code",
      process.env?.[`E2E_OLD_MPOS_USERNAME`],
      process.env?.[`E2E_OLD_MPOS_PASSWORD`]
    );

    const frame = page.frameLocator("iframe");
    const salePanel = frame.locator("#sale-panel1-grid1");

    // Add Large Draft Beer
    const testItemsBtn = frame
      .locator("div[id^='button']", { hasText: "Test Items" })
      .first();
    await expect(testItemsBtn).toBeVisible({ timeout: 5000 });
    await testItemsBtn.click();

    const largeBeer = frame
      .locator("span", { hasText: "Large Draft Beer" })
      .first();
    await expect(largeBeer).toBeVisible({ timeout: 10000 });
    await largeBeer.click();

    await expect(
      salePanel.getByRole("cell", { name: "Large Draft Beer" })
    ).toBeVisible({ timeout: 5000 });

    // Add Small Draft Beer
    await expect(testItemsBtn).toBeVisible();
    await testItemsBtn.click();

    const smallBeer = frame.getByText("Small Draft Beer", { exact: true });
    await expect(smallBeer).toBeVisible();
    await smallBeer.click();

    await expect(
      salePanel.getByRole("cell", { name: "Small Draft Beer" })
    ).toBeVisible();

    // Payment flow
    const goToPayment = frame
      .locator("div[id^='button']", { hasText: "Go to payment" })
      .first();
    await expect(goToPayment).toBeVisible({ timeout: 5000 });
    await goToPayment.click();
    await page.waitForTimeout(5000);

    const cashPayment = frame
      .locator("div[id^='button']", { hasText: "Cash Payment" })
      .first();
    await expect(cashPayment).toBeVisible({ timeout: 5000 });
    await cashPayment.click();

    const cashOption = frame.getByText("Cash", { exact: true });
    await expect(cashOption).toBeVisible();
    await cashOption.click();

    const okBtn = frame.locator("#button-dialog-ok");
    await expect(okBtn).toBeVisible({ timeout: 5000 });
    await okBtn.click();

    // Verify items cleared
    await expect(salePanel.getByText("Large Draft Beer")).not.toBeVisible();
    await expect(salePanel.getByText("Small Draft Beer")).not.toBeVisible();
  });
  test("should be able to do multiple payment", async ({ page }) => {
    await oldPosLogin(
      page,
      true,
      "Salesperson Code",
      process.env?.[`E2E_OLD_MPOS_USERNAME`],
      process.env?.[`E2E_OLD_MPOS_PASSWORD`]
    );

    const frame = page.frameLocator("iframe");
    const salePanel = frame.locator("#sale-panel1-grid1");

    const testItemsBtn = () =>
      frame.locator("div[id^='button']", { hasText: "Test Items" }).first();

    // Add Large Draft Beer
    await expect(testItemsBtn()).toBeVisible({ timeout: 5000 });
    await testItemsBtn().click();

    const largeBeer = frame
      .locator("span", { hasText: "Large Draft Beer" })
      .first();
    await expect(largeBeer).toBeVisible({ timeout: 10000 });
    await largeBeer.click();

    await expect(
      salePanel.getByRole("cell", { name: "Large Draft Beer" })
    ).toBeVisible({ timeout: 5000 });

    // Add Small Draft Beer
    await expect(testItemsBtn()).toBeVisible({ timeout: 5000 });
    await testItemsBtn().click();

    const smallBeer = frame
      .locator("span", { hasText: "Small Draft Beer" })
      .first();
    await expect(smallBeer).toBeVisible({ timeout: 10000 });
    await smallBeer.click();

    await expect(
      salePanel.getByRole("cell", { name: "Small Draft Beer" })
    ).toBeVisible({ timeout: 5000 });

    // Payment flow (first payment: partial using 50)
    const goToPayment = frame
      .locator("div[id^='button']", { hasText: "Go to payment" })
      .first();
    await expect(goToPayment).toBeVisible({ timeout: 5000 });
    await goToPayment.click();
    await page.waitForTimeout(5000);

    const cashPaymentBtn = frame
      .locator("div[id^='button']", { hasText: "Cash Payment" })
      .first();
    await expect(cashPaymentBtn).toBeVisible({ timeout: 5000 });
    await cashPaymentBtn.click();

    const cashOption = frame.getByText("Cash", { exact: true });
    await expect(cashOption).toBeVisible({ timeout: 5000 });
    await cashOption.click();

    await frame.locator("span", { hasText: /^5$/ }).first().click();
    await frame.locator("span", { hasText: /^0$/ }).first().click();

    const okBtn = frame.locator("#button-dialog-ok");
    await expect(okBtn).toBeVisible({ timeout: 5000 });
    await okBtn.first().click();

    await expect(frame.getByRole("cell", { name: "Cash" })).toBeVisible({
      timeout: 5000,
    });
    await frame.getByRole("cell", { name: "Cash" }).click();
    await page.waitForTimeout(5000);

    // Payment flow (first payment: pay the rest)
    await expect(cashPaymentBtn).toBeVisible({ timeout: 5000 });
    await cashPaymentBtn.click();

    await expect(okBtn).toBeVisible({ timeout: 5000 });
    await okBtn.first().click();

    // Verify items cleared after payment
    await expect(salePanel.getByText("Large Draft Beer")).not.toBeVisible({
      timeout: 5000,
    });
    await expect(salePanel.getByText("Small Draft Beer")).not.toBeVisible({
      timeout: 5000,
    });

    await expect(testItemsBtn()).toBeVisible({ timeout: 5000 });
    await testItemsBtn().click();

    const largeBeer2 = frame
      .locator("span", { hasText: "Large Draft Beer" })
      .first();
    await expect(largeBeer2).toBeVisible({ timeout: 10000 });
    await largeBeer2.click();

    await expect(
      salePanel.getByRole("cell", { name: "Large Draft Beer" })
    ).toBeVisible({ timeout: 5000 });

    // Payment flow (second payment)
    await expect(goToPayment).toBeVisible({ timeout: 5000 });
    await goToPayment.click();
    await page.waitForTimeout(5000);

    await expect(cashPaymentBtn).toBeVisible({ timeout: 5000 });
    await cashPaymentBtn.click();

    await expect(okBtn).toBeVisible({ timeout: 5000 });
    await okBtn.first().click();

    // Verify items cleared after payment
    await expect(salePanel.getByText("Large Draft Beer")).not.toBeVisible({
      timeout: 5000,
    });
    await expect(salePanel.getByText("Small Draft Beer")).not.toBeVisible({
      timeout: 5000,
    });
  });
});
