import { expect } from "@playwright/test";
import { test } from "../fixtures/restaurant";
import { restaurantLogin } from "../fixtures/restaurantLogin";
import { restaurantSelectLayoutType } from "../fixtures/restaurantSelectLayoutType";
import * as data from "./util/data/restaurant-test-data.json";

test.skip()

let restaurantViewLayoutDropdownExists: boolean;

test.beforeEach(async ({ page }) => {
  restaurantViewLayoutDropdownExists = await restaurantSelectLayoutType(page, true);
  if(restaurantViewLayoutDropdownExists){
    await restaurantLogin(page, true);
  }
});

test.describe("Restaurant layout", () => {
  test("user should be able to create new location, room, table, wall and bar, and then edit, and remove", async ({
    page,
    location,
    room,
    table,
    wall,
    bar,
  }) => {
    test.skip(!restaurantViewLayoutDropdownExists,"'Restaurant View Layout' dropdown not found. Feature flag 'modernRestaurantLayout' is not enabled.");

    await expect(
      page
        .frameLocator("iframe")
        .locator("span.restaurant-title__small-text")
    ).toHaveCount(1, { timeout: 60000 });

    await page.waitForTimeout(2000);

    await page
      .frameLocator("iframe")
      .locator("button.restaurant-navigation-menu__button svg.fa-location-dot.restaurant-navigation-menu__button__icon")
      .click();
    
    const newLocationCount = await page
      .frameLocator("iframe")
      .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
      .filter({ hasText: new RegExp(`^${data.location.new.name}$`) }).count();

    const editedLocationCount = await page
      .frameLocator("iframe")
      .locator("div.restaurant-locations__item span.restaurant-locations__item__text")
      .filter({ hasText: new RegExp(`^${data.location.edited.name}$`) }).count();

    for (let i = 0; i < newLocationCount; i++) {
      await location.remove(data.location.new.id, data.location.new.name);
    }
    for (let i = 0; i < editedLocationCount; i++) {
      await location.remove(data.location.edited.id, data.location.edited.name);
    }

    // user should be able to create new location and edit location name
    await location.add(data.location.new.id, data.location.new.name);
    await location.rename(data.location.edited.name, data.location.new.name);
    //  user should be able to add new room to the location, rename the room, duplicate the room and delete the room
    await room.add(data.location.edited.name);
    await room.rename(
      data.location.edited.name,
      data.element.room.roomNumber,
      data.element.room.caption
    );
    await room.duplicate(data.location.edited.name, data.element.room.caption);
    await room.remove(data.location.edited.name);
    // user should be able to add new table to the location, rename the table, configure the table, duplicate the table and delete the table
    await table.add(data.location.edited.name);
    await table.rename(
      data.location.edited.name,
      data.element.table.tableNumber,
      data.element.table.caption
    );
    await table.config(
      data.location.edited.name,
      data.element.table.caption,
      data.element.table.tableNumber,
      data.element.table.configure
    );
    await table.duplicate(
      data.location.edited.name,
      data.element.table.caption,
      data.element.table.tableNumber
    );
    await table.remove(data.location.edited.name);
    // user should be able to add new wall to the location, rename the wall, configure the wall, duplicate the wall and delete the wall
    await wall.add(data.location.edited.name);
    await wall.rename(
      data.location.edited.name,
      data.element.wall.wallNumber,
      data.element.wall.caption
    );
    await wall.config(
      data.location.edited.name,
      data.element.wall.caption,
      data.element.wall.wallNumber,
      data.element.wall.configure
    );
    await wall.duplicate(data.location.edited.name, data.element.wall.caption);
    await wall.remove(data.location.edited.name);
    // user should be able to add new bar to the location, rename the bar, configure the bar, duplicate the bar and delete the bar
    await bar.add(data.location.edited.name);
    await bar.rename(
      data.location.edited.name,
      data.element.bar.barNumber,
      data.element.bar.caption
    );
    await bar.config(
      data.location.edited.name,
      data.element.bar.caption,
      data.element.bar.barNumber,
      data.element.bar.configure
    );
    await bar.duplicate(data.location.edited.name, data.element.bar.caption);
    await bar.remove(data.location.edited.name);
    // user should be able to delete location
    await location.remove(data.location.edited.id, data.location.edited.name);
  });
});
