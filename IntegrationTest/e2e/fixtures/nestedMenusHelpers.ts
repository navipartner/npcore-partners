import { expect, FrameLocator, Page } from '@playwright/test';

export const getFrame = (page: Page): FrameLocator => {
  return page.frameLocator('iframe');
};

type GlobalSettingsMode = 'login' | 'sale' | 'payment';

export const populateGlobalSettingsModal = async (
  page: Page,
  mode: GlobalSettingsMode,
  buttonIndex: number,
  selectDivIndex: number
) => {
  const frame = getFrame(page);

  const skipGearClick = mode === 'login';

  if (!skipGearClick) {
    await page
      .frameLocator('iframe')
      .getByRole('contentinfo')
      .locator('svg[data-icon="gear"]')
      .click();
  }

  await frame.locator(`button:nth-child(${buttonIndex})`).click();

  if (mode === 'login') {
    await frame
      .locator(
        `div:nth-child(${selectDivIndex}) > div > div > .select > .css-b62m3t-container > .react-select__control > .react-select__value-container > .react-select__input-container`
      )
      .first()
      .click();
  } else {
    await frame
      .locator(
        `div:nth-child(${selectDivIndex}) > div > .select > .css-b62m3t-container > .react-select__control > .react-select__indicators > .react-select__indicator`
      )
      .click();
  }

  await frame.getByText('GRID_1', { exact: true }).click();
  await frame.getByRole('button', { name: 'Close' }).click();
};

export const openGridAndSetColumns = async (
  page: Page,
  columnsNumber: string
) => {
  const frame = getFrame(page);
  await frame.getByRole('button', { name: 'Grids' }).click();
  await frame.locator('.css-8mmkcg').first().click();
  await frame.getByText('GRID_1', { exact: true }).click();
  await frame.locator('#columnsNr').click();
  await frame.locator('#columnsNr').fill(columnsNumber);
  await frame.locator('.body > div:nth-child(2) > div:nth-child(2)').click();
};

export const createButton = async (
  page: Page,
  config: {
    buttonIndex: number;
    buttonLabel: string;
    nestedMenuAction: string;
    nestedMenuId: string;
  }
) => {
  const frame = getFrame(page);

  await frame
    .locator(
      `div:nth-child(${config.buttonIndex}) > .editable-button__content > .editable-button__button`
    )
    .first()
    .click();

  await frame.getByText('Edit', { exact: true }).click();

  const textbox = frame
    .locator('div')
    .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
    .getByRole('textbox')
    .first();

  await textbox.click();
  await textbox.fill(config.buttonLabel);

  await frame.getByText('VariablesPlease select an').click();

  await frame
    .locator(
      'div:nth-child(2) > .css-b62m3t-container > .react-select__control > .react-select__indicators > .react-select__indicator'
    )
    .first()
    .click();

  await frame.getByText(config.nestedMenuAction, { exact: true }).click();

  await frame.getByRole('button', { name: 'Enter new id' }).click();
  await frame.getByTestId('search-input').fill(config.nestedMenuId);
  await frame.locator('span').filter({ hasText: 'OK' }).first().click();

  await frame.getByRole('button', { name: 'Save' }).nth(1).click();
};

export const openNestedMenu = async (page: Page, buttonLabel: string) => {
  const frame = getFrame(page);
  await frame.getByRole('button', { name: buttonLabel }).click();
  await frame.getByText('Run OPEN_NESTED_MENU').click();
};

export const createButtonInsideNestedMenu = async (
  page: Page,
  useHeadingForVariables: boolean
) => {
  const frame = getFrame(page);

  await frame.locator('.editable-button__button').first().click();
  await frame.getByText('Edit', { exact: true }).click();

  const captionInput = frame
    .locator('div')
    .filter({ hasText: /^Caption2nd Caption3rd Caption$/ })
    .getByRole('textbox')
    .first();
  await captionInput.click();
  await captionInput.fill('Test nested menu');

  if (useHeadingForVariables) {
    await frame.getByRole('heading', { name: 'Variables' }).click();
  } else {
    await frame
      .getByText(
        'ColorIconImageTooltipEnabledCaption2nd Caption3rd CaptionActionData'
      )
      .click();
  }

  const dropdownLocator = frame
    .locator(
      'div:nth-child(2) > .css-b62m3t-container > .react-select__control > .react-select__indicators > .react-select__indicator'
    )
    .first();

  await dropdownLocator.click();
  await frame.getByText('Select Customer', { exact: true }).click();

  await page.getByRole('button', { name: 'Cancel' }).click();
  await frame.getByRole('button', { name: 'Save' }).nth(1).click();
};

export const runAction = async (page: Page) => {
  const frame = getFrame(page);
  await frame.getByRole('button', { name: 'Test nested menu' }).click();
  await frame.getByText('Run SELECT_CUSTOMER').click();
  await page.getByRole('button', { name: 'Cancel' }).click();
};

export const expectButtonVisible = async (
  page: Page,
  buttonLabel: string
): Promise<void> => {
  const frame = getFrame(page);
  await expect(frame.getByText(buttonLabel, { exact: true })).toBeVisible();
};

export const goToPaymentPage = async (page: Page, pageName: string) => {
  const frame = getFrame(page);
  await frame.getByRole('button', { name: `Go to ${pageName}` }).click();
};

export const createAndRunNestedMenu = async (
  page: Page,
  config: {
    buttonIndex: number;
    buttonLabel: string;
    nestedMenuId: string;
    columnsNumber: string;
    useHeadingForVariables: boolean;
  }
) => {
  await openGridAndSetColumns(page, config.columnsNumber);
  await createButton(page, {
    buttonIndex: config.buttonIndex,
    buttonLabel: config.buttonLabel,
    nestedMenuAction: 'Open Nested Menu',
    nestedMenuId: config.nestedMenuId,
  });
  await openNestedMenu(page, config.buttonLabel);
  await createButtonInsideNestedMenu(page, config.useHeadingForVariables);
  await runAction(page);
};
