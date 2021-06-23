import React, { Component } from "react";
import Input from "./Input";
import { InputType, dataTypeToInputType } from "../dragonglass-popup/enums/InputType";

export default class InputWithBinding extends Component {
    constructor(props) {
        super(props);

        this.state = {
            value: this.props.selector()
        };

        this._inputType = dataTypeToInputType(this.props.dataType);
    }

    shouldComponentUpdate(_, nextState) {
        return nextState.value !== this.state.value;
    }

    _updateValue(value, valid) {
        if (!valid)
            return;

        this.props.updater(InputType.behavior[this._inputType].calculate(value));
    }

    render() {
        const { caption, id, dataType, editable } = this.props;

        return (
            <div className="input-with-binding">
                <div className="input-with-binding__content">
                    <div className="input-with-binding__caption">{caption}</div>
                    <div className="input-with-binding__input">
                        <Input
                            id={id}
                            caption={caption}
                            editable={ typeof(editable) === "boolean" ? editable : true }
                            dataType={dataType}
                            value={this.state.value}
                            onChange={(value, fullyValid) => this._updateValue(value, fullyValid)}
                            erase={true}
                        />
                    </div>
                </div>
            </div>
        )
    }
}
