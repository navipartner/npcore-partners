import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { storeActionSequences } from "./../redux/workflows-actions";
import { StateStore } from "dragonglass-redux";

export class ConfigureActionSequences extends FrontEndAsyncRequestHandler {
    private _store: StateStore;

    constructor(store: StateStore) {
        super();
        this._store = store;
    }

    handle(request: any) {
        if (!request.Content || !request.Content.sequences)
            return;

        const sequences: any = {};
        for (let entry of request.Content.sequences) {
            let sequence = sequences[entry.referenceAction] = sequences[entry.referenceAction] || {};
            let ref = sequence[entry.referenceType] = sequence[entry.referenceType] || [];
            ref.push({
                action: entry.action,
                priority: entry.priority
            });
        }

        this._store.dispatch(storeActionSequences(sequences));
    }
}
