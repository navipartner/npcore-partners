import { IFrontEndAsyncRequest } from "dragonglass-front-end-async";

export interface WorkflowCompletedAsyncRequest extends IFrontEndAsyncRequest {
    WorkflowId: number;
    ActionId: number;
    Success: boolean;
    ThrowError: boolean;
    ErrorMessage: string;
}