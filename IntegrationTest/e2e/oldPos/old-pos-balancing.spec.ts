import { test, expect, FrameLocator, Locator } from "@playwright/test";
import { oldPosLogin } from "../fixtures/oldPosLogin";

test.skip()

test.describe("Old POS balancing test", () => {
  let frame: FrameLocator;
  let salePanel: Locator;

  test.beforeEach(async ({ page }) => {
    // Login
    await oldPosLogin(
      page,
      true,
      "Salesperson Code",
      process.env?.[`E2E_OLD_MPOS_USERNAME`],
      process.env?.[`E2E_OLD_MPOS_PASSWORD`]
    );

    frame = page.frameLocator("iframe");
    salePanel = frame.locator("#sale-panel1-grid1");

    // Add item to sale line
    const testItemsBtn = frame
      .locator("div[id^='button']", { hasText: "Test Items" })
      .first();

    if (await testItemsBtn.isVisible()) {
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

      // Add item to sale line
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
      await page.waitForTimeout(2000);

      const cashPayment = frame
        .locator("div[id^='button']", { hasText: "Cash Payment" })
        .first();
      await expect(cashPayment).toBeVisible({ timeout: 5000 });
      await cashPayment.click();
      await page.waitForTimeout(2000);

      const cashOption = frame.getByText("Cash", { exact: true });
      await expect(cashOption).toBeVisible({ timeout: 5000 });
      await cashOption.click();

      const okBtn = frame.locator("#button-dialog-ok");
      await expect(okBtn).toBeVisible({ timeout: 5000 });
      await okBtn.click();

      // Verify items cleared
      await expect(salePanel.getByText("Large Draft Beer")).not.toBeVisible();
      await expect(salePanel.getByText("Small Draft Beer")).not.toBeVisible();

      // Balancing menu open
      const goToOtherFunctions = frame
        .locator("div[id^='button']", { hasText: "Other Functions" })
        .first();
      await expect(goToOtherFunctions).toBeVisible({ timeout: 5000 });
      await goToOtherFunctions.click();

      const endOfTheDayBalancing = frame
        .locator("div[id^='button']", {
          hasText: "End Of Day Balancing (Balance",
        })
        .first();
      await expect(endOfTheDayBalancing).toBeVisible({ timeout: 5000 });
      await endOfTheDayBalancing.click();

      await page.waitForTimeout(5000);
      const deleteSavedSalesCheck = page.getByRole("radio", {
        name: "Delete all saved POS Saved",
      });

      // Handle dialog if present
      if (await deleteSavedSalesCheck.isVisible({ timeout: 5000 })) {
        await deleteSavedSalesCheck.click();

        const okBtn = page.getByRole("button", { name: "OK" });
        await expect(okBtn).toBeVisible({ timeout: 5000 });
        await okBtn.click();
      }
    }
  });

  test("should be able to do end of the day balancing by manual entering amount", async ({
    page,
  }) => {
    const pressNumpadKey = async (testId: string) => {
      const key = frame.getByTestId(testId);
      await expect(key).toBeVisible({ timeout: 3000 });
      await key.click();
    };

    await pressNumpadKey("numpad-input-button-8");
    await pressNumpadKey("numpad-input-button-0");

    await frame.getByTestId("counting-finalize-button").click();
    await page.waitForTimeout(2000);
    await expect(frame.getByText("K finalized")).toBeVisible();
    await frame.getByRole("button", { name: "Complete balancing" }).click();
    await page.waitForTimeout(2000);
    await expect(frame.getByText("Balance")).toBeVisible();
  });

  test("should be able to do end of the day balancing by counting coins", async ({
    page,
  }) => {
    const coinTrigger = frame
      .locator(".balance-counting__coin-count-modal-trigger > button")
      .first();
    await coinTrigger.waitFor({ state: "visible", timeout: 10000 });
    await coinTrigger.click();

    const countingRow8 = frame.getByTestId("undefined-row-8");
    await countingRow8.waitFor({ state: "visible", timeout: 8000 });
    await countingRow8.getByText("10").click();

    const numpad3 = frame
      .getByTestId("counting-numpad-wrapper")
      .getByTestId("numpad-input-button-3");
    await numpad3.waitFor({ state: "visible", timeout: 5000 });
    await numpad3.click();

    const countingRow9 = frame.getByTestId("undefined-row-9");
    await countingRow9.waitFor({ state: "visible", timeout: 8000 });
    await countingRow9.getByText("50").click();

    const numpad1 = frame
      .getByTestId("counting-numpad-wrapper")
      .getByTestId("numpad-input-button-1");
    await numpad1.waitFor({ state: "visible", timeout: 5000 });
    await numpad1.click();

    const closeBtn = frame.getByTestId("counting-button-close");
    await closeBtn.waitFor({ state: "visible", timeout: 5000 });
    await closeBtn.click();

    await frame.getByTestId("counting-finalize-button").click();
    await page.waitForTimeout(2000);
    await expect(frame.getByText("K finalized")).toBeVisible();
    await frame.getByRole("button", { name: "Complete balancing" }).click();
    await page.waitForTimeout(2000);
    await expect(frame.getByText("Balance")).toBeVisible();
  });
});
