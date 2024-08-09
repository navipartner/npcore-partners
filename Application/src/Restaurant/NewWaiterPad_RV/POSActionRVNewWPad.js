let main = async ({ workflow, context }) => {
    await workflow.respond("checkSeating");
    if (context.requestCustomerInfo) {
        context.waiterpadInfo = await popup.configuration(context.waiterpadInfoConfig);
        if (context.waiterpadInfo) {
            await workflow.respond();
        }
    }
}