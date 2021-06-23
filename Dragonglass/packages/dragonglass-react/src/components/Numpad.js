import React, { Component } from "react";
import ButtonGrid from "./ButtonGrid";
import { NumpadClickHandler } from "../dragonglass-click-handlers/grid/NumpadClickHandler";
import { bindComponentToFormatState } from "../redux/reducers/formatReducer";
import { localize, GlobalCaption } from "./LocalizationManager";

class Numpad extends Component {
  render() {
    const {
      id,
      enterValueFunction,
      submitFunction,
      format,
      simple,
    } = this.props;
    const { number } = format;
    const separator = (number && number.NumberDecimalSeparator) || ".";

    return (
      <div className="numpad" id={id}>
        <ButtonGrid
          buttons={
            simple
              ? [
                  [{ caption: 7 }, { caption: 8 }, { caption: 9 }],
                  [{ caption: 4 }, { caption: 5 }, { caption: 6 }],
                  [{ caption: 1 }, { caption: 2 }, { caption: 3 }],
                  [
                    { caption: separator },
                    { caption: 0 },
                    {
                      caption: localize(GlobalCaption.FromBackEnd.Global_OK),
                      submit: true,
                      backgroundColor: "green",
                    },
                  ],
                ]
              : [
                  [
                    { caption: "7" },
                    { caption: "8" },
                    { caption: "9" },
                    { caption: "+", backgroundColor: "gray" },
                  ],
                  [
                    { caption: "4" },
                    { caption: "5" },
                    { caption: "6" },
                    { caption: "-", backgroundColor: "gray" },
                  ],
                  [
                    { caption: "1" },
                    { caption: "2" },
                    { caption: "3" },
                    { caption: "x", backgroundColor: "gray", value: "*" },
                  ],
                  [
                    { caption: "0" },
                    { caption: "00" },
                    { caption: separator },
                    { caption: "/", backgroundColor: "gray" },
                  ],
                ]
          }
          clickHandler={
            new NumpadClickHandler(enterValueFunction, submitFunction)
          }
        ></ButtonGrid>
      </div>
    );
  }
}

export default bindComponentToFormatState(Numpad);
