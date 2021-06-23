import { Component } from "react";
import { bindComponentToLocalizationState } from "../redux/reducers/localizationReducer";

class LocalizedCaption extends Component {
    render() {
        return this.props.caption;
    }
}

export default bindComponentToLocalizationState(LocalizedCaption);
