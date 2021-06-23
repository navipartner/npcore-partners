import { DRAGONGLASS_LOCALIZE } from "./localizationActionTypes";

export const setLocalization = captions => {
    return {
        type: DRAGONGLASS_LOCALIZE,
        payload: captions
    };
}

