import { expect } from "@playwright/test";

import { RestaurantLayout } from "./restaurantLayout";

class RestaurantLocation extends RestaurantLayout {
  async add(id: string, name: string) {
    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-plus.seating-setup-navigation-menu__button__icon")
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(".dialog__container.dialog__container--configuration")
    ).toBeVisible();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#id")
      .getByRole("textbox")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#id")
      .getByRole("textbox")
      .fill(id);
      
    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#caption")
      .getByRole("textbox")
      .click();
      
    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#caption")
      .getByRole("textbox")
      .fill(name);
      
    await this.page
      .frameLocator("iframe")
      .locator("#popup-host div")
      .filter({ hasText: /^OK$/ })
      .nth(3)
      .click();
      
    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("span.restaurant-title__small-text.restaurant-title__small-text--edit-mode")
    ).toHaveText(new RegExp(`> ${name}$`));

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();
      
    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div.seating-setup-locations__item.seating-setup-locations__item--active")
    ).toHaveCount(1, { timeout: 60000 });
      
    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div.seating-setup-locations__item.seating-setup-locations__item--active span.seating-setup-locations__item__text")
    ).toHaveText(`${name}`);
      
    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#button-dialog-ok > div > span > span")
      .first()
      .click();
      
    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();
      
    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
        .filter({ hasText: new RegExp(`^${name}$`) })
    ).toBeVisible();

    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();
  }

  async rename(editedName: string, oldName: string) {
    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(
        `div.seating-setup-locations__item span:has-text('${oldName}') + div.seating-setup-locations__item__buttons > div.seating-setup-locations__item__buttons-icon-edit`
      )
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(".dialog__container.dialog__container--configuration")
    ).toBeVisible();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#caption div")
      .nth(3)
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#caption")
      .getByRole("textbox")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#caption")
      .getByRole("textbox")
      .fill(editedName);

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host div")
      .filter({ hasText: /^OK$/ })
      .nth(3)
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(
          `div.seating-setup-locations__item span:has-text('${editedName}')`
        )
    ).toBeVisible();
    
    await this.page
    .frameLocator("iframe")
    .locator("#button-dialog-ok > div > span > span")
    .first()
    .click();

    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();
      
    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
        .filter({ hasText: new RegExp(`^${editedName}$`) })
    ).toBeVisible();

    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();
  }

  async remove(id: string, name: string) {
    const initialCountTableView = await this.page
      .frameLocator("iframe")
      .locator(
        "div.restaurant-locations__item span.restaurant-locations__item__text"
      )
      .filter({ hasText: new RegExp(`^${name}$`) })
      .count();

    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();
      
      await expect(
        this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(
          `div.seating-setup-locations__item span:has-text('${name}')`
        )
        .nth(0)
      ).toBeVisible();
      
    const initialCountEditMode = await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(
        `div.seating-setup-locations__item span:has-text('${name}')`
      )
      .count();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(
        `div.seating-setup-locations__item span:has-text('${name}') + div.seating-setup-locations__item__buttons > div.seating-setup-locations__item__buttons-icon-delete`
      )
      .nth(0)
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(
          `div.seating-setup-locations__item span:has-text('${name}')`
        )
    ).toHaveCount(initialCountEditMode - 1);

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#button-dialog-ok > div > span > span")
      .first()
      .click();

      await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();
      
    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
        .filter({ hasText: new RegExp(`^${name}$`) })
    ).toHaveCount(initialCountTableView - 1);

    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();
  }
}

export default RestaurantLocation;
