import {
    DRAGONGLASS_OPTIONS_REGISTER_WORKFLOW,
    DRAGONGLASS_OPTIONS_STORE_ACTION_SEQUENCES
} from "./workflows-action-types";
import { WorkflowReduxState } from "./WorkflowReduxState";
import { createReducer } from "dragonglass-redux";
import { initialState } from "./workflows-initial-state";
import { RegisterWorkflowPayload } from "./RegisterWorkflowPayload";
import { StoreActionSequencesPayload } from "./StoreActionSequencesPayload";

export const reducer = createReducer<WorkflowReduxState>(initialState, {

    [DRAGONGLASS_OPTIONS_REGISTER_WORKFLOW]: (state: WorkflowReduxState, payload: RegisterWorkflowPayload) => {
        const result = { ...state };
        result.workflows = { ...state.workflows };
        result.workflows[payload.Workflow.Name] = payload;
        if (payload.Workflow && payload.Workflow.Content && payload.Workflow.Content.engineVersion)
            result.workflows[payload.Workflow.Name].engineVersion = payload.Workflow.Content.engineVersion;
        return result;
    },

    [DRAGONGLASS_OPTIONS_STORE_ACTION_SEQUENCES]: (state: WorkflowReduxState, payload: StoreActionSequencesPayload) => {
        const result = { ...state };
        result.sequences = { ...result.sequences, ...payload };
        return result;
    }

});
