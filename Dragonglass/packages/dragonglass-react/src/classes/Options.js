import { StateStore } from "../redux/StateStore";

export const Options = {
    get: key => StateStore.getState().options[key]
};
