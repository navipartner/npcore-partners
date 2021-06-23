import React, { Component } from "react";
import { bindComponentToFontsState } from "../redux/reducers/fontReducer";
import { WebFont } from "./WebFont";

class WebFontManagerUnbound extends Component {
    render() {
        return this.props.fonts.map(font => <WebFont key={font.prefix} {...font} />);
    }
}

export const WebFontManager = bindComponentToFontsState(WebFontManagerUnbound);
