import React from "react";
import StatusBarSection from "./StatusBarSection";
import DataBoundCaption from "../DataBoundCaption";
import TimerCaption from "../TimerCaption";
import Caption from "../Caption";
import OptionCaption from "../OptionCaption";

const renderSection = (section, id, sectionId, dataSource) => {
    const style = { width: section.width };

    sectionId = `${id}-section${sectionId}`;
    dataSource = section.dataSource || dataSource;

    return (
        <StatusBarSection
            customClass={section.class}
            key={sectionId}
            id={section.id || sectionId}
            style={style}
            layout={section}
            dataSource={dataSource} />
    );
};

const getDataCaptionRenderer = (section, _, dataSource) =>
    <DataBoundCaption field={section.field} dataSourceName={section.dataSource || dataSource}></DataBoundCaption>;

const getLocalizedCaptionRenderer = (section) =>
    <Caption caption={section.caption}></Caption>;

const getOptionCaptionRenderer = section =>
    <OptionCaption option={section.option} />;

const components = {
    timer: section => <TimerCaption layout={section}></TimerCaption>
};

const getComponentRenderer = section =>
    components[section.component](section);

export const getRenderer = (layout) => {
    if (!layout)
        return () => { };

    if (layout.type === "group" || layout.sections)
        return populateSections;

    if (layout.component && typeof components[layout.component] === "function")
        return getComponentRenderer;

    if (layout.field)
        return getDataCaptionRenderer;

    if (layout.caption)
        return getLocalizedCaptionRenderer;

    if (layout.option)
        return getOptionCaptionRenderer;

    if (layout.id) {
        // TODO: handle different IDs (for now only "walkthrough")
        switch (layout.id) {
            case "walkthrough":
                break;
        }
        return () => { };
    }

    let logged = false;
    return () => {
        if (logged)
            return;
        console.warn(`WARNING: Invalid StatusBar renderer configuration: ${JSON.stringify(layout)}`);
    };
};

export const populateSections = (layout, id, dataSource) => {
    if (!layout.sections || !Array.isArray(layout.sections))
        return null;

    let sectionId = 0;
    return layout.sections.map(section => renderSection.call(this, section, id, ++sectionId, dataSource));
};
