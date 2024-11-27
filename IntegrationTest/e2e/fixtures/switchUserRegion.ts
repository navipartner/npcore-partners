import { Page } from "@playwright/test";

// BC17~BC18: page 9176
// BC19~BC25: page 9204

export const switchUserRegion = async (
  page: Page,
  regionName?: string,
  username?: string,
  password?: string
) => {
  const regionInput = regionName ?? "English (United States)";

  // BC19 ~ BC24 - open "My Settings" page 9204
  await page.goto("/BC/?page=9204&tenant=default");
  await page.waitForLoadState("networkidle");
  try {
    await page.waitForSelector(".spinner", { state: "hidden", timeout: 20000 });
  } catch (error) {
    console.warn("Spinner did not disappear within 20 seconds, reloading the page...");
    await page.goto("/BC/?page=9204&tenant=default");
    await page.waitForSelector(".spinner", { state: "hidden", timeout: 20000 });
  }
  const shouldAuthenticate = await page.getByRole("button", { name: "Sign In" }).count();
  if (shouldAuthenticate > 0) {
    await page.getByLabel("User name:").fill(username ?? "");
    await page.getByLabel("Password:").fill(password ?? "");
    await page.getByRole("button", { name: "Sign In" }).click();
  }

  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(5000);

  // BC17~BC18 - open "My Settings" page 9176
  const wrongPageBc17 = await page.frameLocator("iframe").first().getByRole('heading', { name: 'Something went wrong' }).count();
  if (wrongPageBc17 > 0) {
    await page.goto("/BC/?page=9176&tenant=default");
    await page.waitForLoadState("networkidle");
    try {
      await page.waitForSelector(".spinner", { state: "hidden", timeout: 20000 });
    } catch (error) {
      console.warn("Spinner did not disappear within 20 seconds, reloading the page...");
      await page.goto("/BC/?page=9176&tenant=default");
      await page.waitForSelector(".spinner", { state: "hidden", timeout: 20000 });
    }
  }

  await page.waitForTimeout(3000);

  // BC17.0 - select Region
  const changeRegionBc17 = page.frameLocator('iframe').first().getByRole('button', { name: 'Region' }).locator('..').getByLabel('Open assist edit');
  if (await changeRegionBc17.count() > 0) {
    await changeRegionBc17.click();
  } else {
    // BC17.4+ - select Region
    const changeRegionBc24 = page.frameLocator("iframe").getByLabel('Review or update the value for Region')
    if (await changeRegionBc24.count() == 1) {
      await changeRegionBc24.click();
    } else if (await changeRegionBc24.count() > 1) {
      await changeRegionBc24.last().click();
    }
  }

  await page.waitForTimeout(1000);

  // BC17~BC24 - select Search button
  const searchBc24 = page.frameLocator('iframe').getByRole('button', { name: 'Search' });
  if (await searchBc24.count() > 0) {
    await searchBc24.click();
  } else {
    // BC25+ - select Search button
    const searchBc25 = page.frameLocator('iframe').getByLabel('Search');
    if (await searchBc25.count() > 0) {
      await searchBc25.click();
    }
  }

  await page.waitForTimeout(1000);
  await page.frameLocator('iframe').getByPlaceholder('Search').fill(regionInput);
  await page.waitForTimeout(1000);

  // BC17.0 - select country
  const selectCountryBc17 = page.frameLocator('iframe').first().getByRole('button', { name: "Name, " + regionInput + "", exact: true, includeHidden: true });
  if (await selectCountryBc17.count() > 0) {
    await selectCountryBc17.click();
  } else {
    // BC17.4-BC17.11 - select country
    const selectCountryBc1704 = page.frameLocator('iframe').first().getByRole('button', { name: "Name,", exact: true, includeHidden: true });
    if (await selectCountryBc1704.count() > 0) {
      await selectCountryBc1704.click();
    } else {
      // BC18+ - select country
      await page.frameLocator('iframe').getByLabel(regionInput).click();
    }
  }

  await page.waitForTimeout(1000);
  await page.frameLocator('iframe').getByRole('button', { name: 'OK' }).click();
  await page.waitForLoadState("networkidle");
  await page.waitForTimeout(3000);
};