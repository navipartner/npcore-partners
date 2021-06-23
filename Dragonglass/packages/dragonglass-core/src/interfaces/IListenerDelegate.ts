import { IEventOwner } from "./IEventOwner";

export interface IListenerDelegate {
    (...args: any[]): any;

    __owner__?: IEventOwner | null;
}
