import { CurrentFormat } from "../components/FormatManager";
import numeral from "numeral";

const currentRowFunc = (set, row) => field => {
    if (set.current) {
        return set.current.fields[field] || "";
    }

    if (row) {
        return row.fields[field] || "";
    }

    return "";
};

const sumFunc = set => (field, predicate, expectedValue) => {
    let total = 0;
    for (let row of set.rows.filter(row => !row.pending)) {
        set.current = row;

        if (typeof predicate === "function" && !predicate(row.fields))
            continue;

        if (typeof predicate === "number" && typeof expectedValue !== "undefined") {
            let compareToValue = row.fields[predicate];
            if (compareToValue !== expectedValue)
                continue;
        }

        let value = Number.parseFloat(row.fields[field]) || 0;
        total = total + value;
    }
    set.current = null;
    return total;
};

const format = (number, format) => {
    if (typeof number !== "number")
        return number;

    if (!format)
        return CurrentFormat.formatDecimal(number);

    return numeral(number).format(format);
};

const replace = (row, set, field, caption) => {
    const match = field.match(/\{(?<binding>.+)?\}/);
    let forced = false;
    let fieldOnly = true;
    if (match) {
        forced = true;
        field = match.groups.binding;
    }

    const parsed = parseInt(field);
    if (isNaN(parsed))
        fieldOnly = false;

    if (fieldOnly) {
        if (!row || !row.fields)
            return "";

        if (typeof row.fields[field] !== "undefined")
            return row.fields[field];

        console.warn(`Invalid caption binding: field ${field} is unknown`);
        return "";
    }

    if (!row && !forced)
        return "";

    if (row && row.fields && typeof row.fields[field] !== "undefined")
        return row.fields[field]

    try {
        const tempSet = {
            rows: [...set.rows],
            current: null
        };
        const func = new Function("global", `with (global) { return ${field}; }`);
        const global = {
            sum: sumFunc(tempSet),
            format,
            currentRow: currentRowFunc(tempSet, row)
        };
        return func(globalProxy(global));
    }
    catch (e) {
        console.warn(`An error occurred while evaluating "${caption}": ${e}`);
        return "";
    }
};

const globalProxy = global => new Proxy(
    global,
    {
        has: () => true,
        get: (target, key) => key === Symbol.unscopables ? undefined : target[key]
    }
);

export function isDataBound(caption) {
    return /\{\{(.*?)?\}\}/.test(caption);
}

export function replaceBindings(caption, row, set) {
    return caption.replaceAll(/\{\{(.*?)?\}\}/g,
        (_, field) => replace(row, set, field.trim(), caption));
}

