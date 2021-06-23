import { Delegate_T } from "dragonglass-core";

/**
 * Allows awaiting for the entire C/AL call sequence to complete. When an event is raised in C/AL, the InvokeExtensibilityMethod callback
 * can be fired before the actual call stack has been completed (e.g. in 2017 and earlier, when a modal dialog is shown in C/AL). However,
 * an event promise can only be resolved once the entire call stack is completed. This class tracks the entire call sequence and makes sure
 * that the event promise is resolved only after the entire C/AL call stack completes.
 * @param {function} callback Function to be invoked once the entire C/AL call sequence is completed. This callback internally resolves the NAV event promise.
 */
export class WorkflowCallResponseAwaiter {
    private _callback: Delegate_T<any>;
    private _responseContent: any = null;
    private _callCompleted: boolean = false;
    private _signalReceived: boolean = false;

    constructor(callback: Delegate_T<any>) {
        this._callback = callback;
    }

    /**
     * This function makes sure that the entire C/AL call stack is fully processed and that the InvokeExtensibilityMethod callback
     * function have been both invoked and processed. Only after both are processed, this method invokes the tracked callback, which
     * resolves the NAV event promise.
     * @param {WorkflowTracker} tracker Represents the workflow tracker object that represents an individual workflow state
     */
    private process(): void {
        if (!this._callCompleted || !this._signalReceived)
            return;
        this._callback(this._responseContent);
    }

    /**
     * Invoked when the entire call sequence (C/AL OnAction call stack) has been completed. This is result of C/AL explicitly invoking the
     * "completeCall" front-end request.
     * This function invokes the "process" method of the WorkflowCallResponseAwaiter object to detect if the entire call stack has been
     * completed.
     * On 2017 and earlier, when there is a modal call in C/AL, this method is invoked after the "completeCall" method.
     * On 2018, this method is alwass invoked first.
     * @param {WorkflowTracker} tracker Represents the workflow tracker object that represents an individual workflow state
     */
    public respond(content: any): void {
        this._signalReceived = true;
        this._responseContent = content;
        this.process();
    }

    /**
     * Invoked from the InvokeExtensibilityMethod callback to indicate that the C/AL event invocation has completed. This does not
     * indicate that the entire call sequence (C/AL OnAction call stack) has been completed.
     * This function invokes the "process" method of the WorkflowCallResponseAwaiter object to detect if the entire call stack has been
     * completed.
     * On 2017 and earlier, when there is a modal call in C/AL, this method is invoked before the "respond" method.
     * On 2018, this method is always invoked last.
     */
    public completeCall(): void {
        this._callCompleted = true;
        this.process();
    }
}
