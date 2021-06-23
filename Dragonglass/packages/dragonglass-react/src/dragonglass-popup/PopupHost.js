import React, { Component } from "react";
import { Dialog } from "./Dialog";
import { DialogType } from "./enums/DialogType";
import { bindComponentToPopupsState } from "../redux/reducers/popupReducer";
import { buildClass } from "../classes/functions";
import { Focus } from "../components/FocusManager";
import { TooManyInstancesError } from "../dragonglass-errors/TooManyInstancesError";
import { localize, GlobalCaption } from "../components/LocalizationManager";
import { AnimatePresence } from "framer-motion";

let dialogId = 0;
let singleton = null;

const POPUP_HOST_ID = "popup-host";

class PopupHostUnbound extends Component {
  constructor(props) {
    super(props);
    if (singleton)
      throw new TooManyInstancesError(
        "You cannot instantiate more than one instance of the PopupHost component per application."
      );
    this._overlayClickInvoker = null;
  }
  componentDidMount() {
    singleton = this;
  }

  componentWillUnmount() {
    singleton = null;
  }

  _overlayClicked(e) {
    if (e.target.id !== POPUP_HOST_ID) return;

    if (typeof this._overlayClickInvoker === "function")
      this._overlayClickInvoker();
  }

  _subscribeOverlayClicked(invoker) {
    this._overlayClickInvoker = invoker;
  }

  render() {
    const { popups } = this.props;
    const visibleLength = popups.length;

    if (visibleLength) Focus.suspend();
    else Focus.resume();

    this._overlayClickInvoker = null;

    return (
      <div
        id={POPUP_HOST_ID}
        onClick={(e) => visibleLength && this._overlayClicked(e)}
        className={buildClass(
          "dialog-host",
          visibleLength ? "dialog-host--show" : ""
        )}
      >
        <AnimatePresence>
          {popups.map((popup, index) => (
            <Dialog
              overlayClickSubscribe={(invoker) =>
                this._subscribeOverlayClicked(invoker)
              }
              topmost={index === popups.length - 1}
              key={popup.id}
              {...popup}
              offset={popups.length - 1 - index}
            />
          ))}
        </AnimatePresence>
      </div>
    );
  }

  showDialog(type, title, content) {
    const id = ++dialogId;
    return new Promise((fulfill) => {
      this.props.show({
        id: id,
        type: type,
        title: typeof content === "object" ? content.title || title : title,
        content: content,

        _interface: {
          _id: id, // for debugging purposes only
          close: (result) => {
            fulfill(result);
            this.props.remove(id);
          },
        },
      });
    });
  }
}

// TODO: Localize default title parameter values
/**
 * An exported static class that allows anyone to request a dialog to be shown on screen. It contains specific methods
 * for each specific dialog type.
 *
 * @export
 * @class Popup
 */
export class Popup {
  static message(
    content,
    title = localize(GlobalCaption.FromBackEnd.DialogCaption_Message)
  ) {
    return singleton.showDialog(DialogType.MESSAGE, title, content);
  }

  static error(
    content,
    title = localize(GlobalCaption.FromBackEnd.DialogCaption_Error)
  ) {
    return singleton.showDialog(DialogType.ERROR, title, content);
  }

  static confirm(
    content,
    title = localize(GlobalCaption.FromBackEnd.DialogCaption_Confirmation)
  ) {
    return singleton.showDialog(DialogType.CONFIRM, title, content);
  }

  static input(
    content,
    title = localize(GlobalCaption.FromBackEnd.DialogCaption_Numpad)
  ) {
    return singleton.showDialog(DialogType.INPUT, title, content);
  }

  static numpad(
    content,
    title = localize(GlobalCaption.FromBackEnd.DialogCaption_Numpad)
  ) {
    return singleton.showDialog(DialogType.NUMPAD, title, content);
  }

  static calendarPlusGrid(content, title) {
    return singleton.showDialog(DialogType.CALENDAR_PLUS_GRID, title, content);
  }

  static menu(
    content,
    title = localize(GlobalCaption.FromBackEnd.DialogCaption_Numpad)
  ) {
    return singleton.showDialog(DialogType.MENU, title, content);
  }

  static lookup(
    content,
    title = localize(GlobalCaption.FromBackEnd.DialogCaption_Numpad)
  ) {
    return singleton.showDialog(DialogType.LOOKUP, title, content);
  }

  static optionsMenu(content, title = "Please, make your pick") {
    return singleton.showDialog(DialogType.OPTIONS, title, content);
  }

  static configuration(content, title = "Please, complete the configuration") {
    return singleton.showDialog(DialogType.CONFIGURATION, title, content);
  }

  static seatingSetup(content, title = "Restaurant layout") {
    return singleton.showDialog(DialogType.SEATING_SETUP, title, content);
  }

  static splitBill(content, title = "Split bill") {
    return singleton.showDialog(DialogType.SPLIT_BILL, title, content);
  }

  static configurationTable(
    content,
    title = "Please, complete the configuration"
  ) {
    return singleton.showDialog(DialogType.CONFIGURATION_TABLE, title, content);
  }

  static timeout(content, title = "We might have lost you somewhere...") {
    return singleton.showDialog(DialogType.TIMEOUT, title, content);
  }

  static customDialog(content, title) {
    return singleton.showDialog(DialogType.CUSTOM_DIALOG, title, content);
  }

  static lookup(content, title) {
    return singleton.showDialog(DialogType.LOOKUP, title, content);
  }
}

export const PopupHost = bindComponentToPopupsState(PopupHostUnbound);
