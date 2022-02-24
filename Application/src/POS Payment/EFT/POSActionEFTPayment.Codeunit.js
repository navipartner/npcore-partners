/*
    POSActionEFTPayment.Codeunit.js
*/
let main = async ({workflow, runtime, context}) => {
    // create the payment request
    const eftRequest = await workflow.respond("PrepareEftRequest", {context: {suggestedAmount: context.suggestedAmount}});

    // result contains the required request data and 
    const {workflowName, workflowVersion, hwcRequest} = eftRequest;
    
    // fallback to legacy workflow unless its version 3 or higher
    if (workflowVersion <= 2) return ({"success": true, "version": workflowVersion});

    runtime.suspendTimeout();

    // invoke the specific workflow that handles the integration
    let result = {"success": false, "endSale": false, "version": workflowVersion};
    if (hwcRequest.entryNo != 0) {
        const {success, endSale} = await workflow.run(workflowName, { context: { hwcRequest: hwcRequest }});
        result.success = success;
        result.endSale = endSale;
    };

    return (result);
};




