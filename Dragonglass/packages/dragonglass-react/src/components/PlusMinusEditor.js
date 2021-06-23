import React, { Component } from "react";
import { Popup } from "../dragonglass-popup/PopupHost";

export default class PlusMinusEditor extends Component {
    constructor(props) {
        super(props);

        this._minValue = this.props.minValue || 0;
        this._maxValue = this.props.maxValue || Number.MAX_SAFE_INTEGER;

        this.state = {
            value: this._normalizeValue(this.props.passive || (this.props.hasOwnProperty("value") && !this.props.selector) ? this.props.value : this.props.selector())
        };
    }

    shouldComponentUpdate(nextProps, nextState) {
        return this.props.passive
            ? nextProps.value !== this.props.value
            : nextState.value !== this.state.value;
    }

    _normalizeValue(value) {
        if (value >= this._minValue && value <= this._maxValue)
            return value;

        if (value > this._maxValue)
            return this._maxValue;

        return this._minValue;
    }

    _isMinValue() {
        return (this.props.passive ? this.props.value : this.state.value) <= this._minValue;
    }

    _isMaxValue() {
        return (this.props.passive ? this.props.value : this.state.value) >= this._maxValue;
    }

    _updateState(increaseBy) {
        if (this.props.passive) {
            this.props.updater(increaseBy);
            return;
        }

        const newValue = this.state.value + increaseBy;
        this.setState({ value: newValue });
        this.props.updater(newValue);
    }

    _decrease() {
        if (this._isMinValue())
            return;

        this._updateState(-1);
    }

    _increase() {
        if (this._isMaxValue())
            return;

        this._updateState(1);
    }

    async _clickValue() {
        let value = this.props.passive ? this.props.value : this.state.value;
        const result = await Popup.numpad({ caption: this.props.caption || "Enter the number", value});
        if (result === null)
            return;

        this._updateState(result - value);
    }

    render() {
        const { caption, withDelete, readOnly } = this.props;

        return (
            <div className="plus-minus-editor">
                <div className="plus-minus-editor__caption">
                    <span>{caption}</span>
                </div>
                <div className="plus-minus-editor__buttons">
                    {withDelete && <div className="remove" onClick={() => typeof this.props.delete === "function" && this.props.delete()}><span className="label">Remove</span><span className="fa fa-trash"></span></div>}
                    {!readOnly && <div className={`subtract${this._isMinValue() ? " disabled" : ""}`} onClick={() => this._decrease()}><span>-</span></div>}
                    <div className="value" onClick={() => this._clickValue()}><span>{this.props.passive ? this.props.value : this.state.value}</span></div>
                    {!readOnly && <div className={`add${this._isMaxValue() ? " disabled" : ""}`} onClick={() => this._increase()}><span>+</span></div>}
                </div>
            </div>
        )
    }
}
