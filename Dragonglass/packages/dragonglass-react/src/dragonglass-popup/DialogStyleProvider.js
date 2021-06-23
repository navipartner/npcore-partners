/**
 * Represents a style provider that provides custom styles for dialogs.
 *
 * @export
 * @class DialogStyleProvider
 */
export class DialogStyleProvider {
    constructor(descriptor) {
        this.descriptor = typeof descriptor === "object" && descriptor ? descriptor : {};
    }

    getContainerStyle() {
        if (typeof this.descriptor.getContainerStyle === "function")
            return this.descriptor.getContainerStyle();

        if (typeof this.descriptor.containerStyle === "object")
            return this.descriptor.containerStyle;

        return null;
    }

    getBodyStyle() {
        if (typeof this.descriptor.getBodyStyle === "function")
            return this.descriptor.getBodyStyle();

        if (typeof this.descriptor.bodyStyle === "object")
            return this.descriptor.bodyStyle;

        return null;
    }

    getButtonsStyle() {
        if (typeof this.descriptor.getButtonsStyle === "function")
            return this.descriptor.getButtonsStyle();

        if (typeof this.descriptor.buttonsStyle === "object")
            return this.descriptor.buttonsStyle;

        return null;
    }
}
