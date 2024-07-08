import { expect } from "@playwright/test";

import { RestaurantLayout } from "./restaurantLayout";

class RestaurantLocation extends RestaurantLayout {
  async add(id: string, name: string) {
    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator("div.seating-setup-menu-button span")
      .filter({ hasText: /^New Location$/ })
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator(".dialog__container.dialog__container--configuration")
    ).toBeVisible();

    await this.page
      .frameLocator("iframe")
      .locator("#id")
      .getByRole("textbox")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#id")
      .getByRole("textbox")
      .fill(id);

    await this.page
      .frameLocator("iframe")
      .locator("#caption")
      .getByRole("textbox")
      .click();

    await this.page
      .frameLocator("iframe")
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
        .locator(
          `div.seating-setup-locations__location > span:has-text('${name}')`
        )
    ).toBeVisible();

    await this.page
      .frameLocator("iframe")
      .locator("#button-dialog-ok > div > span > span")
      .first()
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.restaurant__location__selection__button span")
        .filter({ hasText: new RegExp(`^${name}$`) })
        .nth(1)
    ).toBeVisible();
  }

  async rename(editedName: string, oldName: string) {
    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator(
        `div.seating-setup-locations__location span:has-text('${oldName}') + div.seating-setup-locations__buttons > div:nth-child(2)`
      )
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator(".dialog__container.dialog__container--configuration")
    ).toBeVisible();

    await this.page
      .frameLocator("iframe")
      .locator("#caption div")
      .nth(3)
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#caption")
      .getByRole("textbox")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#caption")
      .getByRole("textbox")
      .fill(editedName);

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host div")
      .filter({ hasText: /^OK$/ })
      .nth(3)
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator(
          `div.seating-setup-locations__location span:has-text('${editedName}')`
        )
    ).toBeVisible();

    await this.page
      .frameLocator("iframe")
      .locator("#button-dialog-ok > div > span > span")
      .first()
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.restaurant__location__selection__button span")
        .filter({ hasText: new RegExp(`^${editedName}$`) })
        .nth(1)
    ).toBeVisible();
  }

  async remove(id: string, name: string) {
    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator(
        `div.seating-setup-locations__location span:has-text('${name}') + div.seating-setup-locations__buttons > div:nth-child(1)`
      )
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator(
          `div.seating-setup-locations__location span:has-text('${name}')`
        )
    ).not.toBeVisible();

    await this.page
      .frameLocator("iframe")
      .locator("#button-dialog-ok > div > span > span")
      .first()
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("div.restaurant__location__selection__button span")
        .filter({ hasText: new RegExp(`^${name}$`) })
        .nth(1)
    ).not.toBeVisible();
  }
}

export default RestaurantLocation;
