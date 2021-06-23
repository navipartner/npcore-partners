export class ButtonClickHandler {
    /**
     * Decides whether this particular click handler should handle this particular click event.
     * Descending classes must implement this method.
     * 
     * @param {MenuButtonInfo} button Button that was clicked
     * @param {ButtonGrid} sender ButtonGrid to which the clicked button belongs.
     * @returns {Boolean} Boolean value indicating whether this click handler will handle this click event.
     */
    accepts(button, sender) {
        console.warn(`${this.constructor.name} does not implement the "accepts" method.`);
        return false;
    }
    
    onClick(button, sender) {
        console.warn(`${this.constructor.name} does not implement the "onClick" method.`);
    }
}
