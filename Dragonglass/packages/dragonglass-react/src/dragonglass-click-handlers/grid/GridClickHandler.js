import { IncorrectSignatureError } from "../../dragonglass-errors/IncorrectSignatureError";

/**
 * A base class for specific click handlers in different kinds of button grids. Click handlers
 * are introduced to separate different business logic concerns from button grids. For example,
 * clicks are handled differently in a simple numpad, in a menu button grid, in a popup menu grid,
 * in login pad, etc. Since each of those has different business logic, to avoid endless switch
 * statements, individual GridClickHandler classes can handle custom business logic.
 */
export class GridClickHandler {
    constructor(handler) {

        if (typeof handler !== "function")
            throw new IncorrectSignatureError("new GridClickHandler", "function");

        Object.defineProperty(this, "_handler", {
            value: handler
        });
    }

    /**
     * Responds to the button click event.
     * 
     * @param {MenuButtonInfo} button Button component that caused the click event.
     * @param {ButtonGrid} sender ButtonGrid to which the button that was clicked belongs.
     * 
     * @returns {Boolean} Indicates whether the event was handled fully. Handled events do not bubble up.
     */
    onClick(button, sender) {
        return this._handler.call(this, button, sender);
    }
}