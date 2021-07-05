import { TextAlign } from "../dragonglass-popup/enums/TextAlign";
import { localize } from "../components/LocalizationManager";
import { CurrentFormat } from "../components/FormatManager";
import numeral from "numeral";
import { Debug } from "dragonglass-core";

const REGEX_CALCULATIONS = /[\(\)\+\-\*\/x]/;
const debug = new Debug("Formatting");

export const DataType = {
    UNDEFINED: 0,
    BOOLEAN: 1,
    INTEGER: 2,
    DATETIME: 3,
    DECIMAL: 4,
    STRING: 5,

    behavior: {
        0: { // Undefined
            textAlign: TextAlign.NONE,
            format: val => val,
            parse: val => val,
            calculate: val => val,
            isCalculated: () => false,
            isValidValue: () => true,
            isValidDuringEntry: () => true
        },
        1: { // Boolean
            textAlign: TextAlign.CENTER,
            format: val => val ? localize("Global_Yes") : localize("Global_No"),
            parse: val => typeof val === "string"
                ? (localize("Global_Yes").toUpperCase() === val.toUpperCase() || val.toUpperCase() === "TRUE"
                    ? true
                    : (localize("Global_No").toUpperCase() === val.toUpperCase() || val.toUpperCase() === "FALSE"
                        ? false
                        : !!val))
                : !!val,
            calculate: val => !!val,
            isCalculated: () => false,
            isValidValue: () => true,
            isValidDuringEntry: () => true
        },
        2: { // Integer
            textAlign: TextAlign.RIGHT,
            format: val => CurrentFormat.formatInteger(val),
            parse: val => Math.round(numeral(val).value()),
            calculate: val => Math.round(calculateNumeric(val)),
            isCalculated: val => REGEX_CALCULATIONS.test(val) && DataType.behavior[DataType.INTEGER].isValidValue(val),
            isValidValue: val => {
                const calculated = DataType.behavior[DataType.INTEGER].calculate(val);
                return typeof calculated === "number"
                    ? !isNaN(calculated) && isFinite(calculated)
                    : false;
            },
            isValidDuringEntry: val => {
                let str = val;
                let parts = str.split(CurrentFormat.numberFormat.NumberDecimalSeparator);
                if (parts.length > 1)
                    return false;

                parts = str.split(CurrentFormat.numberFormat.NumberGroupSeparator);
                if (parts.length > 1) {
                    str = "";
                    for (let i = parts.length - 1; i > 0; i--) {
                        if (parts[i].length !== 3)
                            return false;
                        str = parts[i] + str;
                    }
                    str = parts[0] + str;
                }

                if (Array.from(str).find(c => c < "0" || c > "9"))
                    return false;

                return true;
            }
        },
        3: { // DateTime
            textAlign: TextAlign.RIGHT,
            format: function (val) {
                return moment(val).format(CurrentFormat.dateFormat.ShortDatePattern.toUpperCase());
            },
            parse: function (val, returnNull) {
                // This function is to be called only when a date object passed by NAV is to be converted to a date
                if (val && typeof val === "string") {
                    var date = moment(val.substring(0, 10), "YYYY-MM-DD");
                    if (date.isValid())
                        return date.toDate();
                };
                // some default behavior must exist if an invalid date is returned
                return returnNull ? null : new Date();
            },
            calculate: (val, noWarning) => {
                var date = moment(val, CurrentFormat.dateFormat.ShortDatePattern.toUpperCase());
                if (date.isValid())
                    return date.toDate();

                if (typeof val === "string") {
                    var v = val.toUpperCase();
                    if (v.length >= 2) {
                        function calculateDay(dayIndex) {
                            var now = new Date();
                            var calc = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                            while (calc.getDay() !== dayIndex) {
                                calc.setDate(calc.getDate() + 1);
                            };
                            return calc;
                        };

                        var calculatedDate = null;
                        CurrentFormat.dateFormat.DayNames.forEach(function (day, i) {
                            day = day.toUpperCase();
                            if (day === v || day.substring(0, v.length) === v)
                                calculatedDate = calculateDay(i);
                        });
                        if (calculatedDate)
                            return calculatedDate;
                    };

                    if (v.length >= 1) {
                        function offsetDay(days) {
                            var now = new Date();
                            var calc = new Date(now.getFullYear(), now.getMonth(), now.getDate());
                            calc.setDate(calc.getDate() + days);
                            return calc;
                        };

                        var today = localize("Global_Today").toUpperCase();
                        var yesterday = localize("Global_Yesterday").toUpperCase();
                        var tomorrow = localize("Global_Tomorrow").toUpperCase();

                        if (today && typeof today === "string")
                            if (v === today || today.substring(0, v.length) === v)
                                return offsetDay(0);

                        if (tomorrow && typeof tomorrow === "string")
                            if (v === tomorrow || tomorrow.substring(0, v.length) === v)
                                return offsetDay(1);

                        if (yesterday && typeof yesterday === "string")
                            if (v === yesterday || yesterday.substring(0, v.length) === v)
                                return offsetDay(-1);
                    }
                };
                noWarning || debug.warn("Unknown date string \"" +
                    val +
                    "\" cannot be parsed, calculated or processed.");
                return null;
            },
            isCalculated: val => DataType.behavior[DataType.DATETIME].calculate(val) instanceof Date && !(DataType.behavior[DataType.DATETIME].parse(val, true) instanceof Date),
            isValidValue: val => DataType.behavior[DataType.DATETIME].calculate(val) instanceof Date,
            isValidDuringEntry: val => !!DataType.behavior[DataType.DATETIME].parse(val)
        },
        4: { // Decimal
            textAlign: TextAlign.RIGHT,
            format: val => CurrentFormat.formatDecimal(val),
            parse: val => numeral(val).value(),
            calculate: val => calculateNumeric(val),
            isCalculated: val => REGEX_CALCULATIONS.test(val) && DataType.behavior[DataType.DECIMAL].isValidValue(val),
            isValidValue: val => {
                if (String(val).trim() === "")
                    return false;

                const calculated = DataType.behavior[DataType.DECIMAL].calculate(val);
                return typeof calculated === "number"
                    ? !isNaN(calculated) && isFinite(calculated)
                    : false;
            },
            isValidDuringEntry: val => {
                let parts = val.split(REGEX_CALCULATIONS).filter(e => e.trim().length);
                for (let part of parts) {
                    if (!isFormattedNumeric(part.trim()))
                        return false;
                }
                return true;
            }
        },
        5: { // String
            textAlign: TextAlign.LEFT,
            format: val => val,
            parse: val => val,
            calculate: val => val,
            isCalculated: () => false,
            isValidValue: () => true,
            isValidDuringEntry: () => true
        }
    }
};

