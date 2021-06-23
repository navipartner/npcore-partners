// Not using Symbol because this enum can be serialized in Redux
export const Enabled = {
    Yes: "Enabled.yes",
    Auto: "Enabled.auto",
    No: "Enabled.no",

    parse: {
        fromInt: number => {
            if (number >= 0 && number < keyOrdinals.length - 1)
                return Enabled[keyOrdinals[number]];
        }
    },
}

const keyOrdinals = Object.keys(Enabled);