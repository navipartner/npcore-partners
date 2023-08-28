
let main = async ({ parameters }) => {
    let { paymentWorkflow, paymentWorkflowParameters } = await workflow.respond("createAndPreparePayment", parameters.saleContents);
    await workflow.run(paymentWorkflow, { parameters: paymentWorkflowParameters });
};