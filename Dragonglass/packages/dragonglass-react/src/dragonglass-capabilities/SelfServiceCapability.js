import { Capability } from "./Capability";
import { Options } from "../classes/Options";
import { GlobalEventDispatcher, GLOBAL_EVENTS } from "dragonglass-core";
import { GlobalErrorDispatcher, GLOBAL_ERRORS } from "dragonglass-core";
import { Workflow } from "dragonglass-workflows/";
import { Popup } from "../dragonglass-popup/PopupHost";
import { InputType } from "../dragonglass-popup/enums/InputType";

export class SelfServiceCapability extends Capability {
    constructor() {
        super("selfService");
    }

    invokeAdmin() {
        const workflowToRun = Options.get("adminMenuWorkflow");

        if (workflowToRun) {
            let workflowParameters;
            try {
                workflowParameters = JSON.parse(Options.get("adminMenuWorkflow_parameters") || "{}");
            }
            catch {
                workflowParameters = {};
            }
            Workflow.run(workflowToRun, workflowParameters);
        }
        else
            Popup.error("No workflow has been configured to run as Self-Service POS Admin workflow.")
    }

    async showUnlockKeypad() {
        const pin = await Popup.numpad({ title: "Enter admin mode unlock PIN", caption: null, masked: true, inputType: InputType.TEXT, value: "" });
        if (!pin)
            return;

        this.interface.validateUnlockPin(pin);
    }

    onNegotiationSucceeded() {
        GlobalErrorDispatcher.addEventListener(GLOBAL_ERRORS.CRITICAL_ERROR, error => {
            this.interface.error(`${error}`);
        });

        GlobalErrorDispatcher.addEventListener(GLOBAL_ERRORS.UNHANDLED_AL_ERROR, error => {
            this.interface.unhandledALError(`${error}`);
        });

        GlobalErrorDispatcher.addEventListener(GLOBAL_ERRORS.SILENT_AL_ERROR, error => {
            this.interface.silentALError(`${error}`);
        });

        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.WORKFLOW_START, info => {
            this.interface.workflowStarted(info.workflow);
        });

        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.WORKFLOW_COMPLETE, info => {
            this.interface.workflowCompleted(info.workflow);
        });

        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.WORKFLOW_FAIL, info => {
            this.interface.workflowFailed(info.workflow, info.reason);
        });

        GlobalEventDispatcher.addEventListener(GLOBAL_EVENTS.BUTTON_CLICK, button => {
            this.interface.buttonClicked(button.caption);
        });

        this.interface.startSelfServiceSession();
    }

    reportUnhandledNavError(error) {
        if (!this.active)
            return;

        this.interface.unhandledNavError(error);
    }
};
