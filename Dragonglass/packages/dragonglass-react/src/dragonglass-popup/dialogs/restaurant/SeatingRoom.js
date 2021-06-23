import React from "react";
import { SeatingComponent } from "./SeatingComponent";
import { Room } from "../../../components/Restaurant/ui/Room";

export class SeatingRoom extends SeatingComponent {
    getContent() {
        return (
            <Room caption={this.props.component.caption} />
        );
    }
}
