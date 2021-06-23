import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { defineImageAction } from "../../redux/actions/imageActions";

export class SetImage extends FrontEndAsyncRequestHandler {
    handle(request) {
        const payload = { [request.Id]: request.Image };
        if (request.Id === "watermark" && request.Content.watermarkText) {
            payload.watermark = {
                type: "text",
                text: request.Content.watermarkText
            };
        }
        StateStore.dispatch(defineImageAction(payload));
    }
}
