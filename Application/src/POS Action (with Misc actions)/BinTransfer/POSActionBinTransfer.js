let main = async ({ workflow }) => {
    let { legacyAction, binTransferContextData, postWorkflows } = await workflow.respond("PrepareWorkflow");
    if (legacyAction) {
        return await workflow.respond("RunLegacyAction");
    };
    
    let returnedData = await popup.binTransfer(binTransferContextData);
    let { success, checkpointEntryNo } = await workflow.respond("ProcessBinTranser", returnedData);
    if (!success) { return };

    if (postWorkflows) {
        for (const postWorkflow of Object.entries(postWorkflows)) {
            let [postWorkflowName, postWorkflowParameters] = postWorkflow;
            if (postWorkflowName) {
                await workflow.run(postWorkflowName, { context: { transferResult: { checkpointEntryNo: checkpointEntryNo } }, parameters: postWorkflowParameters });
            };
        };
    };
};