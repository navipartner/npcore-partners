/**
 * Represents a custom Dragonglass error. Simplifies error classification for logging purposes.
 */
export class CustomDragonglassError implements Error {
    public name: string;
    public message: string;
    public className: string;

    constructor(message: string, name?: string) {
        this.name = this.constructor.name;
        this.message = message;
        this.className = name || this.constructor.name;
    }
}
