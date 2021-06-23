import { DataType, FormatAs } from "../../enums/DataType";

// This enum is serializable in Redux state, therefore not using Symbol
export const InputType = {
    DECIMAL: "InputType.DECIMAL",
    INTEGER: "InputType.INTEGER",
    DATE: "InputType.DATE",
    TEXT: "InputType.TEXT"
};

InputType.behavior = {
    [InputType.DECIMAL]: {
        calculate: val => DataType.behavior[DataType.DECIMAL].calculate(val),
        format: val => FormatAs.decimal(val),
        parse: val => typeof val === "number"
            ? val
            : DataType.behavior[DataType.DECIMAL].parse(val)
    },
    [InputType.INTEGER]: {
        calculate: val => DataType.behavior[DataType.INTEGER].calculate(val),
        format: val => FormatAs.integer(val),
        parse: val => typeof val === "number"
            ? Math.round(val)
            : DataType.behavior[DataType.INTEGER].parse(val)
    },
    [InputType.DATE]: {
        calculate: val => DataType.behavior[DataType.DATETIME].calculate(val),
        format: val => FormatAs.dateTime(vale),
        parse: val => val instanceof Date
            ? val
            : DataType.behavior[DataType.DATETIME].parse(val)
    },
    [InputType.TEXT]: {
        calculate: val => val,
        format: val => val,
        parse: val => val
    }
};

// TODO: Fix this mess... we only need one type, not two: either InputType or DataType should remain
export const dataTypeToInputType = dataType => {
    switch (dataType) {
        case DataType.DECIMAL:
            return InputType.DECIMAL;
        case DataType.INTEGER:
            return InputType.INTEGER;
        case DataType.DATE:
        case DataType.DATETIME:
            return InputType.DATE;
        case DataType.STRING:
            return InputType.TEXT;
    }
};

export const inputTypeToDataType = inputType => {
    switch (inputType) {
        case InputType.DECIMAL:
            return DataType.DECIMAL;
        case InputType.INTEGER:
            return DataType.INTEGER;
        case InputType.DATE:
            return DataType.DATETIME;
        case InputType.TEXT:
            return DataType.STRING;
    }
};
