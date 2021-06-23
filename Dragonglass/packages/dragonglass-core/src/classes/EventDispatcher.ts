import { InvalidEventError } from "../errors/InvalidEventError";
import { InvalidEventListenerError } from "../errors/InvalidEventListenerError";
import { IEventOwner } from "../interfaces/IEventOwner";
import { IListenerDelegate } from "../interfaces/IListenerDelegate";
import { EventsModule } from "../interfaces/EventsModule";
import { InvalidOperationError } from "../errors/InvalidOperationError";

/*
TODO: All event logging should be done through global events
There should be a log listener, which could be a console.log listener for pure browser, and capability Major Tom listener for Major Tom (or any other specific listener for iOS, Android, ...)
*/

export class EventDispatcher {
    _listeners: Record<string, IListenerDelegate[]>;
    _supportedEvents: string[];
    _eventsModules: { [key: string]: EventsModule } = {};

    /**
     * Instantiates a new EventDispatcher instance to handle the specified events.
     */
    constructor(supportedEvents: string[]) {
        this._listeners = {};
        this._supportedEvents = supportedEvents;
    }

    includeModuleEvents(module: EventsModule) {
        if (this._eventsModules[module.name] || Object.values(this._eventsModules).includes(module))
            throw new InvalidOperationError(`Module ${module.name} has already been included. You may include a module into event dispatcher only once`);

        this._eventsModules[module.name] = module;

        for (let event of module.events) {
            if (this._supportedEvents.includes(event))
                throw new InvalidOperationError(`Including module ${module.name} would result in duplicate event ${event}. Refactor your module to use unique event names.`);

            this._supportedEvents.push(event);
        }
    }

    excludeModuleEvents(name: string) {
        if (!this._eventsModules[name])
            throw new InvalidOperationError(`Module ${name} has not been included. You cannot exclude it.`);

        const module = this._eventsModules[name];
        delete this._eventsModules[name];

        for (let event of module.events) {
            if (this._listeners[event])
                delete this._listeners[event];
        }
    }

    /**
     * Registers an event listeners to be invoked when the indicated event occurs.
     * @param event Event to listen to
     * @param listener Listener delegate to invoke on event
     * @param owner Owner of the event (optional)
     */
    addEventListener(event: string, listener: IListenerDelegate, owner: IEventOwner | null = null): boolean {
        if (!this._supportedEvents.includes(event))
            throw new InvalidEventListenerError(event);

        if (!this._listeners[event])
            this._listeners[event] = [];

        if (this._listeners[event].includes(listener))
            return false;

        if (owner !== null)
            listener.__owner__ = owner;

        this._listeners[event].push(listener);

        return true;
    }

    removeEventListener(event: string, listener: IListenerDelegate): boolean {
        if (!this._supportedEvents.includes(event))
            throw new InvalidEventListenerError(event);

        if (!this._listeners[event])
            return false;

        if (!this._listeners[event].includes(listener))
            return false;

        this._listeners[event] = this._listeners[event].filter(l => l !== listener);

        return true;
    }

    removeEventListenersByOwner(owner: IEventOwner) {
        for (var event in this._listeners) {
            this._listeners[event] = this._listeners[event].filter(l => l.__owner__ !== owner);
        }
    }

    raise(event: string, ...args: any) {
        if (!this._supportedEvents.includes(event))
            throw new InvalidEventError(event)

        if (!this._listeners[event])
            return;

        for (var listener of this._listeners[event])
            listener.apply(event, args);
    }

    get supportedEvents(): string[] {
        return [...this._supportedEvents];
    }
};
