import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { DataManager } from "../../classes/DataManager";
import { GlobalEventDispatcher, GLOBAL_EVENTS } from "dragonglass-core";
import { StateStore } from "../../redux/StateStore";

export class RefreshData extends FrontEndAsyncRequestHandler {
    handle(request) {
        DataManager.updateData(request.DataSets);
        const data = StateStore.getState().data;
        GlobalEventDispatcher.refreshData({ changed: Object.keys(request.DataSets), data: data.sets });
    }
}