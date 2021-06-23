import { NAVEvent } from "../../nav/NAVEvent";

/**
 * Represents a NAV event that's being processed by the back end
 */
export interface NAVEventInfo {
    /**
     * Unique invocation ID of the event that's used to identify the event throughout the process
     */
    invocationId: number;

    /**
     * Name of the event
     */
    name: string;

    /**
     * NAV Event object that will handle the event. This info is not serializable.
     */
    event: NAVEvent,

    /**
     * Status of the event, can have any of the status constants.
     * Note to maintainers: this must be not be Symbol because it's not serializable
     */
    status?: string;

    /**
     * Error message of the error that occurred during processing.
     */
    error?: string;
};
