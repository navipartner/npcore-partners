import React, { Component } from "react";
import { Button } from "./Button";

export class ButtonMenuRow extends Component {
    render() {
        return (
            <div className="c-grid__row c-grid__row--button-menu">
                <Button />
                <Button />
                <Button />
                <Button />
            </div>
        );
    }
}