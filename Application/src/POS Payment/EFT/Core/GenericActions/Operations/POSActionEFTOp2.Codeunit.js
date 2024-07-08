/*
    POSActionEFTOp2.Codeunit.js
*/
let main = async ({ workflow }) => {
    const request = await workflow.respond("prepareRequest");
    const { legacy, integrationRequest, showSuccessMessage, showSpinner, synchronousRequest } = request;

    if (synchronousRequest) {
        return;
    }

    if (legacy) {
        await workflow.respond("doLegacyPaymentWorkflow");
        return;
    }

    await workflow.run(request.workflowName, { context: { request: integrationRequest, showSpinner: showSpinner, showSuccessMessage: showSuccessMessage } });
};