// TODO: unit tests needed!

import { IListenerDelegate } from "dragonglass-core";
import { WorkflowManager } from "./WorkflowManager";
import { Require } from "dragonglass-front-end-async";
import {
    IDataStateSet,
    IDataStateRow,
    IDataState
} from "dragonglass-redux";

export const RUNTIME_DISPOSE_TOKEN = Symbol();

export class WorkflowRuntimeCoordinator {
    /**
     * Disposes of the current runtime coordinator at the end of execution of a workflow. This cleans up any global state that may have been modified by the runtime.
     * (for now, it's only the timeout state)
     *
     * @param {Symbol} disposeToken A control variable that should be used to let this instance know that the __dispose__ code is valid. This prevents curious wannabe hackers writing workflow code to dispose of runtime just to see what happens.
     * @returns
     * @memberof WorkflowRuntimeCoordinator
     */
    __dispose__(disposeToken: Symbol) {
        if (disposeToken !== RUNTIME_DISPOSE_TOKEN)
            return;

        WorkflowManager.timeoutHandler.eventDispatcher.removeEventListenersByOwner(this);
        this.resumeTimeout();
    }

    suspendTimeout(): boolean {
        return WorkflowManager.timeoutHandler.suspend();
    }

    resumeTimeout(): boolean {
        return WorkflowManager.timeoutHandler.resume();
    }

    addEventListener(event: string, listener: IListenerDelegate): void {
        WorkflowManager.timeoutHandler.eventDispatcher.addEventListener(event, listener, this);
    }

    removeEventListener(event: string, listener: IListenerDelegate): void {
        WorkflowManager.timeoutHandler.eventDispatcher.removeEventListener(event, listener);
    }

    async retrieveImage(code: string): Promise<string> {
        return await Require.requireResource("image", { code });
    }

    get supportedEvents(): string[] {
        return WorkflowManager.timeoutHandler.eventDispatcher.supportedEvents;
    }

    get timeoutSuspended(): boolean {
        return WorkflowManager.timeoutHandler.isSuspended();
    }

    get timeoutDialogShown(): boolean {
        return WorkflowManager.timeoutHandler.isDialogShown();
    }

    get timeoutActive(): boolean {
        return WorkflowManager.timeoutHandler.isTimeoutActive();
    }

    getData(name: string): IDataStateSet {
        const { data } = WorkflowManager.stateStore.getState<IDataState>(), result: IDataStateSet = [] as unknown as IDataStateSet;

        if (data && data.sets && data.sets[name]) {
            const set = data.sets[name];
            result._current = null;
            result._count = 0;
            if (set.rows.length) {
                let currentPosition = set.currentPosition;
                const lastValidPosition = set.lastValidPosition;
                if (lastValidPosition && lastValidPosition !== currentPosition)
                    currentPosition = lastValidPosition;

                for (let row of set.rows) {
                    let rowCopy: IDataStateRow = { ...row.fields };
                    if (row.pending)
                        continue;

                    rowCopy._position = row.position;
                    rowCopy._current = row.position === currentPosition;
                    if (rowCopy._current)
                        result._current = rowCopy;

                    if (row.deleted)
                        rowCopy._deleted = true;
                    else
                        result._count++;

                    result.push(rowCopy);
                }
            }
        } else {
            result._invalid = true;
        }

        return result;
    }
};
