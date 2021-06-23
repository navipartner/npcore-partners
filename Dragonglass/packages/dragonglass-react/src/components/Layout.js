import React from "react";
import { buildClass } from "../classes/functions";

function getClassFromLayout(className, layout) {
  className = buildClass("container", className);
  layout && layout.flow && (className = `${className} flow-${layout.flow}`);
  layout.class && (className = `${className} ${layout.class}`);
  return className;
}

function mergeProps(obj, prop, add) {
  obj[prop] = { ...(obj[prop] || {}), ...add };
}

function translateLayoutProps(layout, style) {
  let props = { style: { ...(style || {}) } };
  layout.margin && mergeProps(props, "style", { margin: layout.margin });
  layout["margin-top"] &&
    mergeProps(props, "style", { marginTop: layout["margin-top"] });
  layout["margin-bottom"] &&
    mergeProps(props, "style", { marginBottom: layout["margin-bottom"] });
  layout["margin-left"] &&
    mergeProps(props, "style", { marginLeft: layout["margin-left"] });
  layout["margin-right"] &&
    mergeProps(props, "style", { marginRight: layout["margin-right"] });
  layout["weight"] &&
    mergeProps(props, "style", {
      flexGrow: layout["weight"],
      flexShrink: 0,
      flexBasis: layout["weight"] + "em",
    });

  if (layout.flow === "horizontal" || !layout.hasOwnProperty("flow")) {
    layout.alignV === "top"
      ? mergeProps(props, "style", { alignItems: "flex-start" })
      : layout.alignV === "bottom"
      ? mergeProps(props, "style", { alignItems: "flex-end" })
      : null;

    layout.alignH === "left"
      ? mergeProps(props, "style", { justifyContent: "flex-start" })
      : layout.alignH === "right"
      ? mergeProps(props, "style", { justifyContent: "flex-end" })
      : null;
  } else if (layout.flow === "vertical") {
    layout.alignV === "top"
      ? mergeProps(props, "style", { justifyContent: "flex-start" })
      : layout.alignV === "bottom"
      ? mergeProps(props, "style", { justifyContent: "flex-end" })
      : null;

    layout.alignH === "left"
      ? mergeProps(props, "style", { alignItems: "flex-start" })
      : layout.alignH === "right"
      ? mergeProps(props, "style", { alignItems: "flex-end" })
      : null;
  }

  (layout.hasOwnProperty("base") ||
    layout.hasOwnProperty("grow") ||
    layout.hasOwnProperty("shrink")) &&
    mergeProps(props, "style", {
      flexGrow: layout.hasOwnProperty("grow") ? layout.grow : 1,
      flexShrink: layout.hasOwnProperty("shrink") ? layout.shrink : 1,
      flexBasis: layout.hasOwnProperty("base") ? layout.base : "auto",
    });
  layout.width && mergeProps(props, "style", { width: layout.width });
  layout.height && mergeProps(props, "style", { height: layout.height });
  return props;
}

const Layout = (props) => {
  const { id, layout, className, style } = props;
  const attributes = {
    className: getClassFromLayout(className || "", layout),
    ...translateLayoutProps(layout, style),
  };
  id && (attributes.id = id);
  return layout["no-container-wrapper"] ? (
    <>{props.children}</>
  ) : (
    <div {...attributes}>{props.children}</div>
  );
};

export default Layout;
