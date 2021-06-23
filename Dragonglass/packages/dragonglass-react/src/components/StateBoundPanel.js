import React, { Component } from "react";
import Layout from "./Layout";
import { buildClass } from "../classes/functions";
import { bindToStateDynamic } from "../redux/reduxHelper";

class StateBoundPanel extends Component {
    shouldComponentUpdate(nextProps) {
        return nextProps.boundState.bound !== this.props.boundState.bound || nextProps.boundState.state !== this.props.boundState.state;
    }

    render() {
        const { id, children, className, layout, boundState } = this.props;
        if (boundState.bound === true && !boundState.state || !boundState.bound)
            return null;

        return (
            <Layout className={buildClass("", className)} id={id} layout={layout || {}}>
                {children}
            </Layout>
        )
    }
}

export default bindToStateDynamic(StateBoundPanel);
