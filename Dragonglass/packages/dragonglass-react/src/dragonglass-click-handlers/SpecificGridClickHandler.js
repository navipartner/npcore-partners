import { BaseGridClickHandler } from "./grid/BaseGridClickHandler";

export class SpecificGridClickHandler extends BaseGridClickHandler {
    constructor() {
        super(() => {
            console.warn(`The ${this.constructor.name} class extends SpecificClickHandler but does not implement the onClick method. This is a programming error.`);
        });
    }

    registerClickHandler() {
        // Does nothing. Must be implemented in descendant class.
    }

    onClick() {
        // Does nothing. Must be implemented in descendant class.
    }
}
