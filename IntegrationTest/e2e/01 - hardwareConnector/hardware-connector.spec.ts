import { expect, test } from "@playwright/test";
import { login } from "../fixtures/editorLogin";
import { removeLayout } from "../fixtures/removeLayout";

test.describe("Hardware connector tests", () => {
  test("Prints last receipt", async ({ page }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
    const salePersonCode = (workerInfo.parallelIndex + 1).toString();
    const expectedPrintJob =
      "G0AbdBAbYTAKG0UxG2ExHSEAG00wUmV0YWlsIFN0b3JlG0UwChthMR0hABtNMDEwMDBL+GJlbmhhdm4gSwobYTAdIQAbTTAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KG0UxG2EwHSEAG00wRGVzY3JpcHRpb24gICAgICAgIBtFMBtFMRthMB0hABtNMFF1YW50aXR5ICAgICAgG0UwG0UxG2EwHSEAG00wICAgQW1vdW50G0UwChthMB0hABtNMC0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLQobYTAdIQAbTTAtLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0KG2EwHSEAG00wLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tLS0tChtFMRthMB0hABtNMFRvdGFsREtLICAgICAgICAgICAgIBtFMBtFMRthMB0hABtNMCAgICAgICAgICAgICAgICAzNS4wMBtFMAobYTAdIQAbTTBDYXNoICAgICAgICAgICAgICAgICAbYTAdIQAbTTAgICAgICAgICAgICAgICAgMzUuMDAKG2ExHXcDHWgoHWtJBXtCNjY2NjY2CgobYTEdIQAbTTAKG2ExHSEAG00wUkVNRU1CRVIgVE8gS0VFUCBUSElTIFRJQ0tFVAobYTEdIQAbTTBJTiBDQVNFIFlPVSBORUVEIFRPIEVYQ0hBTkdFIFRIRSBJVEVNChthMR0hABtNMFdJVEhJTiAxNSBEQVlTIE9GIFBVUkNIQVNFChthMR0hABtNMCoqKioqKgobYTAdIQAbTTAwMSAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKHVZCAw==";
    const printJobLogs: string[] = [];

    await login(
      page,
      salePersonCode,
      key,
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
    );

    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Test Items" })
      .click();

    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Small Draft Beer" })
      .click();

    await page
      .frameLocator("iframe")
      .getByRole("button", { name: "Go to Payment" })
      .click();

    page.on("console", async (msg) => {
      const args = await Promise.all(msg.args().map((arg) => arg.jsonValue()));
      const message = args.join(" ");
      if (message.includes('"PrintJob"')) {
        printJobLogs.push(message);
      }
    });

    const capturedPrintJobs = () =>
      printJobLogs
        .map((log) => log.match(/"PrintJob"\s*:\s*"([^"]+)"/)?.[1])
        .filter((value): value is string => Boolean(value));

    const cashPaymentButton = page
      .frameLocator("iframe")
      .getByRole("button", { name: "Cash Payment" });
    await cashPaymentButton.waitFor({ state: "visible", timeout: 10000 });
    await cashPaymentButton.click();
    await page.frameLocator("iframe").locator("#button-dialog-ok div").click();

    await expect.poll(capturedPrintJobs, {
      timeout: 10000,
      intervals: [250, 500, 1000],
      message: "Expected receipt PrintJob to be logged after cash payment completed",
    }).toContain(expectedPrintJob);

    await removeLayout(page, key);
  });
});
