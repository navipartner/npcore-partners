import React, { Component } from "react";
import { bindComponentToDataSetState } from "../../redux/reducers/dataReducer";
import CartContentRow from "./CartContentRow";

class CartContent extends Component {
    render() {
        const { rows } = this.props.data;
        const { setup } = this.props;

        return (
            <>
                {
                    rows.filter(row => !row.pending).map(row => <CartContentRow key={row.position} actions={setup.actions} fields={setup.fields} dataSource={this.props.dataSource} row={row} />)
                }
            </>
        );
    }
}

export default bindComponentToDataSetState(CartContent);
