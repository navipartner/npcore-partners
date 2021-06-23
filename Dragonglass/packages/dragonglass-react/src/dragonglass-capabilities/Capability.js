export const CapabilitySupportedState = {
    NOT_SUPPORTED: Symbol(),
    PENDING: Symbol(),
    SUPPORTED: Symbol()
};

export class Capability {
    constructor(name) {
        this.supportedState = CapabilitySupportedState.NOT_SUPPORTED;
        if (!window.top.npDragonglass || !window.top.npDragonglass[name] || typeof window.top.npDragonglass[name].negotiate !== "function")
            return;

        this._negotiationCompletedMethods = {
            [CapabilitySupportedState.NOT_SUPPORTED]: () => this.onNegotiationFailed(),
            [CapabilitySupportedState.SUPPORTED]: () => this.onNegotiationSucceeded()
        };

        this.interface = window.top.npDragonglass[name];
        this._pendingCalls = [];
        this._initialize();
    }

    async _initialize() {
        this.supportedState = CapabilitySupportedState.PENDING;
        this.supportedState = await this.interface.negotiate()
            ? CapabilitySupportedState.SUPPORTED
            : CapabilitySupportedState.NOT_SUPPORTED;

        this._negotiationCompletedMethods[this.supportedState]();

        if (this.supportedState === CapabilitySupportedState.SUPPORTED)
            this.interface.implement(this);

        for (let pending of this._pendingCalls)
            pending(this.supportedState);

        this._pendingCalls = [];
    }

    get active() {
        return this.supportedState === CapabilitySupportedState.SUPPORTED;
    }

    ready() {
        return new Promise(fulfill => {
            if (this.supportedState == CapabilitySupportedState.PENDING) {
                this._pendingCalls.push(fulfill);
                return;
            }

            fulfill(this.supportedState);
        });
    }

    onNegotiationSucceeded() {
        // Override in inheriting classes if any logic is needed when negotiation succeeds and capability is deemed supported
    }

    onNegotiationFailed() {
        // Override in inheriting classes if any logic is needed when negotiation fails and capability is deemed unsupported
    }
}
