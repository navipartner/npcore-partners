import { expect, Page } from "@playwright/test";

export abstract class RestaurantLayout {
  constructor(public page: Page) {}

  async openEdit() {
    // await this.page.waitForLoadState("networkidle");

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.restaurant__selection__item.is-active")
    ).toHaveCount(1, { timeout: 60000 });

    await this.page
      .frameLocator("iframe")
      .locator("div.button--simple--edit.float-left span")
      .filter({ hasText: /^Edit$/ })
      .nth(1)
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("div.seating-setup-menu__burger")
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.seating-setup-menu.is-active")
    ).toBeVisible();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.seating-setup-menu__configuration-title")
        .filter({ hasText: new RegExp(`^Configure.*`) })
    ).toBeVisible();
  }

  abstract add(id: string, name: string): Promise<void>;
  abstract add(locationName: string, id?: string, name?: string): Promise<void>;
  abstract rename(editedName: string, oldName: string): Promise<void>;
  abstract remove(id: string, name: string): Promise<void>;
  abstract remove(
    locationName: string,
    id?: string,
    name?: string
  ): Promise<void>;
}
