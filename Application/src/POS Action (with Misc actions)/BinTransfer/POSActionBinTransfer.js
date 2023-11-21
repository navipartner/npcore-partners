let main = async ({ workflow }) => {
    let { legacyAction, binTransferContextData } = (await workflow.respond("PrepareWorkflow"));
    if (legacyAction) {
        await workflow.respond("RunLegacyAction");
    } else {
        let returnedData = await popup.binTransfer(binTransferContextData);
        await workflow.respond("ProcessBinTranser", returnedData);
    };
};