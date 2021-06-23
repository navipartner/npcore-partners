import { InvalidOperationError, ITimeoutHandler, LocalizationHandler, ErrorReporter } from "dragonglass-core";
import { FrontEndAsyncInterface } from "dragonglass-front-end-async";
import { WorkflowCallCompleted } from "./WorkflowCallCompleted";
import { IHardwareConnector } from "../interfaces/IHardwareConnector";
import { reducer } from "../redux/workflows-reducer";
import { ConfigureReusableWorkflow } from "../front-end-async-handlers/ConfigureReusableWorkflow";
import { RunWorkflow } from "../front-end-async-handlers/RunWorkflow";
import { ConfigureActionSequences } from "../front-end-async-handlers/ConfigureActionSequences";
import { ITranscendence } from "dragonglass-transcendence";
import { KnownWorkflows } from "./WorkflowOptionMapper";
import { StateStore } from "dragonglass-redux";
import { WorkflowReduxWorkflowState } from "../redux/WorkflowReduxState";

export class WorkflowManager {
    private static _transcendence: ITranscendence;
    private static _initialized: boolean;
    private static _stateStore: StateStore;
    private static _errorReporter: ErrorReporter;
    private static _timeoutHandler: ITimeoutHandler;
    private static _localization: LocalizationHandler;
    private static _createPopupCoordinator: Function;
    private static _hardwareConnector: IHardwareConnector;

    private static _getInvalidMethodAccessErrorMessage(method: string): string {
        return `An attempt was made to access ${method} member of a WorkflowManager that wasn't initialized. Initialize WorkflowManager first.`;
    }

    static get transcendence() {
        if (!this._initialized)
            throw new InvalidOperationError(this._getInvalidMethodAccessErrorMessage("transcendence"));

        return this._transcendence;
    }

    static get stateStore() {
        if (!this._initialized)
            throw new InvalidOperationError(this._getInvalidMethodAccessErrorMessage("stateStore"));

        return this._stateStore;
    }

    static get errorReporter() {
        if (!this._initialized)
            throw new InvalidOperationError(this._getInvalidMethodAccessErrorMessage("errorReporter"));

        return this._errorReporter;
    }

    static get timeoutHandler() {
        if (!this._initialized)
            throw new InvalidOperationError(this._getInvalidMethodAccessErrorMessage("timeoutHandler"));

        return this._timeoutHandler;
    }

    static getSequencesForWorkflow(name: string): any {
        if (!this._initialized)
            throw new InvalidOperationError(this._getInvalidMethodAccessErrorMessage("getSequencesForWorkflow"));

        const state = this._stateStore.getState<WorkflowReduxWorkflowState>();
        const seq = state.workflows.sequences;
        return seq[name] || {};
    }

    static getOption(name: string): any {
        if (!this._initialized)
            throw new InvalidOperationError(this._getInvalidMethodAccessErrorMessage("getOption"));

        const state = this._stateStore.getState<any>().options;
        return state[name];
    }

    static get localization(): LocalizationHandler {
        if (!this._initialized)
            throw new InvalidOperationError(this._getInvalidMethodAccessErrorMessage("localization"));

        return this._localization;
    }

    static get hardwareConnector(): IHardwareConnector {
        if (!this._initialized)
            throw new InvalidOperationError(this._getInvalidMethodAccessErrorMessage("hardwareConnector"));

        return this._hardwareConnector;
    }

    static createPopupCoordinator(coordinator: any) {
        if (!this._initialized)
            throw new InvalidOperationError(this._getInvalidMethodAccessErrorMessage("createPopupCoordinator"));

        return this._createPopupCoordinator(coordinator);
    }

    static initialize(transcendence: ITranscendence, stateStore: StateStore, errorReporter: ErrorReporter, createPopupCoordinator: Function, timeout: ITimeoutHandler, localization: LocalizationHandler, hardwareConnector: IHardwareConnector) {
        if (this._initialized)
            throw new InvalidOperationError("An attempt was made to re-initialize WorkflowManager. You may initialize it only once.");

        this._initialized = true;
        this._transcendence = transcendence;
        this._stateStore = stateStore;
        this._errorReporter = errorReporter;
        this._timeoutHandler = timeout;
        this._localization = localization;
        this._createPopupCoordinator = createPopupCoordinator;
        this._hardwareConnector = hardwareConnector;

        KnownWorkflows.initialize(stateStore);
        stateStore.injectReducer("workflows", reducer);
        FrontEndAsyncInterface.register(new WorkflowCallCompleted(), "WorkflowCallCompleted");
        FrontEndAsyncInterface.register(new RunWorkflow(), "RunWorkflow");
        FrontEndAsyncInterface.register(new ConfigureReusableWorkflow(), "ConfigureReusableWorkflow");
        FrontEndAsyncInterface.register(new ConfigureActionSequences(stateStore), "ConfigureActionSequences");
    }
}
