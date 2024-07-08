let main = async ({ workflow, parameters, captions }) => {
    debugger;
    let confirm, attention, extDocNo, yourref;
    if (parameters.ConfirmExport) {
        let confirm = await popup.confirm(captions.confirmLead, captions.confirmTitle);
        if (!confirm)
            return;
    };
    if (parameters.AskExtDocNo) {
        extDocNo = await popup.input(captions.ExtDocNo);
        if (extDocNo === null)
            return;
    };
    if (parameters.AskAttention) {
        attention = await popup.input(captions.Attention);
        if (attention === null)
            return;
    };
    if (parameters.AskYourRef) {
        yourref = await popup.input(captions.YourRef);
        if (yourref === null)
            return;
    };

    const { preWorkflows } = await workflow.respond("preparePreWorkflows");

    if (preWorkflows) {
        for (const preWorkflow of Object.entries(preWorkflows)) {
            let [preWorkflowName, preWorkflowParameters] = preWorkflow;
            if (preWorkflowName) {
                await workflow.run(preWorkflowName, { parameters: preWorkflowParameters });
            };
        };
    };

    const { createdSalesHeader, createdSalesHeaderDocumentType, additionalParameters } = await workflow.respond("exportDocument", { extDocNo: extDocNo, attention: attention, yourref: yourref });

    let prepaymentAmt;
    if (additionalParameters.prompt_prepayment) {
        if (additionalParameters.prepayment_is_amount) {
            prepaymentAmt = await popup.numpad(captions.prepaymentAmountLead, captions.prepaymentDialogTitle)
        } else {
            prepaymentAmt = await popup.numpad(captions.prepaymentPctLead, captions.prepaymentDialogTitle)
        };
    } else
        prepaymentAmt = parameters.FixedPrepaymentValue;

    await workflow.respond("endSaleAndDocumentPayment", { additionalParameters: additionalParameters, createdSalesHeader, createdSalesHeaderDocumentType, prepaymentAmt })
}

