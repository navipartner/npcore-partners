import React, { Component } from "react";
import { SeatingSetupMenuButton } from "./SeatingSetupMenuButton";

export class SeatingSetupLocations extends Component {
  render() {
    const { selected } = this.props;
    let selectedLocation = null;
    return (
      <div className="seating-setup-locations">
        <>
          {this.props.layout.locations
            ? this.props.layout.locations.map(
                (location, index) => (
                  location.id === selected && (selectedLocation = location),
                  (
                    <div
                      key={index}
                      className={`seating-setup-locations__location ${
                        location.id === selected ? " selected" : ""
                      }`}
                      onClick={() => this.props.action("select", location.id)}
                    >
                      <span>{location.caption}</span>
                      {
                        <div className="seating-setup-locations__buttons">
                          <SeatingSetupMenuButton
                            icon="fa fa-trash"
                            onClick={() =>
                              this.props.action("delete", location.id)
                            }
                          />
                          <SeatingSetupMenuButton
                            icon="fa fa-pencil"
                            onClick={() => this.props.action("edit", location)}
                          />
                        </div>
                      }
                    </div>
                  )
                )
              )
            : null}

          {this.props.layout.locations.length ? null : (
            <div className="seating-setup-locations__no-location">
              (No locations)
            </div>
          )}
        </>
        <div className="seating-setup-menu__new-location">
          <SeatingSetupMenuButton
            icon=""
            caption="New Location"
            onClick={() => this.props.action("new")}
          />
        </div>
      </div>
    );
  }
}
