let main = async ({ workflow, context }) => {
    let WaiterPadSelected = await workflow.respond("SelectWaiterPad");
    if (WaiterPadSelected) {
        await workflow.run("RV_GET_WAITER_PAD", { parameters: { WaiterPadCode: context.waiterPadNo } })
    } else {
        await workflow.run(context.newWaiterPadActionCode, context.newWaiterPadActionParams);
    };
}