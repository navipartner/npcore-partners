import { CustomDragonglassError } from "dragonglass-core"

export class InvalidRequestError extends CustomDragonglassError {
    constructor(reason: string) {
        super(`Invalid InvokeFrontEndAsync request received: ${reason}.`);
    }
}
