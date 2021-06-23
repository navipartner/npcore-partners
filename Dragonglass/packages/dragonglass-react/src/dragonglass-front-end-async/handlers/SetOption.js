import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { setOptions } from "../../redux/actions/optionsActions";
import { GLOBAL_EVENTS, GlobalEventDispatcher } from "dragonglass-core";

export class SetOption extends FrontEndAsyncRequestHandler {
    handle(request) {
        StateStore.dispatch(setOptions({ [request.Option]: request.Value }));
        GlobalEventDispatcher.raise(GLOBAL_EVENTS.SET_OPTIONS, StateStore.getState().options);
    }
}
