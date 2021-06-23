import { StateStore } from "dragonglass-redux";
import { updateNavEventQueue } from "../redux/nav-actions";
import { IEventInfo } from "./IEventInfo";

export class EventQueue {
    private _stateStore: StateStore;
    private _queue: IEventInfo[];

    constructor(stateStore: StateStore) {
        this._stateStore = stateStore;
        this._queue = [];
    }

    public push(eventInfo: IEventInfo): number {
        const result = this._queue.push(eventInfo);
        this._stateStore.dispatch(updateNavEventQueue(this._queue));
        return result;
    }

    public shift(): IEventInfo | undefined {
        const result = this._queue.shift();
        this._stateStore.dispatch(updateNavEventQueue(this._queue));
        return result;
    }

    public isEmpty(): boolean {
        return !this._queue.length;
    }

    public contentAsString(eventInfo: IEventInfo): string {
        return this
            ._queue
            .reduce(
                (content, info) => `${content}${content && ", "}${info.event.getLogName()} (${eventInfo.timestamp - info.timestamp}ms)`, "");
    }
}
