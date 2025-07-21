import test from '@playwright/test';
import {
  createAndRunNestedMenu,
  expectButtonVisible,
  populateGlobalSettingsModal,
} from '../../fixtures/nestedMenusHelpers';
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

test.describe('Global settings Sale nested menus tests', () => {
  test('should close Sale nested menu after action', async ({ page }) => {
    await populateGlobalSettingsModal(page, 'sale', 16, 3);

    await createAndRunNestedMenu(page, {
      buttonIndex: 6,
      buttonLabel: 'Sale Test',
      nestedMenuId: 'sale_id',
      columnsNumber: '6',
      useHeadingForVariables: true,
    });

    await expectButtonVisible(page, 'Sale Test');
  });

  test('should keep Sale nested menu opened after action when global settings modal is not populated', async ({
    page,
  }) => {
    await page
      .frameLocator('iframe')
      .getByRole('contentinfo')
      .locator('svg[data-icon="gear"]')
      .click();

    await createAndRunNestedMenu(page, {
      buttonIndex: 6,
      buttonLabel: 'Sale Test',
      nestedMenuId: 'sale_id',
      columnsNumber: '6',
      useHeadingForVariables: true,
    });

    await expectButtonVisible(page, 'Test nested menu');
  });
});
