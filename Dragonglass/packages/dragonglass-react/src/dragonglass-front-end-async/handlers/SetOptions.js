import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { setOptions } from "../../redux/actions/optionsActions";
import { GLOBAL_EVENTS, GlobalEventDispatcher } from "dragonglass-core";

export class SetOptions extends FrontEndAsyncRequestHandler {
    handle(request) {
        StateStore.dispatch(setOptions(request.Content));
        GlobalEventDispatcher.raise(GLOBAL_EVENTS.SET_OPTIONS, StateStore.getState().options);
    }
}
