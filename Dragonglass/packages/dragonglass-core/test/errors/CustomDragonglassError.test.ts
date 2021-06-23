import { CustomDragonglassError } from "../../src/errors/CustomDragonglassError";

describe("CustomDragonglassError class", () => {

    test("Instantiation and content", () => {
        let error1 = new CustomDragonglassError("Hello, World!");
        let error2 = new CustomDragonglassError("Hello, World!", "MyCustomError");
        expect(error1.message).toBe("Hello, World!");
        expect(error1.className).toBe("CustomDragonglassError");
        expect(error2.message).toBe("Hello, World!");
        expect(error2.className).toBe("MyCustomError");
    });

});
