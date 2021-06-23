import React, { Component } from "react";
import { ButtonMenuPage } from "./ButtonMenuPage";
import SwipeableViews from "react-swipeable-views";

export class ButtonMenuContent extends Component {
    render() {
        return (
            <div className="c-button-menu__content">
                <SwipeableViews enableMouseEvents>
                    <ButtonMenuPage />
                    <ButtonMenuPage />
                    <ButtonMenuPage />
                </SwipeableViews>
            </div>
        );
    }
}