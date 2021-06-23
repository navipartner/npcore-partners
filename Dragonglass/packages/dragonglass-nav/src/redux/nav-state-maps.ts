import { ReduxStateMapWithEnhancer } from "dragonglass-redux";
import { BoundNAVEventsActiveState } from "./interfaces/BoundNAVEventsActiveState";
import { BoundNAVEventsErrorState } from "./interfaces/BoundNAVEventsErrorState";
import { BoundNAVEventsQueueState } from "./interfaces/BoundNAVEventsQueueState";
import { NAVEventsRootState } from "./interfaces/NAVEventsRootState";

const areStatesEqual = (next: NAVEventsRootState, prev: NAVEventsRootState) => next === prev && next.navEvents === prev.navEvents;

export const NAVEventsQueueMap: ReduxStateMapWithEnhancer<NAVEventsRootState, BoundNAVEventsQueueState> = {
    state: state => {
        const { navEvents } = state;
        return { eventsQueue: navEvents.queue };
    },
    enhancer: {
        areStatesEqual: (next, prev) => areStatesEqual(next, prev) && next.navEvents.queue === prev.navEvents.queue
    }
};

export const NAVEventsActiveMap: ReduxStateMapWithEnhancer<NAVEventsRootState, BoundNAVEventsActiveState> = {
    state: state => {
        const { navEvents } = state;
        return { activeEvents: navEvents.active };
    },
    enhancer: {
        areStatesEqual: (next, prev) => areStatesEqual(next, prev) && next.navEvents.active === prev.navEvents.active
    }
};


export const NAVEventsErrorMap: ReduxStateMapWithEnhancer<NAVEventsRootState, BoundNAVEventsErrorState> = {
    state: state => {
        const { navEvents } = state;
        return { errorEvents: navEvents.errors };
    },
    enhancer: {
        areStatesEqual: (next, prev) => areStatesEqual(next, prev) && next.navEvents.errors === prev.navEvents.errors
    }
};
