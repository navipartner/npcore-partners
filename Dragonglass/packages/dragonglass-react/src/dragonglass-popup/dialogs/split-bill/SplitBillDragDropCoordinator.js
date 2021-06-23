export class SplitBillDragDropCoordinator {
    constructor() {
        this._resetDrag();
        this._subscribers = [];
    }

    subscribe(handler) {
        if (typeof handler !== "function" || this._subscribers.includes(handler))
            return;

        this._subscribers.push(handler);
    }

    _resetDrag() {
        this._dragging = false;
        this._draggedItem = null;
        this._draggedFromBill = null;
    }

    startDrag(item, fromBill) {
        if (!item) {
            this._resetDrag();
            return;
        }

        this._dragging = true;
        this._draggedItem = item;
        this._draggedFromBill = fromBill;
    }

    endDrag() {
        this._resetDrag();
    }

    mouseUp(toBill) {
        if (!this._dragging || toBill === this._draggedFromBill || !this._subscribers.length)
            return;

        for (let subscriber of this._subscribers)
            subscriber(this._draggedItem, this._draggedFromBill, toBill);
    }

    isValidTarget(targetBill) {
        return this._dragging && (targetBill !== this._draggedFromBill);
    }
}
