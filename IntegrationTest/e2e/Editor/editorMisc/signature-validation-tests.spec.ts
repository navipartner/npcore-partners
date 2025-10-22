import { expect, test } from "@playwright/test";

import { login } from "../../fixtures/editorLogin";
import { removeLayout } from "../../fixtures/removeLayout";

test.skip()

declare global {
  interface Window {
    Dragonglass?: {
      WorkflowPopupCoordinator: new () => {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        signatureValidation: (options: any) => any;
      };
    };
  }
}

test.describe("Signature validation", () => {
  test("canvas should be visible", async ({ page }, workerInfo) => {
    const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
    const salePersonCode = (workerInfo.parallelIndex + 1).toString();

    await login(
      page,
      salePersonCode,
      key,
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
      process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
    );

    await page.evaluate(async () => {
      const wf =
        window.top && window.top.Dragonglass
          ? new window.top.Dragonglass.WorkflowPopupCoordinator()
          : undefined;
      const signature = [
        { x: "10", y: "10" },
        { x: "20", y: "20" },
      ];

      if (wf) {
        await wf.signatureValidation({ signature });
      }
    });
    const canvasLocator = page.frameLocator("iframe").locator("canvas");
    await expect(canvasLocator).toBeVisible();
    await page.frameLocator("iframe").locator("#btn_approve div").click();
    await removeLayout(page, key);
  });

  test("signature validation approve button should be enabled when signature is present", async ({
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
    await page.evaluate(async () => {
      const wf =
        window.top && window.top.Dragonglass
          ? new window.top.Dragonglass.WorkflowPopupCoordinator()
          : undefined;
      const signature = [
        { x: "10", y: "10" },
        { x: "20", y: "20" },
      ];
      if (wf) {
        const dialog = await wf.signatureValidation({ signature });

        dialog.updateSignature(signature, {});
      }
    });
    const canvasLocator = page.frameLocator("iframe").locator("canvas");
    await expect(canvasLocator).toBeVisible();
    await page.frameLocator("iframe").locator("#btn_approve div").click();
    await removeLayout(page, key);
  });

  test("signature validation approve button should be disabled when no signature", async ({
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

    await page.evaluate(async () => {
      const wf =
        window.top && window.top.Dragonglass
          ? new window.top.Dragonglass.WorkflowPopupCoordinator()
          : undefined;
      if (wf) {
        await wf.signatureValidation({ showSignature: false });
      }
    });

    await page.frameLocator("iframe").locator("#btn_approve div").click();
    await page.frameLocator("iframe").locator("#btn_approve div").isVisible();
    await page.frameLocator("iframe").locator("#btn_decline div").click();
    await removeLayout(page, key);
  });

  test("signature validation displays extra fields when parameters are provided", async ({
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

    await page.evaluate(async () => {
      const wf =
        window.top && window.top.Dragonglass
          ? new window.top.Dragonglass.WorkflowPopupCoordinator()
          : undefined;
      const signature = [
        { x: "10", y: "10" },
        { x: "20", y: "20" },
      ];
      if (wf) {
        const dialog = await wf.signatureValidation({ signature });
        dialog.updateSignature(signature, {
          showEmail: true,
          emailData: "test@example.com",
          showPhoneNo: true,
          phoneNoData: "1234567890",
          showSignature: true,
        });
      }
    });
    const frame = page.frameLocator("iframe");
    await expect(frame.locator('label:text("Email:")')).toBeVisible();
    await expect(frame.locator('input[type="email"]')).toHaveValue(
      "test@example.com"
    );
    await expect(frame.locator('label:text("Phone Number:")')).toBeVisible();
    await expect(frame.locator('input[type="tel"]')).toHaveValue("1234567890");
    await page.frameLocator("iframe").locator("#btn_approve div").click();
    await removeLayout(page, key);
  });

  test("signature canvas should be hidden if showSignature is false", async ({
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
    await page.evaluate(async () => {
      const wf =
        window.top && window.top.Dragonglass
          ? new window.top.Dragonglass.WorkflowPopupCoordinator()
          : undefined;
      const signature = [
        { x: "10", y: "10" },
        { x: "20", y: "20" },
      ];
      if (wf) {
        const dialog = await wf.signatureValidation({ signature });
        dialog.updateSignature(signature, { showSignature: false });
      }
    });

    const canvas = page.frameLocator("iframe").locator("canvas");
    await expect(canvas).not.toBeVisible();
    await page.frameLocator("iframe").locator("#btn_decline div").click();
    await removeLayout(page, key);
  });
});