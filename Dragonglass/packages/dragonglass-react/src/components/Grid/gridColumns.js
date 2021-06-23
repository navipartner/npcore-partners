const specifiedColumns = (layout, dataSource) => {
  const result = [];
  for (let included of layout) {
    let match = dataSource.find((column) => {
      switch (typeof included) {
        case "number":
          return `${column.fieldId}` === `${included}`;
        case "object":
          return `${column.fieldId}` === `${included.fieldId}`;
      }
    });
    if (match) {
      let width =
        typeof included.width === "number" ? included.width : match.width;
      result.push({ ...match, width });
    }
  }

  return result;
};

const calculateWidths = (columns) => {
  const total = columns.reduce((prev, current) => prev + current.width || 0, 0);
  for (let column of columns) {
    column.width = (column.width / total) * 100;
  }
};

export const gridColumns = (layout, dataSource) => {
  let columns = Array.isArray(layout)
    ? specifiedColumns(layout, dataSource)
    : dataSource.filter((column) => column.visible);

  calculateWidths(columns);

  return columns;
};
