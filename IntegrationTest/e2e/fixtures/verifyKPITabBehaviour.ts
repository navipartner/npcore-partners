import { expect } from '@playwright/test';
import { getFrame } from './helperFunctions';

export async function verifyKPITabBehaviour(
  frame: ReturnType<typeof getFrame>,
  expectedHeaderText: string
) {
  const currentHeaderText = frame.getByText(expectedHeaderText);
  await expect(currentHeaderText).toHaveText(expectedHeaderText);

  const dropdown = frame.locator('select');
  await dropdown.click();

  await expect(dropdown).toBeVisible({
    timeout: 5000,
  });

  const optionCount = await dropdown.locator('option').count();

  if (optionCount === 0) {
    throw new Error('Dropdown has no options.');
  }

  const targetOption = dropdown.locator('option').nth(optionCount > 1 ? 1 : 0);
  const optionValue = await targetOption.getAttribute('value');

  if (!optionValue) {
    throw new Error(
      `${optionCount > 1 ? 'Second' : 'First'} option has no value attribute.`
    );
  }

  await dropdown.selectOption(optionValue);
  await expect(dropdown).toHaveValue(optionValue);

  const dateTextbox = await frame.getByRole('textbox').nth(3);

  await dateTextbox.click();

  const monthYearLabel = await frame
    .locator('.react-datepicker__current-month')
    .textContent();
  const [monthText, year] = monthYearLabel!.split(' ');

  const monthMap: Record<string, string> = {
    January: '01',
    February: '02',
    March: '03',
    April: '04',
    May: '05',
    June: '06',
    July: '07',
    August: '08',
    September: '09',
    October: '10',
    November: '11',
    December: '12',
  };
  const month = monthMap[monthText];

  const firstDay = frame
    .locator(
      '.react-datepicker__day:not(.react-datepicker__day--outside-month)'
    )
    .first();
  const clickedDay = (await firstDay.textContent())?.trim().padStart(2, '0');
  await firstDay.click();

  const selectedDate = await dateTextbox.inputValue();
  const expectedDate = `${clickedDay}/${month}/${year}`;

  expect(selectedDate).toBe(expectedDate);

  await frame.getByRole('button', { name: 'Day' }).click();

  const canvasLineChart = frame.locator('canvas');
  await expect(canvasLineChart).toBeVisible();
  const toggle = frame.locator('label.switch-component');
  await expect(toggle).toBeHidden();

  await frame.getByRole('button', { name: 'Week' }).click();
  const canvasBarChart = frame.locator('canvas');
  await expect(canvasBarChart).toBeVisible();
  await expect(toggle).toBeVisible();
  await expect(toggle).toHaveText(/Show Details\s*Hide Details/);
  await frame
    .locator('label')
    .filter({ hasText: 'Show DetailsHide Details' })
    .locator('label')
    .click();
  await expect(canvasBarChart).toBeVisible();
  await frame
    .locator('label')
    .filter({ hasText: 'Show DetailsHide Details' })
    .locator('label')
    .click();
  await expect(canvasBarChart).toBeVisible();
}
