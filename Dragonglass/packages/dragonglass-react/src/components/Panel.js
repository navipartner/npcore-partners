import React from "react";
import Layout from "./Layout";
import { buildClass } from "../classes/functions";

const Panel = (props) => {
    const { id, children, className, layout } = props;
    return (
        <Layout className={buildClass("", className)} id={id} layout={layout || {}}>
            {children}
        </Layout>
    )
}

export default Panel;