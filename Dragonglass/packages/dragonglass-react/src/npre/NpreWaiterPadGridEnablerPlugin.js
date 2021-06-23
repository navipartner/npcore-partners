import { StateStore } from "../redux/StateStore";

export class NpreWaiterPadGridEnablerPlugin {
    constructor() {
        let state = StateStore.getState().restaurant;
        let activeWaiterPad = state && state.activeWaiterPad || null;

        this.boundGrids = [];
        this.enabled = !!activeWaiterPad;

        StateStore.subscribe(() => {
            let newState = StateStore.getState().restaurant;
            let newActiveWaiterPad = newState && newState.activeWaiterPad || null;
            if (activeWaiterPad !== newActiveWaiterPad) {
                activeWaiterPad = newActiveWaiterPad;
                let enabled = !!activeWaiterPad;
                if (enabled === this.enabled)
                    return;
                    
                this.enabled = enabled;
                if (this.boundGrids.length)
                    this.enabledChanged();
            }
        });
    }

    enabledChanged() {
        for (let grid of this.boundGrids) {
            grid.enabled = this.enabled;
        }
    }

    bindGrid(grid) {
        this.boundGrids.push(grid);
        if (grid.enabled !== this.enabled)
            grid.enabled = this.enabled;
    }

    unbindGrid(grid) {
        this.boundGrids = this.boundGrids.filter(g => g !== grid);
    }

    get gridEnabled() {
        return this.enabled;
    }
};
