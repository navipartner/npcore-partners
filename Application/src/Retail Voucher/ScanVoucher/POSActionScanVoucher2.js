let main = async ({ workflow, parameters, popup, captions }) => {
    debugger;
    let voucher_input;

    if (parameters.VoucherTypeCode) {
        workflow.context.voucherType = parameters.VoucherTypeCode
    } else {
        workflow.context.voucherType = await workflow.respond("setVoucherType");
    }
    if (workflow.context.voucherType == null || workflow.context.voucherType == "") return;

    if (parameters.ReferenceNo) {
        voucher_input = parameters.ReferenceNo;
    } else {
        voucher_input = await popup.input({ title: captions.VoucherPaymentTitle, caption: captions.ReferenceNo })
    };
    if (voucher_input === null) return;

    let result = await workflow.respond("prepareRequest", { VoucherRefNo: voucher_input });
    if (result.tryEndSale) {
        if (parameters.EndSale) {
            await workflow.respond("endSale");
        };
        return;
    };

    if (result.workflowVersion == 1) {
        await workflow.respond("doLegacyWorkflow", { workflowName: result.workflowName });
    } else {
        await workflow.run(result.workflowName, { parameters: result.parameters })
    };
};
