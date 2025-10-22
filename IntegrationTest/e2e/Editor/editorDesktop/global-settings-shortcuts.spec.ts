import test, { expect } from "@playwright/test";
import { login } from "../../fixtures/editorLogin";
import { addItemToSale, getFrame } from "../../fixtures/helperFunctions";
import { removeLayout } from "../../fixtures/removeLayout";

test.skip()

test("should complete payment successfully using created shortcuts", async ({
  page,
}, workerInfo) => {
  const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
  const salePersonCode = (workerInfo.parallelIndex + 1).toString();
  await login(
    page,
    salePersonCode,
    key,
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
  );

  const frame = getFrame(page);

  await frame.locator("#footer-cog-button svg").click();
  await frame.locator("button:nth-child(16)").click();
  await frame.getByRole("button", { name: "Shortcuts" }).click();
  await frame.getByPlaceholder("Click to add a shortcut").click();
  await frame.getByPlaceholder("Click to add a shortcut").press("Control+q");
  await frame.getByPlaceholder("Click to add an action").click();
  await page.getByLabel(/(Untitled field|Search POS Actions)/).click();
  await page.getByLabel(/(Untitled field|Search POS Actions)/).fill("QUANTITY");
  await page.waitForTimeout(1000);
  const cellQuantity = await page
    .getByRole("row")
    .filter({ hasText: "QUANTITY" })
    .locator("td")
    .first();

  await expect(cellQuantity).toBeVisible();
  await cellQuantity.click();

  await frame.getByRole("button", { name: "Edit parameters" }).first().click();
  await frame
    .locator("div")
    .filter({
      hasText: /^Change To QuantityDefines change to quantityText\.\.\.$/,
    })
    .getByRole("textbox")
    .click();
  await frame
    .locator("div")
    .filter({
      hasText: /^Change To QuantityDefines change to quantityText\.\.\.$/,
    })
    .getByRole("textbox")
    .fill("+1");
  await frame.getByRole("button", { name: "Save" }).nth(1).click();
  await frame.getByRole("button", { name: "Add shortcut" }).click();
  await frame.getByPlaceholder("Click to add a shortcut").nth(1).click();
  await frame
    .getByPlaceholder("Click to add a shortcut")
    .nth(1)
    .press("Control+p");
  await frame.getByPlaceholder("Click to add an action").nth(1).click();
  await page.getByLabel(/(Untitled field|Search POS Actions)/).click();
  await page
    .getByLabel(/(Untitled field|Search POS Actions)/)
    .fill("CANCEL_POS_SALE");
  await page.waitForTimeout(1000);
  const cellCancelPosSale = await page
    .getByRole("row")
    .filter({ hasText: "CANCEL_POS_SALE" })
    .locator("td")
    .first();
  await expect(cellCancelPosSale).toBeVisible();
  await cellCancelPosSale.click();
  await frame.getByRole("button", { name: "Add shortcut" }).click();
  await frame.getByPlaceholder("Click to add a shortcut").nth(2).click();
  await frame
    .getByPlaceholder("Click to add a shortcut")
    .nth(2)
    .press("Control+y");
  await frame.getByPlaceholder("Click to add an action").nth(2).click();
  await page.getByLabel(/(Untitled field|Search POS Actions)/).click();
  await page
    .getByLabel(/(Untitled field|Search POS Actions)/)
    .fill("PAYMENT_2");
  await page.waitForTimeout(1000);
  const cellPayment2 = await page
    .getByRole("row")
    .filter({ hasText: "PAYMENT_2" })
    .locator("td")
    .first();

  await expect(cellPayment2).toBeVisible();
  await cellPayment2.click();

  await frame.getByRole("button", { name: "Edit parameters" }).nth(2).click();
  await frame
    .locator("div")
    .filter({ hasText: /^Payment Method CodePayment Method CodeText\.\.\.$/ })
    .getByRole("textbox")
    .click();
  await frame
    .locator("div")
    .filter({ hasText: /^Payment Method CodePayment Method CodeText\.\.\.$/ })
    .getByRole("textbox")
    .fill("K");
  await frame
    .locator("div")
    .filter({
      hasText:
        /^Try End SaleTry to end the sale after the payment is processed\.Boolean\.\.\.$/,
    })
    .getByRole("textbox")
    .click();
  await frame
    .locator("div")
    .filter({
      hasText:
        /^Try End SaleTry to end the sale after the payment is processed\.Boolean\.\.\.$/,
    })
    .getByRole("textbox")
    .fill("true");
  await page.waitForTimeout(2000);

  await frame.getByRole("button", { name: "Save" }).nth(1).click();
  await frame
    .locator("label")
    .filter({ hasText: "Enable shortcuts" })
    .locator("label")
    .click();
  await frame.getByRole("button", { name: "Close" }).click();
  await addItemToSale(page, "BELLING COOKER HOOD 100CM");
  await frame.getByRole("cell", { name: "100CHIMSTA" }).click();
  await frame.locator("body").press("Control+q");
  await frame.getByTestId("search-input").click();
  await frame.getByTestId("search-input").fill("2");
  await frame.locator("span").filter({ hasText: "OK" }).first().click();
  const saleRow = frame
    .locator("table")
    .locator("tr", { hasText: "100CHIMSTA" });

  await expect(saleRow.locator("td").nth(4)).toHaveText("2.00", {
    timeout: 5000,
  });
  const qtyText = await saleRow.locator("td").nth(4).innerText();

  const unitPriceText = await saleRow.locator("td").nth(8).innerText();
  const amountInclVatText = await saleRow.locator("td").nth(14).innerText();

  const qty = parseFloat(qtyText);
  const unitPrice = parseFloat(unitPriceText);
  const actualAmount = parseFloat(amountInclVatText);
  const expectedAmount = qty * unitPrice;

  expect(actualAmount).toBeCloseTo(expectedAmount, 2);
  await frame.getByRole("cell", { name: "100CHIMSTA" }).click();
  await frame.locator("body").press("Control+p");
  await frame.locator("span").filter({ hasText: "Yes" }).first().click();
  const saleLinesBody = frame.locator("table tbody tr");
  await expect(saleLinesBody).toHaveCount(0);
  await addItemToSale(page, "BELLING COOKER HOOD 100CM");
  await frame.getByRole("button", { name: "Go To Payment" }).click();
  await frame.getByText("Run CHANGE_VIEW").click();
  await frame.getByRole("button", { name: "Cash Payment" }).click();
  await frame
    .getByRole("button", { name: "Terminal", exact: true })
    .press("Control+y");
  await frame.locator("span").filter({ hasText: "OK" }).first().click();
  const updatedSaleLinesBody = frame.locator("table tbody tr");
  await expect(updatedSaleLinesBody).toHaveCount(0, { timeout: 7000 });
  await page
    .frameLocator("iframe")
    .getByRole("button", { name: "Save" })
    .click();
  await page.waitForTimeout(3000);
  await page
    .frameLocator("iframe")
    .getByRole("button", { name: "Overwrite current layout" })
    .click();
  await page.waitForTimeout(3000);
  await removeLayout(page, key);

  await page.waitForTimeout(3000);
});
