import React, { Component } from "react";

export default class RadioGroup extends Component {
    constructor(props) {
        super(props);

        this.state = {
            value: this.props.selector()
        };
    }

    shouldComponentUpdate(_, nextState) {
        return nextState.value !== this.state.value;
    }

    _setValue(value) {
        this.setState({ value: value });
        this.props.updater(value);
    }

    render() {
        const { caption, id, options, vertical } = this.props;

        return (
            <div className="radio-group">
                <div className="radio-group__caption">
                    <span>{caption}</span>
                </div>
                <div className={`radio-group__content${vertical ? " radio-group__content--vertical" : ""}`}>
                    {
                        options.map((option, index) =>
                            <label className={`switch__label switch__label--radio-group ${option.value === this.state.value}`} key={index}>
                                <span className="switch__caption switch__caption--radio-group">{option.caption}</span>
                                <input className="switch__checkbox switch__radio" type="radio" onChange={() => this._setValue(option.value)} checked={option.value === this.state.value} name={`radio-${id}`}></input>
                                <span className="switch__pointer switch__pointer--radio-group"></span>
                            </label>
                        )
                    }
                </div>
            </div>
        )
    }
}

