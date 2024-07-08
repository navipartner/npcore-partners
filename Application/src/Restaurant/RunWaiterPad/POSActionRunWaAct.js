let main = async ({ workflow, context, popup, parameters }) => {
    if (await workflow.respond("createWaiterPad")) {
        if (context.newWaiterPadActionCode) {
            await workflow.run(context.newWaiterPadActionCode, context.newWaiterPadActionParams);
        };
    };
    let confirmCleanup = await workflow.respond("runMainAction");
    if (context.ShowResultMessage) {
        await popup.message(context.ResultMessageText);
    };
    if (context.CleanupMessageText) {
        if (confirmCleanup) {
            if (!await popup.confirm(context.CleanupMessageText)) { return };
        }
        else {
            popup.error(context.CleanupMessageText);
            return;
        };
    };
    await workflow.respond("runCleanup");
};