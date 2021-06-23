import { CustomDragonglassError } from "dragonglass-core";

export class WorkflowRuntimeError extends CustomDragonglassError {
    constructor(message: string) {
        super(message);
    }
}