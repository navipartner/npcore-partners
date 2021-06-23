import { CustomDragonglassError } from "dragonglass-core";

export class AlreadyRegisteredError extends CustomDragonglassError {
    constructor(name: string) {
        super(`FrontEndAsync handler named "${name}" has already been registered.`);
    }
}
