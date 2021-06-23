import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { defineDataSourceAction } from "../../redux/actions/dataActions";
import {
  defineViewAction,
  setActiveViewAction,
} from "../../redux/view/view-actions";
import { DEFAULT_VIEW_LOGIN } from "../../views/login";
import { DEFAULT_VIEW_SALE } from "../../views/sale";
import { DEFAULT_VIEW_PAYMENT } from "../../views/payment";
import { DEFAULT_VIEW_RESTAURANT } from "../../views/restaurant";
import { GlobalEventDispatcher, GLOBAL_EVENTS } from "dragonglass-core";
import { isMobile } from "../../classes/functions";
import { DEFAULT_VIEW_BALANCE } from "../../views/balance";

const viewTypeMap = {
  1: "login",
  2: "sale",
  3: "payment",
  4: "balance",
  12: "restaurant",
};

const defaultViews = {
  login: DEFAULT_VIEW_LOGIN,
  sale: DEFAULT_VIEW_SALE,
  payment: DEFAULT_VIEW_PAYMENT,
  balance: DEFAULT_VIEW_BALANCE,
  restaurant: DEFAULT_VIEW_RESTAURANT,
};

export class SetView extends FrontEndAsyncRequestHandler {
  handle(request) {
    const view = request.View;
    let { layout, dataSources } = view;
    const type = viewTypeMap[view.type];

    if (dataSources) StateStore.dispatch(defineDataSourceAction(dataSources));

    if (
      !layout ||
      (!layout.content && !layout.viewDesktop && !layout.viewMobile)
    )
      layout = defaultViews[type];

    const mobile = isMobile();
    if (layout.viewDesktop && !mobile) layout = layout.viewDesktop;
    else if (layout.viewMobile && mobile) layout = layout.viewMobile;

    StateStore.dispatch(defineViewAction(layout));

    if (type) StateStore.dispatch(setActiveViewAction(type));

    GlobalEventDispatcher.raise(GLOBAL_EVENTS.SET_VIEW, { type, layout });
  }
}
