import React from "react";
import Caption from "./Caption";
import { buildClass } from "../classes/functions";

const Label = (props) => {
  const { id, caption, className, style } = props;
  const additional = {};
  if (style) additional.style = style;

  return (
    <div className={buildClass("label", className)} id={id} {...additional}>
      <Caption caption={caption}></Caption>
    </div>
  );
};

export default Label;
