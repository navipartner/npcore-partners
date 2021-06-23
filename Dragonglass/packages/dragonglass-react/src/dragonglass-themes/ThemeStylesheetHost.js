import React, { Component } from "react";
import { bindComponentToThemeStylesState } from "../redux/reducers/themesReducer";

class ThemeStylesheetHost extends Component {
    render() {
        const { styleInnerHtml } = this.props;
        return styleInnerHtml
            ? <style dangerouslySetInnerHTML={{ __html: styleInnerHtml }} />
            : null;
    }
}

export default bindComponentToThemeStylesState(ThemeStylesheetHost);
