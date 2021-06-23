//const  = /(.*?)\((\d+)\)$/;
const reCaption = /(.*?)(\d+)$/;
const reId = /(.*?)(\d+)$/;

const padZero = (num, length) => {
    let output = num.toString();
    while (output.length < length)
        output = "0" + output;
    return output;
}

export const seatingTypeTitle = type => type.charAt(0).toUpperCase() + type.substring(1);

export const seatingGetNextId = (components, id, type) => {
    const matchId = reId.exec(id);
    id = (matchId ? matchId[1] : id).trim();
    const matching = components.filter(component => component.type === type && component.id.startsWith(id));
    if (matching.length === 0)
        return `${type.toUpperCase()}-1`;

    let longFirst = id;
    let maxLen = 0;
    let maxId = 0;
    for (let comp of matching) {
        let match = reId.exec(comp.id);
        if (match) {
            if (match[1].length > longFirst.length)
                longFirst = match[1];
            if (match[2].length > maxLen)
                maxLen = match[2].length;

            let id = parseInt(match[2]);
            if (!isNaN(id) && id > maxId)
                maxId = id;
        }
    }

    if (!longFirst.trim())
        longFirst = type.toUpperCase();
    return longFirst + padZero(maxId + 1, maxLen);
};

export const seatingGetNextCaption = (components, caption) => {
    const matchCaption = reCaption.exec(caption);
    caption = (matchCaption ? matchCaption[1] : caption).trim();

    let maxId = 1;
    let hasMatch = false;
    for (let comp of components) {
        let match = reCaption.exec(comp.caption);
        if (match) {
            const id = parseInt(match[2]);
            if (!isNaN(id) && id >= maxId && match[1].trim().toUpperCase() === caption.toUpperCase()) {
                maxId = id;
                hasMatch = true;
            }
        } else {
            if (comp.caption.trim() === caption)
                hasMatch = true;
        }
    }
    return `${caption}${hasMatch ? ` ${maxId + 1}` : ""}`;
}
