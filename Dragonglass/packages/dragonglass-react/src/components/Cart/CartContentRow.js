import React, { Component } from "react";
import PlusMinusEditor from "../PlusMinusEditor";
import { StateStore } from "../../redux/StateStore";
import { setSetCurrentPositionAction } from "../../redux/actions/dataActions";
import { Workflow } from "dragonglass-workflows";

const getRowFunctions = props => {
    const { actions } = props;
    if (!actions)
        return { readOnly: true };

    const { row, dataSource } = props;
    var functions = {};
    if (actions) {
        if (actions.delete) {
            functions.withDelete = true;
            functions.delete = () => {
                StateStore.dispatch(setSetCurrentPositionAction(dataSource.id, row.position));
                Workflow.run(actions.delete);
            };
        }
        if (actions.increase) {
            functions.updater = quantity => {
                StateStore.dispatch(setSetCurrentPositionAction(dataSource.id, row.position));
                Workflow.run(actions.increase, { parameters: { increaseBy: quantity } });
            };
        } else {
            functions.readOnly = true;
        }
    }
    return functions;
};

export default class CartContentRow extends Component {
    render() {
        const { row, fields } = this.props;

        var functions = getRowFunctions(this.props);

        return (
            <div className="cart-view__content__row">
                <PlusMinusEditor
                    passive={true}
                    minValue={1}
                    caption={row.fields[fields.caption]}
                    value={row.fields[fields.quantity]}
                    {...functions}
                />
            </div>
        );
    }
}
