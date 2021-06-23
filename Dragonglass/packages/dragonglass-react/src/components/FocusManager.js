const validTypes = ["text", "password", "number"];
const validEventPropTypes = ["number", "string", "boolean"];
const focusStack = [];
let suspended = false;

const cloneKeyboardEvent = original => {
    const init = {};
    for (let prop in original) {
        if (validEventPropTypes.includes(typeof original[prop]))
            init[prop] = original[prop];
    }
    delete init.cancelBubble;
    delete init.defaultPrevented;
    delete init.returnValue;

    const copy = new KeyboardEvent(original.type, init);
    return copy;
};

const sendEventToTarget = (event, target) => {
    const clone = cloneKeyboardEvent(event);
    target.focus();
    if (!target.dispatchEvent(clone))
        event.preventDefault();
    event.stopImmediatePropagation();
}

const handleKeyPress = event => {
    if (document.activeElement && (document.activeElement instanceof HTMLInputElement) || (suspended && !focusStack.length))
        return;

    if (focusStack.length) {
        sendEventToTarget(event, focusStack[focusStack.length - 1]);
        return;
    }

    const input = findAvailableInput();
    if (input)
        sendEventToTarget(event, input);
};

export const focusAvailableInput = () => {
    const input = findAvailableInput();
    if (input)
        input.focus();
}

export const findAvailableInput = () => {
    const inputs = document.getElementsByTagName("input");
    for (let input of inputs) {
        const rect = input.getBoundingClientRect();
        if (validTypes.includes(input.type) && rect.width > 16 && rect.height > 16 && rect.left > 0 && rect.top > 0) {
            return input;
        }
    }
};

const handleKeyDown = event => {
    if (!["Backspace"].includes(event.key))
        return;

    return handleKeyPress(event);
};

document.addEventListener("keypress", handleKeyPress);
document.addEventListener("keydown", handleKeyDown);

export const Focus = {
    require: control => {
        focusStack.push(control);
        control.focus();
    },

    release: control => {
        if (!focusStack.length)
            return;

        if (focusStack[focusStack.length - 1] === control) {
            focusStack.pop();
            return;
        }

        for (let i = 0; i < focusStack.length; i++) {
            if (focusStack[i] === control) {
                delete focusStack[i];
                return;
            }
        }
    },

    suspend: () => suspended = true,
    resume: () => suspended = false
};
