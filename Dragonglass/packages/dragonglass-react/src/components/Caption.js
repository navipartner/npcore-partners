import React from "react";
import LocalizedCaption from "./LocalizedCaption";
import DataBoundCaption from "./DataBoundCaption";
import { isDataBound } from "../classes/dataBindingEvaluation";
import sliceNonHtmlCaption from "./SliceNonHtmlCaption";

const Caption = (props) => {
  const { caption, dataSourceName } = props;

  if (dataSourceName && isDataBound(caption)) {
    return (
      <DataBoundCaption
        dataSourceName={dataSourceName}
        inline={true}
        caption={caption}
      />
    );
  }

  let content =
    typeof caption === "string"
      ? caption
      : `${caption === undefined ? "" : caption}`;

  if (content.startsWith("l$.")) {
    return <LocalizedCaption caption={content.substring(3)} />;
  }

  const slicedCaption = sliceNonHtmlCaption(content);

  return (
    <span
      title={content}
      dangerouslySetInnerHTML={{ __html: `${slicedCaption}` }}
    />
  );
};

export default Caption;
