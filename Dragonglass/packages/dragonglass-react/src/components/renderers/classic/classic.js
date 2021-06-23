import React from "react";
import Layout from "../../Layout";
import renderControl from "./renderControl";

export const Classic = ({ tag, layout }) => {
    return (
        <Layout id={`view-${tag}`} className={`view ${tag}`} layout={layout}>
            {renderControl(layout)}
        </Layout>
    );
}
