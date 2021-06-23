import { PureComponent } from "react";
import { Popup } from "../dragonglass-popup/PopupHost";
import { bindComponentToViewActiveState } from "../redux/view/view-bind";
import { clearPopupsAction } from "../redux/actions/popupActions";
import { Workflow } from "dragonglass-workflows";
import { EventDispatcher } from "dragonglass-core";
import { Options } from "../classes/Options";
import { StateStore } from "../redux/StateStore";
import { showCartAction } from "../redux/actions/cartActions";

const BEFORE_TIMEOUT_DIALOG = "beforeTimeoutDialog";
const AFTER_TIMEOUT_DIALOG = "afterTimeoutDialog";
const TIMEOUT_SUSPEND = "timeoutSuspend";
const TIMEOUT_RESUME = "timeoutResume";

const DEFAULT_CAPTION = "We wonder if you are still here?";
const DEFAULT_TITLE = "We might have lost you somewhere...";
const DEFAULT_BUTTON_CAPTION = "Yes, I am still here, just need some more time";

const timeoutEventDispatcher = new EventDispatcher([
  BEFORE_TIMEOUT_DIALOG,
  AFTER_TIMEOUT_DIALOG,
  TIMEOUT_SUSPEND,
  TIMEOUT_RESUME,
]);

export const Timeout = {
  suspend: () => {
    if (!currentInstance || !currentInstance._workflowToRun) return false;

    return currentInstance._suspend();
  },

  resume: () => {
    if (!currentInstance || !currentInstance._workflowToRun) return false;

    return currentInstance._resume();
  },

  isDialogShown: () => {
    return !!(currentInstance && currentInstance._inDialog);
  },

  isSuspended: () => {
    return !!(currentInstance && currentInstance._suspended);
  },

  isTimeoutActive: () => {
    return !!(
      currentInstance &&
      currentInstance._active &&
      currentInstance._workflowToRun
    );
  },

  eventDispatcher: timeoutEventDispatcher,
};

let currentInstance = null;

class TimeoutHandler extends PureComponent {
  constructor(props) {
    super(props);

    this._workflowToRun = Options.get("idleTimeoutWorkflow");
    this._timeout = 0;
  }

  _setupEvents() {
    this._handler = () => {
      if (this._inDialog || this._suspended) return;

      this._setTimeout();
    };
    document.addEventListener("keydown", this._handler, true);
    document.addEventListener("mousedown", this._handler, true);
    document.addEventListener("touchstart", this._handler, true);
    document.addEventListener("touchmove", this._handler, true);
  }

  _removeEvents() {
    document.removeEventListener("keydown", this._handler, true);
    document.removeEventListener("mousedown", this._handler, true);
    document.removeEventListener("touchstart", this._handler, true);
    document.removeEventListener("touchmove", this._handler, true);
  }

  async _callTimeout() {
    if (this._suspended) return;

    const timeoutController = {
      graceTime: this.props.timeout.graceTime,
      caption: this.props.timeout.caption || DEFAULT_CAPTION,
      title: this.props.timeout.title || DEFAULT_TITLE,
      buttonCaption: this.props.timeout.buttonCaption || DEFAULT_BUTTON_CAPTION,
      suspended: false,
      skipDialog: false,
      customHandler: null,
    };

    timeoutEventDispatcher.raise(BEFORE_TIMEOUT_DIALOG, timeoutController);
    if (timeoutController.suspended) this._suspend();

    // Suspension may have occurred through eventArgs.suspended = true or runtime.suspendTimeout() - both should be observed!
    if (this._suspended) return;

    const handler =
      typeof timeoutController.customHandler === "function"
        ? async () => await Promise.resolve(timeoutController.customHandler())
        : async () =>
            await Popup.timeout({
              timeout: timeoutController.graceTime,
              caption: timeoutController.caption || DEFAULT_CAPTION,
              title: timeoutController.title || DEFAULT_TITLE,
              buttonCaption:
                timeoutController.buttonCaption || DEFAULT_BUTTON_CAPTION,
            });

    this._inDialog = true;
    const timedOut = timeoutController.skipDialog || (await handler());
    timeoutEventDispatcher.raise(AFTER_TIMEOUT_DIALOG, {
      timedOut: !!timedOut,
      skippedDialog: !!timeoutController.skipDialog,
      customHandler: !!timeoutController.customHandler,
    });
    this._inDialog = false;

    if (!timedOut) {
      this._setTimeout();
      return;
    }

    StateStore.dispatch(clearPopupsAction());
    StateStore.dispatch(showCartAction(false));
    Workflow.run(this._workflowToRun);
  }

  _clearTimeout() {
    if (this._timeout) clearTimeout(this._timeout);
  }

  _setTimeout() {
    this._clearTimeout();
    this._timeout = setTimeout(
      () => this._callTimeout(),
      this.props.timeout.after * 1000
    );
  }

  _activate() {
    if (this._active || this._inDialog || this._suspended) return false;

    currentInstance = this;
    this._active = true;
    this._setTimeout();
    this._setupEvents();
    return true;
  }

  _deactivate() {
    if (!this._active) return false;

    this._active = false;
    this._clearTimeout();
    this._removeEvents();
    return true;
  }

  _suspend() {
    this._suspended = true;
    var suspended = this._deactivate();
    if (suspended) {
      timeoutEventDispatcher.raise(TIMEOUT_SUSPEND, {});
    }

    return suspended;
  }

  _resume() {
    this._suspended = false;
    if (!this.props.active) return false;

    var resumed = this._activate();
    if (resumed) {
      timeoutEventDispatcher.raise(TIMEOUT_RESUME, {});
    }

    return resumed;
  }

  componentDidMount() {
    currentInstance = this.props.active ? this : null;
  }

  componentWillUnmount() {
    currentInstance = null;
    this._deactivate();
  }

  render() {
    if (!this._workflowToRun) return null;

    this.props.active ? this._activate() : this._deactivate();

    return null;
  }
}

export default bindComponentToViewActiveState(TimeoutHandler);
