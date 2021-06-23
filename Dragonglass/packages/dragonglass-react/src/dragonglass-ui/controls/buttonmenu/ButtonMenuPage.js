import React, { Component } from "react";
import { ButtonMenuRow } from "./ButtonMenuRow";


export class ButtonMenuPage extends Component {
    render() {
        return (
            <div className="c-grid c-grid--button-menu">
                <ButtonMenuRow />
                <ButtonMenuRow />
                <ButtonMenuRow />
                <ButtonMenuRow />
                <ButtonMenuRow />
                <ButtonMenuRow />
                <ButtonMenuRow />                 
            </div> 
        );
    }
}