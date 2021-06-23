import { GridClickHandler } from "./GridClickHandler";
import { ButtonClickHandler } from "../button/ButtonClickHandler";
import { IncorrectSignatureError } from "../../dragonglass-errors/IncorrectSignatureError";

export class GenericGridClickHandler extends GridClickHandler {
    constructor() {
        super(() => { });
        Object.defineProperty(this, "_handlers", {
            value: []
        });
    }

    /**
     * Registers a button click handler that executes specific button click events.
     * 
     * @param {ButtonClickHandler} handler An instance of a ButtonClickHandler that handles the click if the filter returns true.
     */
    registerClickHandler(handler) {
        if (!(handler instanceof ButtonClickHandler))
            throw new IncorrectSignatureError("registerClickHandler", "Function<MenuButtonInfo, ButtonGrid, Boolean>, ButtonClickHandler");

        this._handlers.push(handler);
    }

    onClick(button, sender) {
        if (this._handlers.length) {
            for (let handler of this._handlers) {
                if (handler.accepts(button, sender))
                    return handler.onClick(button, sender);
            }

            console.warn(`The ${this.constructor.name} class did not register a click handler that responded to this particular button click.`);
            console.dir(button);
            return false;
        }

        console.warn(`The ${this.constructor.name} class extends GenericGridClickHandler but does neither implement the onClick method nor register any button click handlers. This is a programming error.`);
    }
}