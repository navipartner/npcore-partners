const TIMER_PROPERTY = "__timer_id__";

const handlers = {};
let nextTimerId = 0;
let timerInterval;
let timerIsRunning = false;

function startTimer() {
    if (timerIsRunning)
        return;

    const now = Date.now();
    const delay = Math.ceil(now / 1000) * 1000 - now;

    setTimeout(() => {
        timerIsRunning = true;
        timerInterval = setInterval(() => {
            const now = Date.now();
            const date = new Date(now);
            for (let name in handlers) {
                if (handlers.hasOwnProperty(name)) {
                    const handler = handlers[name];
                    if (now >= handler.nextTick) {
                        handler.nextTick = getNextTick(handler.interval, now + 1);
                        handler.component.timerUpdate(date);
                    }
                }
            }
        }, 1000);
    }, delay);
}

function stopTimer() {
    if (!timerIsRunning)
        return;

    clearInterval(timerInterval);
    timerIsRunning = false;
}

function getNextTick(interval, now) {
    const factor = interval * 1000;
    return Math.ceil((now || Date.now()) / factor) * factor;
}

export class Timer {
    static subscribe(component, intervalSeconds) {
        if (!component || typeof component !== "object" || typeof component.timerUpdate !== "function") {
            console.warn("WARNING: Attempting to subscribe an invalid component to the Timer class");
            return;
        }
        intervalSeconds = intervalSeconds || 60;    
        intervalSeconds = Math.ceil(intervalSeconds);
        const id = ++nextTimerId;
        handlers[id] = {
            interval: intervalSeconds,
            component: component,
            nextTick: getNextTick(intervalSeconds)
        };
        component[TIMER_PROPERTY] = id;

        startTimer();
    }

    static unsubscribe(component) {
        const id = component && component[TIMER_PROPERTY];
        if (!id) {
            console.warn(`WARNING: Invalid Timer subscription`);
            return;
        }

        let exists = false;
        delete handlers[id];
        delete component[TIMER_PROPERTY];
        for (let handler in handlers) {
            if (handlers.hasOwnProperty(handler)) {
                exists = true;
                break;
            }
        }
        if (!exists)
            stopTimer();
    }

    static get currentInterval() {
        return currentInterval;
    }

    static get timerIsRunning() {
        return timerIsRunning;
    }
}