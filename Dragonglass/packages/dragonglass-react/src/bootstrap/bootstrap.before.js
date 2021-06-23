import {
    Ready,
    bootstrapStringSubstituteMonkeyPatch,
    bootstrapBusinessCentralUICustomization,
    DEBUG_SEVERITY
} from "dragonglass-core";
import { NAV } from "dragonglass-nav";
import { StateStore } from "../redux/StateStore";

/**
 * Runs any initialization code before page loads. This should involve only "static" (or more precisely: impure) modules to
 * initialize any global "static" state on which other things depend.
 * 
 * Keep this at minimum! Before adding anything to this script, think twice. Then think again.
 */
export const bootstrapBeforeLoad = () => new Promise(fulfill => {
    let finalizedReady = false;
    let finalizedStraight = false;

    // Initialize the ReadyManager object
    Ready.initialize(window, document);

    // Initialize the back-end infrastructure object
    Ready.instance.run(() => {
        // TODO: this path should be updateable from somewhere
        NAV.initialize(StateStore, Microsoft.Dynamics.NAV, "", DEBUG_SEVERITY.INFO);

        // Finalize and fulfill if necessary
        finalizedReady = true;
        if (finalizedStraight)
            fulfill();
    });

    // Monkey-patch String.prototype.substitute
    bootstrapStringSubstituteMonkeyPatch();

    // Hide all Business Central UI elements
    bootstrapBusinessCentralUICustomization();

    // Finalize and fulfill if necessary
    finalizedStraight = true;
    if (finalizedReady)
        fulfill();
});
