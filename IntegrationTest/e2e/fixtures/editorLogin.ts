import { Page } from '@playwright/test';
import { loginAndCreateLayout } from './loginAndCreateLayout';

export const login = async (
  page: Page,
  salePersonCode: string,
  uniqueLayoutKey: string,
  username?: string,
  password?: string
) => {
  await loginAndCreateLayout(page, uniqueLayoutKey, username, password);

  await page
    .frameLocator('iframe')
    .getByRole('contentinfo')
    .locator('svg[data-icon="gear"]')
    .click();
  await page
    .frameLocator('iframe')
    .getByText(salePersonCode, { exact: true })
    .click();
  await page.frameLocator('iframe').getByText('OK', { exact: true }).click();
  const agreeOnBalancingQty = page
    .frameLocator('iframe')
    .getByText('Do you agree?');

  if (await agreeOnBalancingQty.isVisible()) {
    await page
      .frameLocator('iframe')
      .getByRole('button', { name: 'Yes', exact: true })
      .click();
  }
  await page.waitForTimeout(12000);
  const balancingText = page
    .frameLocator('iframe')
    .getByText('Confirm Bin Contents.');
  if (await balancingText.isVisible()) {
    await page.frameLocator('iframe').locator('#button-dialog-yes div').click();
  }
  await page.waitForTimeout(3000);
  const unfinishedSaleText = page
    .locator('[class="spa-view spa-dialog no-animations shown"]')
    .getByText('There is an unfinished sale, do you want to resume it?');
  if (await unfinishedSaleText.isVisible()) {
    await page.waitForTimeout(1000);
    await page.getByRole('button', { name: 'No' }).click();
  }
  const paymentBinText = page.getByText('Payment bin has never been balanced');
  if (await paymentBinText.isVisible()) {
    await page.waitForTimeout(1000);
    await page.getByRole('button', { name: 'Yes' }).click();
  }
  const unfinishedBalancingText = page.getByText(
    'Do you want to continue with balancing now?'
  );
  if (await unfinishedBalancingText.isVisible()) {
    await page.waitForTimeout(1000);
    await page.getByRole('button', { name: 'Yes' }).click();
    const textLocator = page.locator(
      'text=There is nothing to count in this payment bin.'
    );
    await page.waitForTimeout(1000);
    if (await textLocator.isVisible()) {
      await page.getByRole('button', { name: 'OK' }).click();
    } else {
      await page
        .frameLocator('iframe')
        .getByRole('button', { name: 'Cancel' })
        .click();
      await page
        .frameLocator('iframe')
        .locator('span')
        .filter({ hasText: 'Yes' })
        .first()
        .click();
    }
    await page.waitForTimeout(1000);
    await page
      .frameLocator('iframe')
      .getByText(salePersonCode, { exact: true })
      .click();
    await page.frameLocator('iframe').getByText('OK', { exact: true }).click();
  }
  if (await agreeOnBalancingQty.isVisible()) {
    await page.frameLocator('iframe').locator('#button-dialog-yes div').click();
  }
  await page.waitForTimeout(2000);
};
