import React from "react";

const Icon = (props) => {
  const { id, className, style } = props;
  const additional = {};
  if (style) additional.style = style;

  return <span className={className} id={id} {...additional}></span>;
};

export default Icon;
