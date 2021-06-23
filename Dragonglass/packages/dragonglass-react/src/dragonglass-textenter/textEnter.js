import { StateStore } from "../redux/StateStore";
import { openTextEnter, closeTextEnter } from "../redux/actions/textEnterActions";
import { runWorkflow } from "dragonglass-workflows";

const MINIMUM_TOAST_SCREEN_TIME = 750;

const transcendenceImplicitControls = ["eanBox"];
const transcendenceImplicitControlToIdMap = {
    "eanBox": "EanBox"
};

let dispatchId = 0;

/**
 * Handles the textEnter event on Input component. It includes the necessary logic to decide when raising of a TextEnter
 * event in the back end is necessary.
 * The `this` context in the function always points to the instance of the Input component that raises the event.
 */
function textEnter() {
    const { layout } = this.props;
    const hostId = this.props.id;

    if (!this.value.trim())
        return;

    let { raiseTextEnterId, control, _key, ...rest } = layout;

    if (!raiseTextEnterId && control && transcendenceImplicitControls.includes(control)) {
        raiseTextEnterId = transcendenceImplicitControlToIdMap[control];
        const correctLayout = { ...rest, raiseTextEnterId: raiseTextEnterId };
        console.warn(`[TextEnter] Obsolete implicit transcendence-style control ${control}. Please use the raiseTextEnterId property on the layout object instead, like this: ${JSON.stringify(correctLayout)} `);
    }

    const entry = {
        text: this.value,
        id: ++dispatchId,
        timestamp: Date.now()
    };
    StateStore.dispatch(openTextEnter(entry, hostId));
    this._clear();

    const notifyEnd = () => {
        if (!elapsed || !responded)
            return;

        StateStore.dispatch(closeTextEnter(entry, hostId));
    };

    let elapsed = false;
    let responded = false;
    setTimeout(() => {
        elapsed = true;
        notifyEnd();
    }, MINIMUM_TOAST_SCREEN_TIME);

    const navContent = {
        _getInitialContext: () => ({
            id: raiseTextEnterId,
            value: entry.text,
            _replace_v1_method: true
        })
    };

    runWorkflow("textEnter", navContent).then(() => {
        responded = true;
        notifyEnd();
    });
}

export default textEnter;
