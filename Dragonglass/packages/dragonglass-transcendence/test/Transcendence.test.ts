import { getTranscendenceInstance } from "./../src/getTranscendenceInstance";

describe("Transcendence", () => {
    test("All Transcendence tests", async () => {
        const transcendence = await getTranscendenceInstance(null, null);

        expect(transcendence).toBeDefined();

        let count = 0;
        for (let key in transcendence) {
            if (!transcendence.hasOwnProperty(key))
                continue;

            switch (key) {
                case "invokeFrontEndAsync":
                case "getNewButtonWorkflow":
                case "executeV1Workflow":
                case "actionActive":
                case "noSupport":
                case "Event":
                case "abortAllWorkflows":
                    count++;
                    expect(typeof transcendence[key]).toBe("function");
                    break;
                default:
                    throw new Error(`Unexpected member of Transcendence instance: ${key}`)
            }
        }
        expect(count).toBe(7);
    });
});
