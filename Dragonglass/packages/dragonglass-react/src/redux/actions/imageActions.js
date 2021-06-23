import { DRAGONGLASS_IMAGE_DEFINE } from "./imageActionTypes";

export const defineImageAction = image => ({
    type: DRAGONGLASS_IMAGE_DEFINE,
    payload: image
});
