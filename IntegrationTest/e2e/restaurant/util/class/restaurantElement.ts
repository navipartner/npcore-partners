import { expect, Page } from "@playwright/test";

import { RestaurantLayout } from "./restaurantLayout";

export enum ElementType {
  Room = "Room",
  Table = "Table",
  Wall = "Wall",
  Bar = "Bar",
}

export interface ConfigureObject {
  count?: string;
  minimum?: string;
  maximum?: string;
  round?: string;
  width?: string;
  height?: string;
  length?: string;
  rotation?: string;
}

const degreesToRadians = (degrees: number) => degrees * (Math.PI / 180);

const formatNumber = (number: number, precision: number) =>
  parseFloat(number.toFixed(precision));

const rotateToMatrix = (degrees: number) => {
  const radian = degreesToRadians(degrees);
  const aa = formatNumber(Math.cos(radian), 6);
  const ab = formatNumber(Math.sin(radian), 6);
  const ac = formatNumber(-Math.sin(radian), 6);
  const ad = formatNumber(Math.cos(radian), 6);

  return `matrix(${aa}, ${ab}, ${ac}, ${ad}, 0, 0)`;
};

export class RestaurantElement extends RestaurantLayout {
  protected elementName: ElementType;

  constructor(page: Page, elementName: ElementType) {
    super(page);
    this.elementName = elementName;
  }

