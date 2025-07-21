import test from '@playwright/test';
import { loginAndCreateLayout } from '../../fixtures/loginAndCreateLayout';
import {
  createAndRunNestedMenu,
  expectButtonVisible,
  populateGlobalSettingsModal,
} from '../../fixtures/nestedMenusHelpers';

test.beforeEach(async ({ page }, workerInfo) => {
  const uniqueLayoutKey = `${Date.now()}-WORKER${workerInfo.parallelIndex}`;
  const username =
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`];
  const password =
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`];

  await loginAndCreateLayout(page, uniqueLayoutKey, username, password);
});

test.describe('Global settings Login nested menus tests', () => {
  test('should close Login nested menu after action', async ({ page }) => {
    await populateGlobalSettingsModal(page, 'login', 14, 7);

    await createAndRunNestedMenu(page, {
      buttonIndex: 3,
      buttonLabel: 'Login Test',
      nestedMenuId: 'test_id',
      columnsNumber: '3',
      useHeadingForVariables: false,
    });

    await expectButtonVisible(page, 'Login Test');
  });

  test('should keep Login nested menu opened after action when global settings modal is not populated', async ({
    page,
  }) => {
    await createAndRunNestedMenu(page, {
      buttonIndex: 3,
      buttonLabel: 'Login Test',
      nestedMenuId: 'test_id',
      columnsNumber: '3',
      useHeadingForVariables: false,
    });

    await expectButtonVisible(page, 'Test nested menu');
  });
});
