import { ActionDescription } from "./ActionDescription";

export interface ActionWrapper {
    action: ActionDescription,
    context: any,
    metadata?: any,
    Content: {
        
    },
    plugins?: Array<string>
}
