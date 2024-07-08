let main = async ({ workflow, context }) => {
    // create the payment request
    const request = await workflow.respond("PrepareEftRequest", { context: { amount: context.amount } });
    const { workflowName, integrationRequest } = request;

    // invoke the specific workflow that handles the integration
    const { success, tryEndSale } = await workflow.run(workflowName, { context: { request: integrationRequest } });
    return ({ "success": success, "tryEndSale": request.tryEndSale && tryEndSale });
};




