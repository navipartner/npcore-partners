import { CustomDragonglassError } from "dragonglass-core";

export class ParameterAccessViolationError extends CustomDragonglassError {
    constructor(parameter: string) {
        super(`Attempting to set value of "${parameter}" parameter. Parameters are read-only.`);
    }
}