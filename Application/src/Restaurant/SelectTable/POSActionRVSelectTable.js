let main = async ({ workflow, parameters, context}) => { 
    let WaiterPadSelected = await workflow.respond("SelectWaiterPad");
    if (WaiterPadSelected)
    {
        workflow.run("RV_GET_WAITER_PAD", {parameters: {WaiterPadCode: context.waiterPadNo}})
    } else {
        workflow.run("RV_NEW_WAITER_PAD", {parameters: {SeatingCode: parameters.SeatingCode, SwitchToSaleView: true}})
    };
}