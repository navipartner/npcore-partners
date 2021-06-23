const blobTransformers = {
  table: (component, blob) => ({
    ...blob,
    chairs: {
      ...blob.chairs,
      count: component.capacity || (blob.chairs && blob.chairs.count) || 0,
      max: Math.max((blob.chairs && blob.chairs.max) || 0, component.capacity || 0),
    },
    ...(component.color ? { color: component.color } : {}),
  }),
};

const transformBlob = (component) => {
  let blob = JSON.parse(component.blob || "{}");
  return typeof blobTransformers[component.type] === "function"
    ? blobTransformers[component.type](component, blob)
    : blob;
};

export const transformComponentFromBlob = (component) => ({
  id: component.id,
  caption: component.caption,
  type: component.type,
  ...transformBlob(component),
});

export const transformComponentToBlob = (component) => {
  const result = {};
  const { id, caption, type, location, ...blob } = component;

  result.id = id;
  result.caption = caption;
  result.type = type;
  result.locationId = location;
  result.blob = JSON.stringify(blob);

  return result;
};
