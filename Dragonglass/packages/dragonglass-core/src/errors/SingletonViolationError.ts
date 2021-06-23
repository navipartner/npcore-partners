import { CustomDragonglassError } from "./CustomDragonglassError";

export class SingletonViolationError extends CustomDragonglassError {
    className: string;
    base: boolean;

    /**
     * Thrown by constructors when an attempt is made to instantiate more than one instance of a class
     */
    constructor(name: string, base: boolean = false) {
        super(`Singleton expected for "${name}"`);

        this.className = name;
        this.base = !!base;
    }
}
