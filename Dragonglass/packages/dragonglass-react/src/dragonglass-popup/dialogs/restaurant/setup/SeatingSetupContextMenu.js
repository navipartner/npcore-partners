import React, { Component } from "react";
import { SeatingSetupMenuButton } from "./SeatingSetupMenuButton";

export class SeatingSetupContextMenu extends Component {
  render() {
    const { visible, options } = this.props;
    if (!visible) return null;

    return (
      <div className="seating-setup-context-menu">
        {options.map((option, index) => (
          <SeatingSetupMenuButton
            key={index}
            icon={option.icon}
            caption={option.caption}
            onClick={() => option.onClick()}
          />
        ))}
      </div>
    );
  }
}
