export function buildClass() {
    let args;
    switch (arguments.length) {
        case 0:
            return "";
        case 1:
            if (Array.isArray(arguments[0]))
                args = arguments[0];
            break;
        default:
            args = arguments;
    }

    const result = [];
    if (args) {
        for (let arg of args) {
            if (typeof arg === "object" || !arg)
                continue;
            if (typeof arg === "function")
                arg = arg();
            result.push(arg);
        }
    }
    return result.join(" ");
};

export function isMobile() {
    return window.top.innerWidth <= 736;
}
