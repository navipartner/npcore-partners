import React from "react";
import { InfoBoxContent } from "./InfoBoxContent";

const Row = ({ children }) => <div className="infobox__row">{children}</div>;

const InfoBoxArray = ({ content }) => {
  return (
    <Row>
      {content.map(({ caption, field, width, align }, index) => (
        <InfoBoxContent key={index} {...{ caption, field, width, align }} />
      ))}
    </Row>
  );
};

const InfoBoxSeparator = ({ width }) => {
  return <div className="infobox__separator" {...width} />;
};

/**
 * Renders an entry in the top-level infobox content array. It makes a decision on what that entry is, and then renders
 * the corresponding entry object (array, content, spacer, or separator).
 *
 * @param {Object} props Properties
 */
export const InfoBoxRow = ({ row }) => {
  // Case 1: Array
  if (Array.isArray(row)) {
    return <InfoBoxArray content={row} />;
  }

  const { caption, field, align, separator, width } = row;

  // Case 2: Spacer, renders as an empty row of 0.5em height
  if (!caption && !field && !separator) {
    return <div className="infobox__spacer" />;
  }

  // Case 3: Separator, renders as a line in the middle of a row of 0.5em height
  if (separator) {
    return (
      <Row>
        <InfoBoxSeparator {...width} />
      </Row>
    );
  }

  // Case 4: Content
  return (
    <Row>
      <InfoBoxContent {...{ caption, field, width, align }} />
    </Row>
  );
};
