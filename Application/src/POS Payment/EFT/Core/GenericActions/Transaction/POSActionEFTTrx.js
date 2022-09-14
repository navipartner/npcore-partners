let main = async ({ workflow, runtime, context }) => {
    // create the payment request
    const request = await workflow.respond("PrepareEftRequest", { context: { suggestedAmount: context.suggestedAmount } });
    const { workflowName, integrationRequest, legacy } = request;

    debugger;

    // fallback to legacy workflow
    if (legacy) {
        return ({ "success": true, "legacy": true });
    }

    // Trx was handled synchronously via AL code, no workflow to nest.
    if (integrationRequest.synchronousRequest) {
        return ({ "success": integrationRequest.synchronousSuccess, "tryEndSale": request.tryEndSale })
    }

    runtime.suspendTimeout(); //Avoid self-service timeout

    // invoke the specific workflow that handles the integration
    debugger;
    const { success, tryEndSale } = await workflow.run(workflowName, { context: { request: integrationRequest } });
    return ({ "success": success, "tryEndSale": request.tryEndSale && tryEndSale });
};




