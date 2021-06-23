import React, { Component } from "react";
import { connect } from "react-redux";
import { testEvents } from "./tests/Test.Events";
import { Popup } from "../dragonglass-popup/PopupHost";
import { setActiveViewAction } from "../redux/view/view-actions";
import { defineImageAction } from "../redux/actions/imageActions";
import { updateDataAction } from "../redux/actions/dataActions";

class Mock extends Component {
  render() {
    return (
      <>
        <button onClick={() => this.props.switchUi()}>🐲🍸</button>|
        <button onClick={() => this.props.view.login()}>Login</button>
        <button onClick={() => this.props.view.sale()}>Sale</button>
        <button onClick={() => this.props.view.payment()}>Payment</button>|
        <button onClick={() => this.props.image.maga()}>Logo: MAGA</button>
        <button onClick={() => this.props.image.brexit()}>Logo: Brexit</button>|
        <button onClick={() => this.props.data.addLine()}>
          Sale: Add line
        </button>
        <button onClick={() => this.props.data.updateLine()}>
          Sale: Change qty.
        </button>
        <button onClick={() => this.props.data.deleteLine()}>
          Sale: Delete line
        </button>
        |
        <button
          onClick={() =>
            Popup.message("Hello, World!").then(() => alert("Done!"))
          }
        >
          Message
        </button>
        <button
          onClick={() =>
            Popup.confirm({
              caption: "Do you want to say 'Hello, World'?",
              confirmOnEnter: false,
            }).then(
              (result) => result && Popup.message("Ok then. Hello, World.")
            )
          }
        >
          Confirm
        </button>
        <button
          onClick={() =>
            Popup.numpad({
              caption: "Enter π (pi) with as many decimals as you know",
              value: 3.14,
            }).then((result) => alert("Result: " + JSON.stringify(result)))
          }
        >
          Numpad
        </button>
        <button
          onClick={() =>
            Popup.calendarPlusGrid({
              caption: "Just do it!",
              dataSource: "BUILTIN_SALELINE",
            }).then((result) => alert("Result: " + JSON.stringify(result)))
          }
        >
          Calendar+Grid
        </button>
        <button
          onClick={() =>
            Popup.optionsMenu({
              title: "Who's the best?",
              caption: "Just do it!",
              oneTouch: true,
              options: [
                { caption: "Tim", icon: "fa-rocket", id: 1 },
                "Mark",
                "Vjeko",
                "Vladimir",
                "Alexandru",
              ],
            }).then((result) => alert("Result: " + JSON.stringify(result)))
          }
        >
          One-touch options menu
        </button>
        <button
          onClick={() =>
            Popup.optionsMenu({
              title: "Who's the best?",
              caption: "Just do it!",
              options: [
                { caption: "Tim", icon: "fa-rocket", id: 1 },
                "Mark",
                "Vjeko",
                "Vladimir",
                "Alexandru",
              ],
            }).then((result) => alert("Result: " + JSON.stringify(result)))
          }
        >
          Options menu
        </button>
        <button
          onClick={() =>
            Popup.optionsMenu({
              title: "Who's the best?",
              caption: "Just do it!",
              multiSelect: true,
              options: [
                { caption: "Tim", icon: "fa-rocket", id: 1 },
                "Mark",
                "Vjeko",
                "Vladimir",
                "Alexandru",
              ],
            }).then((result) => alert("Result: " + JSON.stringify(result)))
          }
        >
          Options menu (multi)
        </button>
        |<button onClick={testEvents}>Test events</button>
      </>
    );
  }
}

const mapDispatchToProps = (dispatch) => ({
  view: {
    login: () => dispatch(setActiveViewAction("login")),
    sale: () => dispatch(setActiveViewAction("sale")),
    payment: () => dispatch(setActiveViewAction("payment")),
  },
  image: {
    maga: () => dispatch(defineImageAction({ logo: __img.maga })),
    brexit: () => dispatch(defineImageAction({ logo: __img.brexit })),
  },
  data: {
    addLine: () => dispatch(updateDataAction(__data.addLine())),
    updateLine: () => dispatch(updateDataAction(__data.changeLine())),
    deleteLine: () => dispatch(updateDataAction(__data.deleteLine())),
  },
});

export default connect(null, mapDispatchToProps)(Mock);
