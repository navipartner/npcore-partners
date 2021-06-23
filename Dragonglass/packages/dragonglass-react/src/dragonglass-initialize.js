import React from "react";
import { render } from "react-dom";
import { Provider } from "react-redux";
import App from "./App.js";
import Mock from "./_mock/Mock.js";
import { ReactInterface } from "./classes/ReactInterface";
import { FrontEndAsyncInterface } from "dragonglass-front-end-async";
import { StateStore } from "./redux/StateStore";
import { Capabilities } from "./dragonglass-capabilities/Capabilities";
import { initializeFrontEndId } from "./bootstrap/getFrontEndId.js";
import { initializeBrowserEvents } from "./bootstrap/browserEvents.js";
import { initializeVersion } from "./bootstrap/version.js";
import { customizeTop } from "./bootstrap/customize.js";
import { bootstrapBuiltinAsyncHandlersTodo } from "./dragonglass-front-end-async/bootstrapBuiltinAsyncHandlersTodo";
import { GlobalErrorDispatcher, GLOBAL_ERRORS } from "dragonglass-core";
import { bootstrapFrameworkReady, bootstrapKeepAlive, bootstrapSetDragonglass } from "dragonglass-nav";
import { raiseError } from "./redux/actions/errorActions.js";
import { WorkflowManager } from "dragonglass-workflows";
import { Popup } from "./dragonglass-popup/PopupHost";
import { Timeout } from "./components/TimeoutHandler.js";
import { LocalizationHandler } from "./components/LocalizationManager.js";
import { WorkflowPopupCoordinator } from "./dragonglass-popup/WorkflowPopupCoordinator";
import { Globals } from "./Globals.REFACTOR.js";
import { RestaurantBootstrap } from "./bootstrap/restaurantBootstrap.js";
import HardwareConnector from "./HardwareConnector";

export async function initializeDragonglass() {
  // Subscribe to global critical error event // TODO: Move this into a function of its own or a common bootstrap something this or that
  GlobalErrorDispatcher.addEventListener(GLOBAL_ERRORS.CRITICAL_ERROR, (error, serialized) => {
    console.error(`[CRITICAL ERROR] ${error}`);
    StateStore.dispatch(raiseError(serialized));
  });

  const transcendence = await ReactInterface.initializeTranscendence(StateStore);
  Globals.transcendence = transcendence; // TODO: refactor this away! It's temp!

  FrontEndAsyncInterface.initialize(window, transcendence);
  bootstrapBuiltinAsyncHandlersTodo(transcendence);

  WorkflowManager.initialize(
    transcendence,
    StateStore,
    Popup,
    (coordinator) => new WorkflowPopupCoordinator(coordinator),
    Timeout,
    LocalizationHandler,
    HardwareConnector
  );
  bootstrapKeepAlive();
  bootstrapSetDragonglass();

  Capabilities.initialize();
  initializeBrowserEvents();
  initializeFrontEndId();
  initializeVersion();
  customizeTop();

  window.dispatch = StateStore.dispatch;
  const switcher = {};
  const switchUi = () => {
    switcher.switchUi();
  };

  const toolbar = document.getElementById("toolbar");
  if (toolbar)
    render(
      <Provider store={StateStore.internalReduxStore}>
        <Mock switchUi={switchUi} />
      </Provider>,
      toolbar
    );

  RestaurantBootstrap.initialize();

  await bootstrapFrameworkReady();

  const controlAddIn = document.getElementById("controlAddIn");
  render(
    <Provider store={StateStore.internalReduxStore}>
      <App uiSwitcher={switcher} />
    </Provider>,
    controlAddIn
  );
}
