import React, { Component } from "react";
import Button from "../../components/Button";

export class DialogButtons extends Component {
    constructor(props) {
        super(props);
        this.state = {};
    }
    render() {
        const { buttons } = this.props;
        const setState = () => this.setState({});
        return buttons.map((button, id) =>
            <Button
                key={id}
                id={button.id}
                button={button.button}
                caption={button.caption}
                onClick={button.click}
                enabled={button.enabler ? button.enabler.getEnabled(setState) : true}
            />
        );
    }
}