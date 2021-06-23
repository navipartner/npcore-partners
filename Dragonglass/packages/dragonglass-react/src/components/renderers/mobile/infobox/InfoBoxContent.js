import React, { useContext } from "react";
import { DataSourceContext } from "../../../../dragonglass-context";
import Caption from "../../../Caption";
import DataBoundCaption from "../../../DataBoundCaption";

const AlignedContent = ({ width, align, children, className }) => {
  let style = {
    width: width ? width : "100%",
    textAlign: align ? align : "inherit",
  };

  return (
    <div style={style} className={className}>
      {children}
    </div>
  );
};

export const InfoBoxContent = ({ caption, field, width, align }) => {
  if (!caption && !field) {
    return null;
  }

  const alignment = { align, width };

  if (caption && !field) {
    return (
      <AlignedContent {...alignment}>
        <Caption caption={caption} />
      </AlignedContent>
    );
  }

  if (field && !caption) {
    return (
      <AlignedContent {...alignment}>
        <DataBoundCaption
          dataSourceName={useContext(DataSourceContext)}
          field={field}
        />
      </AlignedContent>
    );
  }

  const content = (
    <>
      {" "}
      <InfoBoxContent align="left" caption={caption} />
      <InfoBoxContent align="right" field={field} />
    </>
  );

  return align ? (
    <AlignedContent className="aligned-content" {...alignment}>
      {content}
    </AlignedContent>
  ) : (
    content
  );
};
