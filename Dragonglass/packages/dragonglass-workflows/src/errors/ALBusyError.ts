import { ALError } from "./ALError";

export class ALBusyError extends ALError {
    constructor() {
        super("Workflow AL Interface is already processing another workflow.respond() call. You must not call workflow.respond() before another call to workflow.respond() completes. Try awaiting on workflow.respond() or using workflow.respond().then(() => {}) syntax.");
    }
}