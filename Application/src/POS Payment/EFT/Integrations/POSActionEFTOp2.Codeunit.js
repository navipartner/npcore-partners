/*
    POSActionEFTOp2.Codeunit.js
*/
let main = async ({workflow}) => {
    const {version, hwcRequest, showSuccessMessage, showSpinner} = await workflow.respond ("prepareRequest");

    if ((typeof version === 'undefined') || (version == 1)) {
        // Revert to legacy
        await workflow.respond ("doLegacyPaymentWorkflow");
        return;
    }

    if ((typeof hwcRequest !== 'undefined') && (hwcRequest.hasOwnProperty('WorkflowName'))) {
        workflow.queue (hwcRequest.WorkflowName, {context: {hwcRequest: hwcRequest, showSpinner: showSpinner, showSuccessMessage: showSuccessMessage}});
    }
};