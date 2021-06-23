export class ButtonEnableProxy {
    constructor(enabled) {
        this._enabled = !!enabled;
    }

    getEnabled(refresh) {
        this._refresh = refresh;
        return this._enabled;
    }

    get enabled() {
        return this._enabled;
    }

    set enabled(enabled) {
        if (this._enabled === enabled)
            return;
        this._enabled = !!enabled;
        if (typeof this._refresh === "function")
            this._refresh();
    }
}