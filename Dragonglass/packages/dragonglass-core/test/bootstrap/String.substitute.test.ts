import { bootstrapStringSubstituteMonkeyPatch } from "../../src/bootstrap/String.substitute";

describe("String.prototype.substitute monkeypatch", () => {
    
    test("Testing monkeypatching", () => {
        expect((String.prototype as any).substitute).toBeUndefined();

        bootstrapStringSubstituteMonkeyPatch();

        expect((String.prototype as any).substitute).toBeDefined();

        expect(("Test %1 %2 %3" as any).substitute("one", "two", "three")).toBe("Test one two three");
    });
});