const getNumericRegExp = () => new RegExp(`(^\\d{1,3}(\\${CurrentFormat.numberFormat.NumberGroupSeparator}\\d{3})*(\\${CurrentFormat.numberFormat.NumberGroupSeparator}\\d{0,3})?(\\${CurrentFormat.numberFormat.NumberDecimalSeparator}(\\d+)?)?$)|(^\\${CurrentFormat.numberFormat.NumberDecimalSeparator}(\\d+)?$)|(^\\d+(\\${CurrentFormat.numberFormat.NumberDecimalSeparator}\\d*)?$)`);
const isFormattedNumeric = val => getNumericRegExp().test(val);

const evalStrict = value => {
    "use strict";
    return eval(value);
};

const calculate = (val, octalsAllowed) => {
    if (typeof val === "number")
        return val;

    let v = "";
    for (let i = 0; i < val.length; i++)
        val[i] === CurrentFormat.numberFormat.NumberDecimalSeparator
            ? v += "."
            : val[i] !== " " && val[i] !== CurrentFormat.numberFormat.NumberGroupSeparator && (v += val[i]);
    v = v || "0";
    try {
        return (octalsAllowed ? eval : evalStrict)(v.replace(/x/g, "*"));
    } catch (er) {
        return NaN;
    }
};

const calculateNumeric = val => {
    typeof val === "string" && (val = val.trim());
    let ret = calculate(val, false);
    if (isNaN(ret)) {
        ret = calculate(val, true);
        if (!isNaN(ret)) {
            val = val.replace(/\b0+/g, "");
            ret = calculate(val, false);
        };
    };
    return !isFinite(ret) ? NaN : ret;
};

export const FormatAs = {
    decimal: number => DataType.behavior[DataType.DECIMAL].format(number),
    integer: number => DataType.behavior[DataType.INTEGER].format(number),
    dateTime: dateTime => DataType.behavior[DataType.DATETIME].format(dateTime)
};
