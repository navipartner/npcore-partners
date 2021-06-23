import { ActionStepDescription } from "./ActionStepDescription";

/**
 * Represents a worfklow as described in the back-end action codeunit. This is a JSON-serialized workflow representation
 * as passed from the back end to Dragonglass.
 */
export interface ActionDescription {
    Workflow: {
        Name: string;
        Steps: ActionStepDescription[];
        Content: {
            engineVersion?: string;
        },
    },
    Content: {
        requirePosUnitType: any
    },
    Parameters: any[],
}
