import { PropertyBag } from "dragonglass-core";
import { ActionParameters } from "../../src/classes/ActionParameters";
import { ParameterAccessViolationError } from "../../src/errors/ParameterAccessViolationError";

describe("ActionParameters class", () => {
    const template = {
        "Ordinal": 0,
        "_option_Color": {
            "red": 0,
            "green": 1,
            "blue": 2
        },
        "Color": 0,
        "Name": "John Doe",
        "_option_Title": {
            "Mr": 0,
            "Dr": 1,
            "HRH": 2
        },
        "Title": 1,
        "Retired": false
    };

    test("Parameter validation", () => {
        const param = new ActionParameters(template) as PropertyBag<any>;

        expect(param.Ordinal).toBe(0);
        expect(param.Color == param.Color.red).toBe(true);
        expect(param.Name).toBe("John Doe");
        expect(param.Title == param.Title.Dr).toBe(true);
        expect(param.Retired).toBe(false);
    });

    test("Option parameter equality checks", () => {
        const param = new ActionParameters(template) as PropertyBag<any>;

        const color = {
            red: Symbol(0),
            green: Symbol(1),
            blue: Symbol(2)
        };

        const title = {
            Mr: Symbol(),
            Dr: Symbol(),
            HRH: Symbol()
        };

        expect(param.Color.equals("red")).toBe(true);
        expect(param.Color.equals(0)).toBe(true);
        expect(param.Color.equals(param.Color.red)).toBe(true);
        expect(`${param.Color}` === "red").toBe(true);
        expect(param.Color === "red").toBe(false); // No strict equality on parameters!
        expect(param.Color.equals(color.red)).toBe(false); // This cannot ever be validated!

        expect(param.Title.equals("Dr")).toBe(true);
        expect(param.Title.equals(1)).toBe(true);
        expect(param.Title.equals(param.Title.Dr)).toBe(true);
        expect(`${param.Title}` === "Dr").toBe(true);
        expect(param.Title === "Dr").toBe(false); // No strict equality on parameters!
        expect(param.Title.equals(title.Dr)).toBe(false); // This cannot ever be validated!
    });

    test("Parameter write access", () => {
        const param = new ActionParameters(template) as PropertyBag<any>;
        expect(() => param.Color = param.Color.blue).toThrowError(ParameterAccessViolationError);
        expect(() => param.Title = param.Title.HRH).toThrowError(ParameterAccessViolationError);
        expect(() => param.Ordinal = 1).toThrowError(ParameterAccessViolationError);
        expect(() => param.Name = "Jane Doe").toThrowError(ParameterAccessViolationError);

        expect(() => param._expand_ = Symbol()).toThrowError(TypeError);
    });
    
});