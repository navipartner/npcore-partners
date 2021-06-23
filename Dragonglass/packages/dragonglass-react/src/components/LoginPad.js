import React, { Component } from "react";
import Input from "./Input";
import Numpad from "./Numpad";
import { DataType } from "../enums/DataType";
import { runWorkflow } from "dragonglass-workflows";

class LoginPad extends Component {
  constructor(props) {
    super(props);
    this._refs = {
      input: React.createRef(),
      submit: this._submit,
    };
  }

  async _submit() {
    const content = {
      _getInitialContext: () => ({
        type: "SalespersonCode",
        password: this._refs.input.current.value,
      }),
    };

    await runWorkflow("login", content);
    if (this._refs.input.current)
      this._refs.input.current._clear();
  }

  render() {
    const { id } = this.props;
    return (
      <div className="loginpad" id={id}>
        <Input
          simple={true}
          ref={this._refs.input}
          dataType={DataType.STRING}
          onEnter={() => this._submit()}
          inputType="password"
          erase={true}
          layout={{ caption: "l$.Sale_SalesPersonCode" }}
        />
        <Numpad
          simple={true}
          enterValueFunction={(value) =>
            this._refs.input.current.insertValueAtCurrentPosition(value)
          }
          submitFunction={() => this._submit()}
          inputRef={this._refs}
        />
      </div>
    );
  }
}

export default LoginPad;
