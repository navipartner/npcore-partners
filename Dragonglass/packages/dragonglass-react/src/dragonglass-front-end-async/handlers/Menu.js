import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { defineMenu } from "../../redux/menu/menu-actions";
import { StateStore } from "../../redux/StateStore";

export class Menu extends FrontEndAsyncRequestHandler {
  handle(request) {
    let menus = request.Menus;
    let payload = {};
    for (var menu of menus) payload[menu.Id] = menu;

    StateStore.dispatch(defineMenu(payload));
  }
}
