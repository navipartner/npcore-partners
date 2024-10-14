import { expect, Page } from "@playwright/test";

export const restaurantSelectLayoutType = async (
  page: Page,
  isModern: boolean
) => {
  await page.goto("/BC/?page=6150669&tenant=default");
  await page.waitForLoadState("networkidle");
  await page.waitForSelector(".spinner", { state: "hidden" });

  const shouldAuthenticate = await page.getByRole("button", { name: "Sign In" }).count();
  if (shouldAuthenticate) {
    if(isModern){
      await page.getByLabel("User name:").fill(process.env.E2E_RESTAURANT_USERNAME ?? "");
      await page.getByLabel("Password:").fill(process.env.E2E_RESTAURANT_PASSWORD ?? "");
    } else {
      await page.getByLabel("User name:").fill(process.env.E2E_OLD_RESTAURANT_USERNAME ?? "");
      await page.getByLabel("Password:").fill(process.env.E2E_OLD_RESTAURANT_PASSWORD ?? "");
    }
    await page.getByRole("button", { name: "Sign In" }).click();
    await page.waitForLoadState("networkidle");
    await page.waitForSelector(".spinner", { state: "hidden" });
    await page.waitForTimeout(2000);
  }

  const popupLocator = page.locator("div").filter({
    hasText: /Caution: Your program license expires in \d+ days\.OK/,
  });
  const popupExists = await popupLocator.count();
  if (popupExists > 0) {
    await page.getByRole("button", { name: "OK" }).click();
    await page.waitForTimeout(5000); 
  }

  const tourDismissButton = page
    .frameLocator('iframe')
    .getByRole('button', { name: 'Dismiss' });
  if(await tourDismissButton.count() > 0){
    await tourDismissButton.click();
  }

  const editModeInactive = page
    .frameLocator('iframe')
    .getByRole('button', { name: /^Make changes on the page/ });
  if(await editModeInactive.count() > 0){
    await editModeInactive.click();
  }

  await page.waitForTimeout(2000);

  const restaurantViewMenuCollapsed = page
    .frameLocator('iframe')
    .locator("div.ms-nav-band.collapsed:has(span:has-text('Restaurant View'))");
  if(await restaurantViewMenuCollapsed.count() > 0){
    await restaurantViewMenuCollapsed.scrollIntoViewIfNeeded({ timeout: 5000 });
    await page
      .frameLocator('iframe')
      .getByRole('heading', { name: 'Restaurant View' })
      .click();
  }

  await page.waitForTimeout(2000);
  
  const saveLayoutActionElement = page
    .frameLocator('iframe')
    .getByRole('button', { name: 'Save Layout Action', exact: true });
  if(await saveLayoutActionElement.count() > 0){
    await saveLayoutActionElement.scrollIntoViewIfNeeded({ timeout: 5000 });
  }

  const restaurantViewLayoutDropdownHidden = page
    .frameLocator('iframe')
    .locator('div.multiple-columns-group div.ms-nav-group.ms-nav-hidden')
    .getByLabel('Restaurant View Layout');
  const restaurantViewLayoutDropdownHiddenExists = await restaurantViewLayoutDropdownHidden.count() > 0;

  if(restaurantViewLayoutDropdownHiddenExists){
    return false;
  }

  const restaurantViewLayoutDropdown = page
    .frameLocator('iframe')
    .getByLabel('Restaurant View Layout');
  const restaurantViewLayoutDropdownExists = await restaurantViewLayoutDropdown.count() > 0;

  if(restaurantViewLayoutDropdownExists){
    await restaurantViewLayoutDropdown.scrollIntoViewIfNeeded({ timeout: 5000 });
    if(isModern){
      await page.frameLocator('iframe').getByLabel('Restaurant View Layout').selectOption('1');
    } else {
      await page.frameLocator('iframe').getByLabel('Restaurant View Layout').selectOption('0');
    }
    await page.frameLocator('iframe').getByRole('button', { name: 'Back' }).click();
  }

  await page.waitForTimeout(2000);

  return restaurantViewLayoutDropdownExists;
};
