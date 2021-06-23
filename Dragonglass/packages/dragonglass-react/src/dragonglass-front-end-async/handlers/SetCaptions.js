import { FrontEndAsyncRequestHandler } from "dragonglass-front-end-async";
import { StateStore } from "../../redux/StateStore";
import { setLocalization } from "../../redux/actions/localizationActions";

export class SetCaptions extends FrontEndAsyncRequestHandler {
    handle(request) {
        const captions = request.Captions;
        captions.Actions = {};

        for (let c in captions) {
            if (captions.hasOwnProperty(c)) {
                let index = c.indexOf(".");
                if (index > 0) {
                    let action = c.substring(0, index), key = c.substring(index + 1);
                    captions.Actions[action] || (captions.Actions[action] = {});
                    captions.Actions[action][key] = captions[c];
                };
            };
        };

        StateStore.dispatch(setLocalization(captions));
    }
}