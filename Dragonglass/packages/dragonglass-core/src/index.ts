import GlobalErrorDispatcher from "./classes/GlobalErrorDispatcher";
import GlobalEventDispatcher from "./classes/GlobalEventDispatcher";

// Constants
export { GLOBAL_ERRORS } from "./classes/GlobalErrorDispatcher";
export { GLOBAL_EVENTS } from "./classes/GlobalEventDispatcher";

// Errors
export { CustomDragonglassError } from "./errors/CustomDragonglassError";
export { SingletonViolationError } from "./errors/SingletonViolationError";
export { InvalidOperationError } from "./errors/InvalidOperationError";

// Classes
export { Singleton } from "./classes/Singleton";
export { EventDispatcher } from "./classes/EventDispatcher";
export { GlobalErrorDispatcher, GlobalEventDispatcher };
export { Ready } from "./classes/ReadyManager";
export { Debug, DEBUG_SEVERITY } from "./classes/Debug";
export { IDebugSeverity } from "./interfaces/IDebugSeverity";
export { Util } from "./classes/Util";
export { PluginRepository } from "./classes/PluginRepository";

// Functions
export { bootstrapStringSubstituteMonkeyPatch } from "./bootstrap/String.substitute";
export { bootstrapBusinessCentralUICustomization } from "./bootstrap/hack.ui";

// Interfaces
export {
    Delegate,
    Delegate_T,
    Delegate_T_U,
    Delegate_T_U_V,
    Func,
    Func_T,
    Func_T_U,
    Func_T_U_V,
    Predicate,
    Predicate_T
} from "./interfaces/Delegates";
export { PropertyBag } from "./interfaces/PropertyBag";
export { ITimeoutHandler } from "./interfaces/ITimeoutHandler";
export { IListenerDelegate } from "./interfaces/IListenerDelegate";
export { LocalizationHandler } from "./interfaces/LocalizationHandler";
export { ErrorReporter } from "./interfaces/ErrorReporter";
export { ControlRenderer } from "./interfaces/ControlRenderer";
export { ControlRendererPlugin } from "./interfaces/ControlRendererPlugin";
export { EventsModule } from "./interfaces/EventsModule";