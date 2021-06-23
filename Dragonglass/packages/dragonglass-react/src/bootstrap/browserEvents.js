import { Ready } from "dragonglass-core";

function cancelWheel(e) {
    e.cancelBubble = true;
    return false;
}

function cancelBackspaceNavigation(e) {
    if (e.which === 8) {
        if (e.target.tagName !== "INPUT")
            e.preventDefault();
    }
}

function initialize() {
    document.addEventListener("mousewheel", cancelWheel, false);
    document.addEventListener("DOMMouseScroll", cancelWheel, false);
    document.addEventListener("keydown", cancelBackspaceNavigation, true);
}

export const initializeBrowserEvents = () => {
    Ready.instance.run(initialize);
};
