import { test as restaurantTest } from "@playwright/test";

import {
  ElementType,
  RestaurantConfigElement,
  RestaurantElement,
} from "../restaurantOld/util/class/restaurantElement";
import RestaurantLocation from "../restaurantOld/util/class/restaurantLocation";

type restaurant = {
  location: RestaurantLocation;
  room: RestaurantElement;
  table: RestaurantConfigElement;
  wall: RestaurantConfigElement;
  bar: RestaurantConfigElement;
};

const testRestaurant = restaurantTest.extend<restaurant>({
  location: async ({ page }, use) => {
    await use(new RestaurantLocation(page));
  },
  room: async ({ page }, use) => {
    await use(new RestaurantElement(page, ElementType.Room));
  },
  table: async ({ page }, use) => {
    await use(new RestaurantConfigElement(page, ElementType.Table));
  },
  wall: async ({ page }, use) => {
    await use(new RestaurantConfigElement(page, ElementType.Wall));
  },
  bar: async ({ page }, use) => {
    await use(new RestaurantConfigElement(page, ElementType.Bar));
  },
});

export const test = testRestaurant;
