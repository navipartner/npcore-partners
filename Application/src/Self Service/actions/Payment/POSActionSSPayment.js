let main = async ({ workflow, runtime }) => {
    runtime.suspendTimeout(); //Avoid self-service timeout

    const { dispatchToWorkflow, paymentType, amount } = await workflow.respond("preparePaymentWorkflow");

    if (amount === 0) {
      return await workflow.respond("tryEndSale");
    }
    
    const paymentResult = await workflow.run(dispatchToWorkflow, { context: { paymentType, amount } });
    
    if (paymentResult.tryEndSale) {
      return await workflow.respond("tryEndSale");
    }
    
    return {"success": false};
}