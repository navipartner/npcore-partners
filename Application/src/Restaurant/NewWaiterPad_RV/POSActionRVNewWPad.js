let main = async ({ workflow, context }) => {
    await workflow.respond("checkSeating");
    context.waiterpadInfo = await popup.configuration(context.waiterpadInfoConfig);
    if (context.waiterpadInfo) {
        await workflow.respond();
    }
}