import { Debug, DEBUG_SEVERITY } from "../../src/classes/Debug";
import { IDebugSeverity } from "../../src/interfaces/IDebugSeverity";

describe("Debug class", () => {

    afterEach(() => jest.resetAllMocks());

    test("Debug base console replacement functionality", () => {
        // First, spy on console methods
        const log = jest.spyOn(console, "log");
        const info = jest.spyOn(console, "info");
        const warn = jest.spyOn(console, "warn");
        const error = jest.spyOn(console, "error");
        const trace = jest.spyOn(console, "trace");

        // Then instantiate debug, because this one binds console methods
        const debug = new Debug("jest", DEBUG_SEVERITY.INFO);
        expect(debug.source).toBe("jest");

        console.log("test");
        debug.log("test");
        expect(log).toBeCalledTimes(2);

        console.info("test");
        debug.info("test");
        expect(info).toBeCalledTimes(2);

        console.warn("test");
        debug.warn("test");
        expect(warn).toBeCalledTimes(2);

        console.error("test");
        debug.error("test");
        expect(error).toBeCalledTimes(2);

        console.trace();
        debug.trace();
        expect(trace).toBeCalledTimes(2);
    });

    test("Console content test", () => {
        let lastMessage: string = "";

        const log = jest.spyOn(console, "log").mockImplementation(message => lastMessage = message);
        const info = jest.spyOn(console, "info").mockImplementation(message => lastMessage = message);
        const warn = jest.spyOn(console, "warn").mockImplementation(message => lastMessage = message);
        const error = jest.spyOn(console, "error").mockImplementation(message => lastMessage = message);

        const source = "jest";
        const debug = new Debug("jest", DEBUG_SEVERITY.VERBOSE);

        const expectedLastMessage = (message: string, severity: IDebugSeverity) => `[${source}].[${severity._severity}] ${message}`;

        debug.verbose("test");
        expect(lastMessage).toBe(expectedLastMessage("test", DEBUG_SEVERITY.VERBOSE));
        
        debug.info("test");
        expect(lastMessage).toBe(expectedLastMessage("test", DEBUG_SEVERITY.INFO));
        
        debug.log("test");
        expect(lastMessage).toBe(expectedLastMessage("test", DEBUG_SEVERITY.LOG));
        
        debug.warn("test");
        expect(lastMessage).toBe(expectedLastMessage("test", DEBUG_SEVERITY.WARNING));
        
        debug.error("test");
        expect(lastMessage).toBe(expectedLastMessage("test", DEBUG_SEVERITY.ERROR));
        
        debug.critical("test");
        expect(lastMessage).toBe(expectedLastMessage("test", DEBUG_SEVERITY.CRITICAL));
    });

    test("Debug.bug (without trace)", () => {
        // First, spy on console methods
        const log = jest.spyOn(console, "log");
        const info = jest.spyOn(console, "info");
        const warn = jest.spyOn(console, "warn");
        const error = jest.spyOn(console, "error");
        const trace = jest.spyOn(console, "trace");

        // Then instantiate debug, because this one binds console methods
        const debug = new Debug("jest");

        // Default severity = error
        debug.bug("test");
        expect(error).toBeCalledTimes(1);

        // bug of info severity does not exist
        debug.bug("test", DEBUG_SEVERITY.INFO);
        expect(info).not.toBeCalled();
        expect(log).not.toBeCalled();
        expect(warn).not.toBeCalled();
        expect(error).toBeCalledTimes(1);

        // ... nor does it exist for verbose severity
        debug.bug("test", DEBUG_SEVERITY.VERBOSE)
        expect(info).not.toBeCalled();
        expect(log).not.toBeCalled();
        expect(warn).not.toBeCalled();
        expect(error).toBeCalledTimes(1);

        debug.bug("test", DEBUG_SEVERITY.WARNING);
        expect(warn).toBeCalledTimes(1);

        debug.bug("test", DEBUG_SEVERITY.ERROR);
        expect(error).toBeCalledTimes(2);

        debug.bug("test", DEBUG_SEVERITY.CRITICAL);
        expect(error).toBeCalledTimes(3); // Still error, more side effects should occur, though, and they should be tested when they are implemented

        expect(trace).toBeCalled();
    });

    test("Severity-based instances", () => {
        const log = jest.spyOn(console, "log");
        const info = jest.spyOn(console, "info");
        const warn = jest.spyOn(console, "warn");
        const error = jest.spyOn(console, "error");

        const debugVerbose = new Debug("test1", DEBUG_SEVERITY.VERBOSE);
        const debugInfo = new Debug("test1", DEBUG_SEVERITY.INFO);
        const debugLog = new Debug("test1", DEBUG_SEVERITY.LOG);
        const debugWarn = new Debug("test1", DEBUG_SEVERITY.WARNING);
        const debugError = new Debug("test1", DEBUG_SEVERITY.ERROR);
        const debugCritical = new Debug("test1", DEBUG_SEVERITY.CRITICAL);

        debugVerbose.verbose("verbose");
        debugInfo.verbose("verbose");
        debugLog.verbose("verbose");
        debugWarn.verbose("verbose");
        debugError.verbose("verbose");
        debugCritical.verbose("verbose");

        debugVerbose.info("info");
        debugInfo.info("info");
        debugLog.info("info");
        debugWarn.info("info");
        debugError.info("info");
        debugCritical.info("info");

        debugVerbose.log("log");
        debugInfo.log("log");
        debugLog.log("log");
        debugWarn.log("log");
        debugError.log("log");
        debugCritical.log("verbose");

        debugVerbose.warn("warn");
        debugInfo.warn("warn");
        debugLog.warn("warn");
        debugWarn.warn("warn");
        debugError.warn("warn");
        debugCritical.warn("warn");

        debugVerbose.error("error");
        debugInfo.error("error");
        debugLog.error("error");
        debugWarn.error("error");
        debugError.error("error");
        debugCritical.error("error");

        debugVerbose.critical("critical");
        debugInfo.critical("critical");
        debugLog.critical("critical");
        debugWarn.critical("critical");
        debugError.critical("critical");
        debugCritical.critical("critical");        

        expect(info).toBeCalledTimes(3);
        expect(log).toBeCalledTimes(3);
        expect(warn).toBeCalledTimes(4);
        expect(error).toBeCalledTimes(11);
    });
});
