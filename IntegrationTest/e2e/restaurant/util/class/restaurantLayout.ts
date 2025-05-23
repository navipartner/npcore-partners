import { expect, Page } from "@playwright/test";

export abstract class RestaurantLayout {
  constructor(public page: Page) {}

  async openEdit() {

    await this.page
    .frameLocator("iframe")
    .locator("button.restaurant-navigation-menu__button svg.fa-house.restaurant-navigation-menu__button__icon")
    .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.restaurant-selection__item--active")
    ).toHaveCount(1, { timeout: 60000 });

    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-gear.restaurant-navigation-menu__button__icon")
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("span.restaurant-title__text.restaurant-title__text--edit-mode")
        .filter({ hasText: /^Edit Mode$/ })
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
