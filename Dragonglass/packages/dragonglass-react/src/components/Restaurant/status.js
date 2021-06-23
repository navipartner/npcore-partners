export const getStatusColorAndIcon = status => {
    if (!status || typeof status !== "object")
        return null;

    const result = { id: status.id };
    if (status.color)
        result.color = `#${status.color}`;
    if (status.icon)
        result.icon = status.icon;

    return result;
};
