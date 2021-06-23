import { Component } from "react";
import { bindComponentToSingleOptionState } from "../redux/reducers/optionsReducer";

class OptionCaption extends Component {
    render() {
        return this.props.optionValue || null;
    }
}

export default bindComponentToSingleOptionState(OptionCaption);
