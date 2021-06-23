import { GenericGridClickHandler } from "./GenericGridClickHandler";
import { NumpadButtonClickHandler } from "../button/NumpadButtonClickHandler";
import { NumpadSubmitButtonClickHandler } from "../button/NumpadSubmitButtonClickHandler";

export class NumpadClickHandler extends GenericGridClickHandler {
    constructor(enterValueFunction, submitFunction) {
        super();
        this.registerClickHandler(new NumpadButtonClickHandler(enterValueFunction));
        this.registerClickHandler(new NumpadSubmitButtonClickHandler(submitFunction));
    }
}