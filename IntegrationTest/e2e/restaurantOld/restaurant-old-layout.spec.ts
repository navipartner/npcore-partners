import { test } from "../fixtures/restaurantOld";
import { restaurantLogin } from "../fixtures/restaurantLogin";
import * as data from "./util/data/restaurant-test-data.json";
import { restaurantSelectLayoutType } from "../fixtures/restaurantSelectLayoutType";

test.beforeEach(async ({ page }) => {
  await restaurantSelectLayoutType(page, false);
  await restaurantLogin(page, false);
});

test.describe("Restaurant old layout", () => {
  test("user should be able to create new location, room, table, wall and bar, and then edit, and remove", async ({
    location,
    room,
    table,
    wall,
    bar,
  }) => {
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
    await location.remove(data.location.new.id, data.location.edited.name);
  });
});
