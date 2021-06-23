import React, { Component } from "react";
import { SeatingSetupMenuButton } from "./SeatingSetupMenuButton";
import { SeatingSetupLocations } from "./SeatingSetupLocations";

export class SeatingSetupMenu extends Component {
  constructor(props) {
    super(props);
    this.state = {
      expanded: false,
      isActive: false,
    };
  }

  toggleMenu() {
    this.setState({
      expanded: !this.state.expanded,
      isActive: !this.state.isActive,
    });
  }

  createNew(type) {
    this.props.action({ action: "new", type: type });
  }

  locationAction(type, target) {
    this.props.action({ action: "location", type: type, target: target });
  }

  render() {
    const locationId = this.props.location;
    const { locations } = this.props.layout;
    const location =
      locations && locations.length
        ? locations.find((l) => l.id === locationId)
        : null;

    return (
      <div
        className={
          this.state.isActive
            ? "seating-setup-menu is-active"
            : "seating-setup-menu"
        }
      >
        <div
          className="seating-setup-menu__burger"
          onClick={() => this.toggleMenu()}
        >
          <span className="seating-setup-menu__title">Locations</span>
          <span className="burger-icon"></span>
        </div>
        {this.state.expanded && (
          <div className="seating-setup-menu__content">
            <SeatingSetupLocations
              layout={this.props.layout}
              selected={locationId}
              action={(option, target) => this.locationAction(option, target)}
            />
            {locations && locations.length ? (
              <div className="seating-setup-menu__buttons">
                <div className="seating-setup-menu__configuration-title">
                  Configure {(location && location.caption) || "unknown"}
                </div>
                <SeatingSetupMenuButton
                  caption="New Room"
                  onClick={() => this.createNew("room")}
                />
                <SeatingSetupMenuButton
                  caption="New Table"
                  onClick={() => this.createNew("table")}
                />
                <SeatingSetupMenuButton
                  caption="New Wall"
                  onClick={() => this.createNew("wall")}
                />
                <SeatingSetupMenuButton
                  caption="New Bar Counter"
                  onClick={() => this.createNew("bar")}
                />
              </div>
            ) : null}
          </div>
        )}
      </div>
    );
  }
}
