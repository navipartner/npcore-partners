let main = async ({ workflow, runtime }) => {
    runtime.suspendTimeout(); //Avoid self-service timeout

    const { dispatchToWorkflow, paymentType, amount } = await workflow.respond("preparePaymentWorkflow");

    if (amount === 0) {
        await workflow.respond("tryEndSale");
        return;
    }

    let paymentResult = await workflow.run(dispatchToWorkflow, { context: { paymentType: paymentType, amount: amount } });
    if (paymentResult.tryEndSale) {
        await workflow.respond("tryEndSale");
    }
}