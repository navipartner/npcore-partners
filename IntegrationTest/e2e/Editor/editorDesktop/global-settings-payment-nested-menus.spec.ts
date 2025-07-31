import test from '@playwright/test';
import {
  createAndRunNestedMenu,
  expectButtonVisible,
  goToPaymentPage,
  populateGlobalSettingsModal,
} from '../../fixtures/helperFunctions';
import { login } from '../../fixtures/editorLogin';

test.beforeEach(async ({ page }, workerInfo) => {
  const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
  const salePersonCode = (workerInfo.parallelIndex + 1).toString();
  await login(
    page,
    salePersonCode,
    key,
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`],
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`]
  );
});

test.describe('Global settings Payment nested menus tests', () => {
  test('should close Payment nested menu after action', async ({ page }) => {
    await goToPaymentPage(page, 'Payment');

    await populateGlobalSettingsModal(page, 'payment', 16, 4);

    await createAndRunNestedMenu(page, {
      buttonIndex: 24,
      buttonLabel: 'Payment Test',
      nestedMenuId: 'payment_id',
      columnsNumber: '6',
      useHeadingForVariables: true,
    });

    await expectButtonVisible(page, 'Payment Test');
  });

  test('should keep Payment nested menu opened after action when global settings modal is not populated', async ({
    page,
  }) => {
    await goToPaymentPage(page, 'Payment');
    await page
      .frameLocator('iframe')
      .getByRole('contentinfo')
      .locator('svg[data-icon="gear"]')
      .click();

    await createAndRunNestedMenu(page, {
      buttonIndex: 24,
      buttonLabel: 'Payment Test',
      nestedMenuId: 'payment_id',
      columnsNumber: '6',
      useHeadingForVariables: true,
    });

    await expectButtonVisible(page, 'Test nested menu');
  });
});
