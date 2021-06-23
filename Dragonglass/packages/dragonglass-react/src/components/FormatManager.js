import { Component } from "react";
import { bindComponentToFormatState } from "../redux/reducers/formatReducer";
import numeral from "numeral";
import { FormatError } from "../dragonglass-errors/FormatError";

let _decimalFormat = "0,0.00";
let _integerFormat = "0,0";
let _numberFormat;
let _dateFormat;
let _currentLocale;

const registerNumberFormat = format => {
    _currentLocale = `dragonglass-${Date.now()}`;
    if (format.number) {
        _numberFormat = format.number;
        numeral.register("locale", _currentLocale,
            {
                delimiters: {
                    thousands: format.number.NumberGroupSeparator,
                    decimal: format.number.NumberDecimalSeparator
                },
                abbreviations: {
                    thousand: "K",
                    million: "M",
                    billion: "B",
                    trillion: "T"
                },
                ordinal: function () {
                    return ".";
                },
                currency: {
                    symbol: format.number.CurrencySymbol
                }
            });
        numeral.locale(_currentLocale);
        _decimalFormat = "0,0." + "0".repeat(format.number.NumberDecimalDigits);
        _integerFormat = "0,0";
    }

    if (format.date)
        _dateFormat = format.date;
};

class Format {
    get numberFormat() {
        if (!_numberFormat)
            throw new FormatError("[Dragonglass.FormatManager] Attempting to read numberFormat, but format has not been initialized.");
        return _numberFormat;
    }

    get dateFormat() {
        if (!_dateFormat)
            throw new FormatError("[Dragonglass.FormatManager] Attempting to read dateFormat, but format has not been initialized.");
        return _dateFormat;
    }

    get decimalFormat() {
        return _decimalFormat;
    }

    get integerFormat() {
        return _integerFormat;
    }

    parseNumber(value) {
        return numeral(value).value();
    }

    formatInteger(value) {
        const valueInt = numeral(value).value();
        return numeral(valueInt).format(_integerFormat);
    }

    formatDecimal(value) {
        const valueDec = numeral(value).value();
        return numeral(valueDec).format(_decimalFormat);
    }
}

export const CurrentFormat = new Format();

class FormatManager extends Component {
    shouldComponentUpdate(nextProps) {
        return this.props.format.generation !== nextProps.format.generation;
    }

    render() {
        const { format } = this.props;
        if (!format.generation)
            return null;

        console.log(`[Dragonglass.FormatManager] Updating date and number format to generation ${format.generation}`);
        registerNumberFormat(format);
        return null;
    }
}

export default bindComponentToFormatState(FormatManager);
