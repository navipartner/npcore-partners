import { SingletonViolationError } from "../errors/SingletonViolationError";

const _classNames: string[] = [];
const _classes: Record<string, any> = {};

/**
 * Represents the base class that can only have a single instance.
 */
export class Singleton {
    /**
     * Instantiates the instance of the Singleton class
     * @throws {SingletonViolationError} If an instance of this class has already been instantiated.
     */
    constructor() {
        const { name } = this.constructor;

        if (name === Singleton.prototype.constructor.name)
            throw new SingletonViolationError(name, true);

        if (_classNames.includes(name))
            throw new SingletonViolationError(name);

        _classNames.push(name)
        _classes[name] = this;
    }

    static get instance(): Singleton {
        return _classes[this.prototype.constructor.name];
    }
}
