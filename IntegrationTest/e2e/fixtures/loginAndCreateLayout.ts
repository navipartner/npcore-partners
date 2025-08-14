import { Page } from '@playwright/test';

export const loginAndCreateLayout = async (
  page: Page,
  uniqueLayoutKey: string,
  username?: string,
  password?: string
) => {
  await page.goto('/BC/Tablet.aspx?page=6150750&tenant=default');
  const shouldAuthenticate = await page
    .getByRole('button', { name: 'Sign In' })
    .count();
  if (shouldAuthenticate > 0) {
    await page.getByLabel('User name:').fill(username ?? '');
    await page.getByLabel('Password:').fill(password ?? '');
    await page.getByRole('button', { name: 'Sign In' }).click();
  }
  
  await page.waitForLoadState('networkidle');
  await page.waitForSelector('.spinner', { state: 'hidden', timeout: 20000 });

  const popupLocator = page.locator('[id=b3]');
  if ((await popupLocator.count()) > 0) {
    await page.getByRole('button', { name: 'OK' }).click();
  }

  await page
  .frameLocator('iframe')
  .getByRole('contentinfo')
  .locator('svg[data-icon="gear"]')
  .click();
  await page
    .frameLocator('iframe')
    .getByRole('button', { name: 'New Layout' })
    .click();
  await page
    .frameLocator('iframe')
    .getByRole('button', { name: 'Copy Existing Layout' })
    .click();
  await page
    .frameLocator('iframe')
    .locator(
      '.new-layout-modal__content-inner > .select > .css-b62m3t-container > .react-select__control > .react-select__indicators'
    )
    .click();
  await page
    .frameLocator('iframe')
    .getByText('E2E Base layout', { exact: true })
    .click();

  const textboxIndex = (await page
    .frameLocator('iframe')
    .getByRole('textbox')
    .nth(3)
    .isVisible())
    ? 3
    : 2;

  await page
    .frameLocator('iframe')
    .getByRole('textbox')
    .nth(textboxIndex)
    .fill(`E2E Testing ${uniqueLayoutKey}`);

  await page
    .frameLocator('iframe')
    .getByRole('button', { name: 'Create', exact: true })
    .click();

  await page.waitForSelector('.new-layout-modal', { state: 'hidden' });
};
