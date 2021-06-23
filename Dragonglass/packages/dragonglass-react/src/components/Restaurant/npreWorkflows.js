import { Options } from "../../classes/Options";
import { ACCEPT_NON_EXISTING_PARAMETERS, Workflow } from "dragonglass-workflows";

const tryGetParameters = option => {
    try {
        return JSON.parse(Options.get(option) || "{}");
    }
    catch {
        return {};
    }
};

/**
 * 
 * @param {String} workflow Name of the workflow to run
 * @param {Function} assignContext Function to run to assign context
 * @param {Symbol} noWorkflowSymbol Symbol to return from this function if no workflow is configured
 */
export const runWorkflowFromOption = async (workflow, assignContext, noWorkflowSymbol) => {
    const option = `npre_${workflow}Action`;
    const workflowToRun = Options.get(option);

    if (!workflowToRun) {
        console.info(`[NPRE] No workflow is configured to run on ${workflow} event.`);
        return noWorkflowSymbol;
    }

    const context = tryGetParameters(`${option}_parameters`);
    if (typeof context.parameters !== "object")
        context.parameters = {};
    if (typeof context.context !== "object")
        context.context = {};
    if (typeof assignContext === "function")
        assignContext(context);

    context[ACCEPT_NON_EXISTING_PARAMETERS] = true;
    return await Workflow.run(workflowToRun, context);
}

const newWaiterPad = table => runWorkflowFromOption("NewWaiterPad", context => context.parameters.SeatingCode = table);
const selectWaiterPad = waiterPad => runWorkflowFromOption("SelectWaiterPad", context => context.parameters.WaiterPadCode = waiterPad);
const selectRestaurant = restaurant => runWorkflowFromOption("SelectRestaurant", context => context.parameters.RestaurantCode = restaurant);
const selectTable = (table, noWorkflowSymbol) => runWorkflowFromOption("SelectTable", context => context.parameters.SeatingCode = table, noWorkflowSymbol);
const saveLayout = layout => runWorkflowFromOption("SaveLayout", context => context.context.layout = { ...layout });
const setWaiterPadStatus = (waiterPad, status) => runWorkflowFromOption("SetWaiterPadStatus", context => context.parameters = {...context.parameters, WaiterPadCode: waiterPad, StatusCode: status });
const setTableStatus = (table, status) => runWorkflowFromOption("SetTableStatus", context => context.parameters = {...context.parameters, SeatingCode: table, StatusCode: status });
const setNumberOfGuests = (table, waiterPad, noOfGuests) => runWorkflowFromOption("SetNumberOfGuests", context => context.parameters = {...context.parameters, SeatingCode: table, WaiterPadCode: waiterPad, NoOfGuests: noOfGuests });

export const npreWorkflows = {
    newWaiterPad,
    selectWaiterPad,
    selectTable,
    selectRestaurant,
    saveLayout,
    setWaiterPadStatus,
    setTableStatus,
    setNumberOfGuests
};
