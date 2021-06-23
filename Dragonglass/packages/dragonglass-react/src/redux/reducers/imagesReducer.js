import { createReducer } from "dragonglass-redux";
import { bindToMap } from "../reduxHelper";
import initialState from "../initialState.js";
import {
    DRAGONGLASS_IMAGE_DEFINE
} from "../actions/imageActionTypes.js";

const images = createReducer(initialState.images, {
    [DRAGONGLASS_IMAGE_DEFINE]: (state, payload) => {
        let equal = true;
        for (let key in payload) {
            if (payload.hasOwnProperty(key)) {
                if (!state[key] || state[key] !== payload[key]) {
                    equal = false;
                    break;
                }
            }
        }
        if (equal)
            return state;

        return { ...state, ...payload };
    }
});

export default images;

const imageMap = {
    state: (_, ownProps) =>
        state => {
            const { images } = state, { imageId } = ownProps;
            return (
                {
                    src: images.hasOwnProperty(imageId)
                        ? images[imageId]
                        : ownProps.hasOwnProperty("src")
                            ? ownProps.src
                            : ""
                }
            );
        },
    enhancer: {
        areStatesEqual: (next, prev) => next.images === prev.images
    }
};

const watermarkMap = {
    state: state => ({ watermark: state.images.watermark }),
    enhancer: {
        areStatesEqual: (next, prev) => next.images.watermark === prev.images.watermark
    }
};

export const bindComponentToImageSrcState = component => bindToMap(component, imageMap);
export const bindComponentToWatermarkState = component => bindToMap(component, watermarkMap);