  async add(locationName: string): Promise<void> {
    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("div.seating-setup-locations__item span.seating-setup-locations__item__text")
      .filter({ hasText: new RegExp(`^${locationName}$`) })
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div.seating-setup-locations__item.seating-setup-locations__item--active span.seating-setup-locations__item__text")
    ).toHaveText(`${locationName}`);

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("span.restaurant-title__small-text.restaurant-title__small-text--edit-mode")
    ).toHaveText(new RegExp(`> ${locationName}$`));

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-square-plus.seating-setup-navigation-menu__button__icon")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("div.seating-setup-new-elements__item span.seating-setup-new-elements__item__text")
      .filter({ hasText: `Add ${this.elementName}` })
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-square-plus.seating-setup-navigation-menu__button__icon")
      .click();

    switch (this.elementName) {
      case ElementType.Room:
        await expect(
          this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(`div.seating-component--${this.elementName.toLowerCase()} div.${this.elementName.toLowerCase()}`)
            .filter({ hasText: this.elementName })
        ).toBeVisible();
        break;
      case ElementType.Table:
        await expect(
          this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(`div.seating-component--${this.elementName.toLowerCase()} span.circle-text__text`)
            .filter({ hasText: this.elementName })
        ).toBeVisible();
        break;
      case ElementType.Wall:
        await expect(
          this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(`div.seating-component--${this.elementName.toLowerCase()}`)
        ).toBeVisible();
        break;
      case ElementType.Bar:
        await expect(
          this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(`div.seating-component--${this.elementName.toLowerCase()} span.${this.elementName.toLowerCase()}__text`)
            .filter({ hasText: this.elementName })
        ).toBeVisible();
        break;
    }

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

    await this.page
      .frameLocator("iframe")
      .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
      .filter({ hasText: new RegExp(`^${locationName}$`) })
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator(`div.floor-render-element-${this.elementName.toLowerCase()}`)
    ).toBeVisible();
  }

  rename(editedName: string, oldName: string): Promise<void>;
  rename(locationName: string, number: string, caption: string): Promise<void>;
  async rename(...args: string[]): Promise<void> {
    if (args.length === 3) {
      const [locationName, number, caption] = args;
      await this.openEdit();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
        .click();
    
      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div.seating-setup-locations__item span.seating-setup-locations__item__text")
        .filter({ hasText: new RegExp(`^${locationName}$`) })
        .click();

      await expect(
        this.page
          .frameLocator("iframe")
          .locator("#popup-host")
          .locator("div.seating-setup-locations__item.seating-setup-locations__item--active span.seating-setup-locations__item__text")
      ).toHaveText(`${locationName}`);

      await expect(
        this.page
          .frameLocator("iframe")
          .locator("#popup-host")
          .locator("span.restaurant-title__small-text.restaurant-title__small-text--edit-mode")
      ).toHaveText(new RegExp(`> ${locationName}$`));

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
        .click();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(`div.${this.elementName.toLowerCase()}`)
        .first()
        .click();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(
          "div.seating-setup-context-menu__item > span.seating-setup-context-menu__text"
        )
        .filter({ hasText: /^Rename$/ })
        .click();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div#user_friendly_id div.input__erase")
        .nth(1)
        .click();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div#user_friendly_id")
        .getByTestId("search-input")
        .click();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div#user_friendly_id")
        .getByTestId("search-input")
        .fill(number);

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div#caption div.input__erase")
        .nth(1)
        .click();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div#caption")
        .getByTestId("search-input")
        .fill(caption);

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host div")
        .filter({ hasText: /^OK$/ })
        .nth(3)
        .click();

      const byCaptionPromise = this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
        .filter({ hasText: caption });

      const byNumberPromise = this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
        .filter({ hasText: number });

      const byClassPromise = this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`);

      switch (this.elementName) {
        case ElementType.Table:
          await expect(byNumberPromise).toBeVisible();
          break;
        case ElementType.Wall:
          await expect(byClassPromise).toBeVisible();
          break;
        default:
          await expect(byCaptionPromise).toBeVisible();
      }

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
  
      await this.page
        .frameLocator("iframe")
        .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
        .filter({ hasText: new RegExp(`^${locationName}$`) })
        .click();
  
      await this.page
        .frameLocator("iframe")
        .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
        .click();

      await expect(
        this.page
          .frameLocator("iframe")
          .locator(`div.${this.elementName.toLowerCase()}`)
      ).toBeVisible();

      // checking
      await this.openEdit();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
        .click();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div.seating-setup-locations__item span.seating-setup-locations__item__text")
        .filter({ hasText: new RegExp(`^${locationName}$`) })
        .click();

      await expect(
        this.page
          .frameLocator("iframe")
          .locator("#popup-host")
          .locator("div.seating-setup-locations__item.seating-setup-locations__item--active span.seating-setup-locations__item__text")
      ).toHaveText(`${locationName}`);

      await expect(
        this.page
          .frameLocator("iframe")
          .locator("#popup-host")
          .locator("span.restaurant-title__small-text.restaurant-title__small-text--edit-mode")
      ).toHaveText(new RegExp(`> ${locationName}$`));

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
        .click();

      const byCaptionPromise1 = this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
        .filter({ hasText: caption })
        .first();

      const byNumberPromise1 = this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
        .filter({ hasText: number })
        .first();

      const byClassPromise1 = this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
        .first();

      switch (this.elementName) {
        case ElementType.Table:
          await byNumberPromise1.click();
          break;
        case ElementType.Wall:
          await byClassPromise1.click();
          break;
        default:
          await byCaptionPromise1.click();
      }

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(
          "div.seating-setup-context-menu__item > span.seating-setup-context-menu__text"
        )
        .filter({ hasText: /^Rename$/ })
        .click();

      await expect(
        this.page
          .frameLocator("iframe")
          .locator("#popup-host")
          .locator("div#user_friendly_id")
          .getByTestId("search-input")
      ).toHaveValue(number);

      await expect(
        this.page
          .frameLocator("iframe")
          .locator("#popup-host")
          .locator("div#caption")
          .getByTestId("search-input")
      ).toHaveValue(caption);

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host div")
        .filter({ hasText: /^OK$/ })
        .nth(3)
        .click();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("#button-dialog-ok > div > span > span")
        .first()
        .click();
    }
  }

  async duplicate(
    locationName: string,
    caption: string,
    number?: string
  ): Promise<void> {
    await this.openEdit();

    await this.page
    .frameLocator("iframe")
    .locator("#popup-host")
    .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
    .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("div.seating-setup-locations__item span.seating-setup-locations__item__text")
      .filter({ hasText: new RegExp(`^${locationName}$`) })
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div.seating-setup-locations__item.seating-setup-locations__item--active span.seating-setup-locations__item__text")
    ).toHaveText(`${locationName}`);

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("span.restaurant-title__small-text.restaurant-title__small-text--edit-mode")
    ).toHaveText(new RegExp(`> ${locationName}$`));

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.${this.elementName.toLowerCase()}`)
      .first()
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(
        "div.seating-setup-context-menu__item > span.seating-setup-context-menu__text"
      )
      .filter({ hasText: /^Duplicate$/ })
      .click();

    const byElementNamePromise = this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`);

    const byNumberPromise = this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`);

    const byClassPromise = this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`);

    switch (this.elementName) {
      case ElementType.Room:
        await expect(byElementNamePromise).toHaveCount(2);
        await expect(
          byElementNamePromise.filter({ hasText: this.elementName }).nth(0)
        ).toHaveText(caption);
        await expect(
          byElementNamePromise.filter({ hasText: this.elementName }).nth(1)
        ).toHaveText(new RegExp(`^${this.elementName}\\s*\\d+$`));
        break;
      case ElementType.Table:
        await expect(byNumberPromise).toHaveCount(2);
        if (number) {
          await expect(
            byNumberPromise
              .locator(`span.circle-text__text`)
              .filter({ hasText: number })
              .nth(0)
          ).toHaveText(number);
          await expect(
            byNumberPromise
              .locator(`span.circle-text__text`)
              .filter({ hasText: number })
              .nth(1)
          ).toHaveText(number);
        }
        break;
      case ElementType.Wall:
        await expect(byClassPromise).toHaveCount(2);
        await expect(byClassPromise.nth(0)).toHaveText("");
        await expect(byClassPromise.nth(1)).toHaveText("");
        break;
      case ElementType.Bar:
        await expect(byElementNamePromise).toHaveCount(2);
        await expect(
          byElementNamePromise
            .locator(`span.${this.elementName.toLowerCase()}__text`)
            .filter({ hasText: this.elementName })
            .nth(0)
        ).toHaveText(caption);
        await expect(
          byElementNamePromise
            .locator(`span.${this.elementName.toLowerCase()}__text`)
            .filter({ hasText: this.elementName })
            .nth(1)
        ).toHaveText(new RegExp(`^${this.elementName}\\s*\\d+$`));
    }

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

    await this.page
      .frameLocator("iframe")
      .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
      .filter({ hasText: new RegExp(`^${locationName}$`) })
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();

    const elementsLayout = this.page
      .frameLocator("iframe")
      .locator(`div.${this.elementName.toLowerCase()}`);

    await expect(elementsLayout).toHaveCount(2);
  }

  async remove(locationName: string): Promise<void> {
    const elementsLayout = this.page
      .frameLocator("iframe")
      .locator(`div.${this.elementName.toLowerCase()}`);

    expect(await elementsLayout.count()).toBeGreaterThan(0);

    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("div.seating-setup-locations__item span.seating-setup-locations__item__text")
      .filter({ hasText: new RegExp(`^${locationName}$`) })
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div.seating-setup-locations__item.seating-setup-locations__item--active span.seating-setup-locations__item__text")
    ).toHaveText(`${locationName}`);

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("span.restaurant-title__small-text.restaurant-title__small-text--edit-mode")
    ).toHaveText(new RegExp(`> ${locationName}$`));

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    const elementsEdit = await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
      .all();

    for (const element of elementsEdit.reverse()) {
      await element.click();

      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(
          "div.seating-setup-context-menu__item > span.seating-setup-context-menu__text"
        )
        .filter({ hasText: /^Remove$/ })
        .click();

      await expect(element).toBeHidden();
    }

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

    await this.page
      .frameLocator("iframe")
      .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
      .filter({ hasText: new RegExp(`^${locationName}$`) })
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();

    const elements = this.page
      .frameLocator("iframe")
      .locator(`div.${this.elementName.toLowerCase()}`);

    await expect(elements).toHaveCount(0);
  }
}

export class RestaurantConfigElement extends RestaurantElement {
  async config(
    locationName: string,
    caption: string,
    number: string,
    configure: ConfigureObject
  ): Promise<void> {
    const { count, minimum, maximum, round, width, height, length, rotation } =
      configure;
    const roundBoolean = round?.toLowerCase() === "true";
    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("div.seating-setup-locations__item span.seating-setup-locations__item__text")
      .filter({ hasText: new RegExp(`^${locationName}$`) })
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div.seating-setup-locations__item.seating-setup-locations__item--active span.seating-setup-locations__item__text")
    ).toHaveText(`${locationName}`);

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("span.restaurant-title__small-text.restaurant-title__small-text--edit-mode")
    ).toHaveText(new RegExp(`> ${locationName}$`));

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.${this.elementName.toLowerCase()}`)
      .first()
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(
        "div.seating-setup-context-menu__item > span.seating-setup-context-menu__text"
      )
      .filter({ hasText: /^Configure$/ })
      .click();

    switch (this.elementName) {
      case ElementType.Table:
        if (count) {
          await this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(
              "div.plus-minus-editor__caption:has-text('Count') + div.plus-minus-editor__buttons > div.add"
            )
            .click({ clickCount: parseInt(count) });
        }
        if (minimum) {
          await this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(
              "div.plus-minus-editor__caption:has-text('Minimum') + div.plus-minus-editor__buttons > div.add"
            )
            .click({ clickCount: parseInt(minimum) });
        }
        if (maximum) {
          await this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(
              "div.plus-minus-editor__caption:has-text('Maximum') + div.plus-minus-editor__buttons > div.add"
            )
            .click({ clickCount: parseInt(maximum) });
        }
        if (roundBoolean) {
          await this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator("input#switch-round + span.switch__pointer")
            .click();
        }
        if (width && parseInt(width) >= 1) {
          await this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(
              "div.plus-minus-editor__caption:has-text('Width') + div.plus-minus-editor__buttons > div.add"
            )
            .click({ clickCount: parseInt(width) - 1 });
        }
        if (height && parseInt(height) >= 1) {
          await this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(
              "div.plus-minus-editor__caption:has-text('Height') + div.plus-minus-editor__buttons > div.add"
            )
            .click({ clickCount: parseInt(height) - 1 });
        }
        break;
      case ElementType.Wall:
        if (width && parseInt(width) >= 1) {
          await this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(
              "div.plus-minus-editor__caption:has-text('Width') + div.plus-minus-editor__buttons > div.add"
            )
            .click({ clickCount: parseInt(width) - 1 });
        }
        if (length && parseInt(length) >= 1) {
          await this.page
            .frameLocator("iframe")
            .locator("#popup-host")
            .locator(
              "div.plus-minus-editor__caption:has-text('Length') + div.plus-minus-editor__buttons > div.add"
            )
            .click({ clickCount: parseInt(length) - 1 });
        }
        break;
    }

    if (rotation) {
      await this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator(
          "div.plus-minus-editor__caption:has-text('Rotation (degrees)') + div.plus-minus-editor__buttons > div.value"
        )
        .click();
      for (const digit of rotation.split("")) {
        await this.page
          .frameLocator("iframe")
          .locator("#popup-host")
          .locator("div.dialog__container--numpad")
          .getByTitle(digit, { exact: true })
          .click();
      }
    }

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#button-dialog-ok > div > span > span")
      .nth(2)
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#button-dialog-ok > div > span > span")
      .nth(1)
      .click();

    const byCaptionPromise = this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
      .filter({ hasText: caption });

    const byNumberPromise = this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
      .filter({ hasText: number });

    const chairs = byNumberPromise.locator("div.table__chairs > span");

    const byClassPromise = this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`);

    switch (this.elementName) {
      case ElementType.Table:
        await expect(byNumberPromise).toBeVisible();
        await expect(byNumberPromise).toHaveClass(
          new RegExp(`.*chairs-${count}.*`)
        );
        if (count && parseInt(count) >= 0) {
          await expect(chairs).toHaveCount(parseInt(count));
        }
        if (roundBoolean) {
          await expect(byNumberPromise).toHaveClass(
            new RegExp(`.*${this.elementName.toLowerCase()}--round.*`)
          );
        }
        if (width) {
          await expect(byNumberPromise).toHaveCSS(
            "width",
            `${60 * parseFloat(width)}px`
          );
        }
        if (height) {
          await expect(byNumberPromise).toHaveCSS(
            "height",
            `${60 * parseFloat(height)}px`
          );
        }
        if (rotation && parseFloat(rotation) > 0) {
          await expect(byNumberPromise).toHaveCSS(
            "transform",
            rotateToMatrix(parseFloat(rotation))
          );
        }
        break;
      case ElementType.Wall:
        await expect(byClassPromise).toBeVisible();
        if (width) {
          await expect(byClassPromise).toHaveCSS(
            "width",
            `${60 * parseFloat(width)}px`
          );
        }
        if (length) {
          await expect(byClassPromise).toHaveCSS(
            "height",
            `${60 * parseFloat(length)}px`
          );
        }
        if (rotation && parseFloat(rotation) > 0) {
          await expect(byClassPromise).toHaveCSS(
            "transform",
            rotateToMatrix(parseFloat(rotation))
          );
        }
        break;
      default:
        await expect(byCaptionPromise).toBeVisible();
        if (rotation && parseFloat(rotation) > 0) {
          await expect(byCaptionPromise).toHaveCSS(
            "transform",
            rotateToMatrix(parseFloat(rotation))
          );
        }
    }

    await this.page
      .frameLocator("iframe")
      .locator("#button-dialog-ok > div > span > span")
      .first()
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();
  
    await this.page
      .frameLocator("iframe")
      .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
      .filter({ hasText: new RegExp(`^${locationName}$`) })
      .click();
  
    await this.page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator(`div.${this.elementName.toLowerCase()}`)
    ).toBeVisible();

    const byCaptionPromise1 = this.page
      .frameLocator("iframe")
      .locator(`div.restaurant-container div.${this.elementName.toLowerCase()}`)
      .filter({ hasText: caption });

    const byNumberPromise1 = this.page
      .frameLocator("iframe")
      .locator(`div.restaurant-container div.${this.elementName.toLowerCase()}`)
      .filter({ hasText: number });

    const chairs1 = byNumberPromise1.locator("div.table__chairs > span");

    const byClassPromise1 = this.page
      .frameLocator("iframe")
      .locator(`div.restaurant-container div.${this.elementName.toLowerCase()}`);

    switch (this.elementName) {
      case ElementType.Table:
        await expect(byNumberPromise1).toBeVisible();
        await expect(byNumberPromise1).toHaveClass(
          new RegExp(`.*chairs-${count}.*`)
        );
        if (count && parseInt(count) >= 0) {
          await expect(chairs1).toHaveCount(parseInt(count));
        }
        if (roundBoolean) {
          await expect(byNumberPromise1).toHaveClass(
            new RegExp(`.*${this.elementName.toLowerCase()}--round.*`)
          );
        }
        if (width) {
          await expect(byNumberPromise1).toHaveCSS(
            "width",
            `${60 * parseFloat(width)}px`
          );
        }
        if (height) {
          await expect(byNumberPromise1).toHaveCSS(
            "height",
            `${60 * parseFloat(height)}px`
          );
        }
        if (rotation && parseFloat(rotation) > 0) {
          await expect(byNumberPromise1).toHaveCSS(
            "transform",
            rotateToMatrix(parseFloat(rotation))
          );
        }
        break;
      case ElementType.Wall:
        await expect(byClassPromise1).toBeVisible();
        if (width) {
          await expect(byClassPromise1).toHaveCSS(
            "width",
            `${60 * parseFloat(width)}px`
          );
        }
        if (length) {
          await expect(byClassPromise1).toHaveCSS(
            "height",
            `${60 * parseFloat(length)}px`
          );
        }
        if (rotation && parseFloat(rotation) > 0) {
          await expect(byClassPromise1).toHaveCSS(
            "transform",
            rotateToMatrix(parseFloat(rotation))
          );
        }
        break;
      default:
        await expect(byCaptionPromise1).toBeVisible();
        if (rotation && parseFloat(rotation) > 0) {
          await expect(byCaptionPromise1).toHaveCSS(
            "transform",
            rotateToMatrix(parseFloat(rotation))
          );
        }
    }

    // checking
    await this.openEdit();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("div.seating-setup-locations__item span.seating-setup-locations__item__text")
      .filter({ hasText: new RegExp(`^${locationName}$`) })
      .click();

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("div.seating-setup-locations__item.seating-setup-locations__item--active span.seating-setup-locations__item__text")
    ).toHaveText(`${locationName}`);

    await expect(
      this.page
        .frameLocator("iframe")
        .locator("#popup-host")
        .locator("span.restaurant-title__small-text.restaurant-title__small-text--edit-mode")
    ).toHaveText(new RegExp(`> ${locationName}$`));

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("button.seating-setup-navigation-menu__button svg.fa-location-dot.seating-setup-navigation-menu__button__icon")
      .click();

    const byCaptionPromise2 = this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
      .filter({ hasText: caption })
      .first();

    const byNumberPromise2 = this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
      .filter({ hasText: number })
      .first();

    const byClassPromise2 = this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(`div.seating-floor div.${this.elementName.toLowerCase()}`)
      .first();

    switch (this.elementName) {
      case ElementType.Table:
        await byNumberPromise2.click();
        break;
      case ElementType.Wall:
        await byClassPromise2.click();
        break;
      default:
        await byCaptionPromise2.click();
    }

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator(
        "div.seating-setup-context-menu__item > span.seating-setup-context-menu__text"
      )
      .filter({ hasText: /^Configure$/ })
      .click();

    switch (this.elementName) {
      case ElementType.Table:
        if (count) {
          await expect(
            this.page
              .frameLocator("iframe")
              .locator("#popup-host")
              .locator(
                "div.plus-minus-editor__caption:has-text('Count') + div.plus-minus-editor__buttons > div.value > span"
              )
          ).toHaveText(count);
        }
        if (minimum) {
          await expect(
            this.page
              .frameLocator("iframe")
              .locator("#popup-host")
              .locator(
                "div.plus-minus-editor__caption:has-text('Minimum') + div.plus-minus-editor__buttons > div.value > span"
              )
          ).toHaveText(minimum);
        }
        if (maximum) {
          await expect(
            this.page
              .frameLocator("iframe")
              .locator("#popup-host")
              .locator(
                "div.plus-minus-editor__caption:has-text('Maximum') + div.plus-minus-editor__buttons > div.value > span"
              )
          ).toHaveText(maximum);
        }
        if (round) {
          if (roundBoolean) {
            expect(
              this.page
                .frameLocator("iframe")
                .locator("#popup-host")
                .locator("input#switch-round + span.switch__pointer")
            ).toBeChecked();
          } else {
            expect(
              this.page
                .frameLocator("iframe")
                .locator("#popup-host")
                .locator("input#switch-round + span.switch__pointer")
            ).not.toBeChecked();
          }
        }
        if (width) {
          await expect(
            this.page
              .frameLocator("iframe")
              .locator("#popup-host")
              .locator(
                "div.plus-minus-editor__caption:has-text('Width') + div.plus-minus-editor__buttons > div.value > span"
              )
          ).toHaveText(width);
        }
        if (height) {
          await expect(
            this.page
              .frameLocator("iframe")
              .locator("#popup-host")
              .locator(
                "div.plus-minus-editor__caption:has-text('Height') + div.plus-minus-editor__buttons > div.value > span"
              )
          ).toHaveText(height);
        }
        break;
      case ElementType.Wall:
        if (width) {
          await expect(
            this.page
              .frameLocator("iframe")
              .locator("#popup-host")
              .locator(
                "div.plus-minus-editor__caption:has-text('Width') + div.plus-minus-editor__buttons > div.value > span"
              )
          ).toHaveText(width);
        }
        if (length) {
          await expect(
            this.page
              .frameLocator("iframe")
              .locator("#popup-host")
              .locator(
                "div.plus-minus-editor__caption:has-text('Length') + div.plus-minus-editor__buttons > div.value > span"
              )
          ).toHaveText(length);
        }
        break;
    }

    if (rotation) {
      await expect(
        this.page
          .frameLocator("iframe")
          .locator("#popup-host")
          .locator(
            "div.plus-minus-editor__caption:has-text('Rotation (degrees)') + div.plus-minus-editor__buttons > div.value > span"
          )
      ).toHaveText(rotation);
    }

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#button-dialog-ok > div > span > span")
      .nth(1)
      .click();

    await this.page
      .frameLocator("iframe")
      .locator("#popup-host")
      .locator("#button-dialog-ok > div > span > span")
      .first()
      .click();
  }
}
