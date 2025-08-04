import test from '@playwright/test';
import { loginAndCreateLayout } from '../../fixtures/loginAndCreateLayout';
import { getFrame } from '../../fixtures/helperFunctions';
import { verifyKPITabBehaviour } from '../../fixtures/verifyKPITabBehaviour';
import { switchUserRegion } from '../../fixtures/switchUserRegion';
import { removeLayout } from '../../fixtures/removeLayout';

test('should verify KPI tab behaviour for each tab', async ({
  page,
}, workerInfo) => {
  const key = `${new Date().getTime()}-WORKER${workerInfo.parallelIndex}`;
  const uniqueLayoutKey = `${Date.now()}-WORKER${workerInfo.parallelIndex}`;
  const username =
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_USERNAME`];
  const password =
    process.env?.[`E2E_USER_${workerInfo.parallelIndex}_PASSWORD`];

  const frame = getFrame(page);

  await switchUserRegion(page, 'English (United Kingdom)', username, password);
  await loginAndCreateLayout(page, uniqueLayoutKey, username, password);

  await frame.locator('div:nth-child(2) > div:nth-child(2) > button').click();
  await frame.getByRole('button', { name: 'Total Sales' }).click();
  await verifyKPITabBehaviour(frame, 'Total Amount of Sales');

  await frame.getByRole('button', { name: 'Total Customers' }).click();
  await verifyKPITabBehaviour(frame, 'Total Amount of Customers');

  await frame.getByRole('button', { name: 'Sales Per Customer' }).click();
  await verifyKPITabBehaviour(frame, 'Sales Per Customer');

  await frame.getByRole('button', { name: 'Sales Per Product' }).click();
  await verifyKPITabBehaviour(frame, 'Sales Per Product');

  await removeLayout(page, key);
});
