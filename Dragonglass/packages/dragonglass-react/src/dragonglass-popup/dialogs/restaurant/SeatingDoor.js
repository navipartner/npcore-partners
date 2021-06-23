import React from "react";
import { SeatingComponent } from "./SeatingComponent";
import { Door } from "../../../components/Restaurant/ui/Door";

export class SeatingDoor extends SeatingComponent {
    getContent() {
        return (
            <Door />
        );
    }
}
