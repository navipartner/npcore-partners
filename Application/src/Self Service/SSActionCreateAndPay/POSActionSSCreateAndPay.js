
let main = async ({ parameters }) => {
    let { paymentWorkflow, paymentWorkflowParameters } = await workflow.respond("createAndPreparePayment", parameters.SaleContents);
    let paymentResult = await workflow.run(paymentWorkflow, { parameters: paymentWorkflowParameters });
    
    if (!paymentResult.success) {
        console.info("[SS Create And Pay] payment result: "+paymentResult.success)
        throw new Error("DECLINED"); // Self-Service handles the DECLINED exception nicely without lock-down
    }

};