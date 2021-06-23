import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { setFormatAction } from "../../redux/actions/formatActions";

export class SetFormat extends FrontEndAsyncRequestHandler {
    handle(request) {
        const format = {
            number: request.NumberFormat,
            date: request.DateFormat
        };

        StateStore.dispatch(setFormatAction(format));
    }
}
