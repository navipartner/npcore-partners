import { PropertyBag } from "dragonglass-core";
import { ParameterAccessViolationError } from "../errors/ParameterAccessViolationError";

/**
 * Class that contains functionality to handle parameters defined on the action menu button in NAV.
 */
export class ActionParameters implements PropertyBag<any> {
    private _parameters: any;

    /**
     * Creates an instance of ActionParameters class.
     * @param {object} params Contains the Parameters collection passed from C/AL with the action configuration
     */
    constructor(parameters: any) {
        this._parameters = { ...parameters };
        const thisExpando: PropertyBag<any> = this;

        const defineParameter = (parameter: string, value: any) => {
            Object.defineProperty(this,
                parameter,
                {
                    get: () => value,
                    set: () => {
                        throw new ParameterAccessViolationError(parameter);
                    }
                });
        };

        // First pass, takes care of all _option_ parameters
        for (let param in this._parameters) {
            if (param.lastIndexOf("_option_") === 0) {
                let option = param.substring(8);

                // Define it as an instance of Number object so we can expand it with option-like properties
                const intValue = Number(this._parameters[option]);
                const numberValue = new Number(intValue);
                defineParameter(option, numberValue);
                const thisExpandoOption = thisExpando[option] as PropertyBag<any>;

                const options = this._parameters[param];
                let stringValue = "";
                // Attaching option-like properties, this allows for syntax like (param.color == param.color.red), however not (param.color === param.color.red)!!
                for (let v in options) {
                    thisExpandoOption[v] = options[v];
                    if (thisExpandoOption[v] === intValue)
                        stringValue = v;
                }

                // Attaching the equals function, this allows for syntax like (param.color.equals(param.color.red)) or (param.color.equals("red"))
                thisExpandoOption.equals = (value: any) => {
                    switch (typeof value) {
                        case "number":
                            return intValue === value;
                        case "string":
                            return stringValue === value;
                        default:
                            return false;
                    }
                };

                // Attaching the toString function, this allows for syntax like (param.color == "red")
                thisExpandoOption.toString = () => stringValue;

                // Attaching the toInt function, this allows to convert the value to integer for indexing purposes (if needed)
                thisExpandoOption.toInt = () => intValue;

                delete this._parameters[param];
            }
        }

        // Second pass, takes care of all other parameters, except for option parameters defined in the previous pass
        for (let o in this._parameters) {
            if (!thisExpando[o])
                defineParameter(o, this._parameters[o]);
        }

        Object.seal(thisExpando);
    }

    getRawObject() {
        return { ...this._parameters };
    }
}
