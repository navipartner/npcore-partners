import { Delegate_T } from "dragonglass-core";
import { NAVEvent } from "./NAVEvent";

export interface IEventInfo {
    event: NAVEvent;
    payload: any;
    fulfill: Delegate_T<string>;
    timestamp: number;
};
