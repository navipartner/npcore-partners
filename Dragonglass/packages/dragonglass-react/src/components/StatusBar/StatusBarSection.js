import React, { Component } from "react";
import { getRenderer } from "./statusBarHelper";

class StatusBarSection extends Component {
    render() {
        const { id, layout, style, dataSource, customClass } = this.props;
        const classList = ["statusbar__section"];
        customClass && classList.push(customClass);
        layout.sections && classList.push("statusbar__section--group");
        const unique = [...new Set(classList.join(" ").split(" "))]

        return (
            <div style={style} className={`${unique.join(" ")}`} id={id}>
                {
                    getRenderer(layout).call(this, layout, id, layout.dataSource || dataSource)
                }
            </div>
        )
    }
}

export default StatusBarSection;