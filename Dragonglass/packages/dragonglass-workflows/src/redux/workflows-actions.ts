import { createActionWithPayload } from "dragonglass-redux";
import { RegisterWorkflowPayload } from "./RegisterWorkflowPayload";
import { StoreActionSequencesPayload } from "./StoreActionSequencesPayload";
import { DRAGONGLASS_OPTIONS_REGISTER_WORKFLOW, DRAGONGLASS_OPTIONS_STORE_ACTION_SEQUENCES } from "./workflows-action-types";

// TODO: !! IMPORTANT !! Workflow redcer state should not belong to Options!! It should be in its own "workflows" state branch

export const registerWorkflow = createActionWithPayload<RegisterWorkflowPayload>(DRAGONGLASS_OPTIONS_REGISTER_WORKFLOW);
export const storeActionSequences = createActionWithPayload<StoreActionSequencesPayload>(DRAGONGLASS_OPTIONS_STORE_ACTION_SEQUENCES);
