let main = async ({ workflow, parameters, popup, captions }) => {
    debugger;
    let voucher_input;
    let response = {tryEndSale: false, legacy: false};

    if (parameters.VoucherTypeCode) {
        workflow.context.voucherType = parameters.VoucherTypeCode
    } else if (parameters.AskForVoucherType){
        workflow.context.voucherType = await workflow.respond("setVoucherType");
        if (!workflow.context.voucherType) return response;
    }
    
    if (parameters.ReferenceNo) {
        voucher_input = parameters.ReferenceNo;
    } else {
        voucher_input = await popup.input({ title: captions.VoucherPaymentTitle, caption: captions.ReferenceNo })
    };

    if (!voucher_input) return response;
    
    if (!workflow.AskForVoucherType && !workflow.context.voucherType){
        workflow.context.voucherType = await workflow.respond("setVoucherTypeFromReferenceNo",  { VoucherRefNo: voucher_input });
        if (!workflow.context.voucherType ) return response;
    }
    
    let result = await workflow.respond("prepareRequest", { VoucherRefNo: voucher_input });
    if (result.tryEndSale) {
        if ((parameters.EndSale) && (!result.endSaleWithoutPosting)) {
            await workflow.respond("endSale");
        };
        return response;
    };

    if (result.workflowVersion == 1) {
        await workflow.respond("doLegacyWorkflow", { workflowName: result.workflowName });
    } else {
        await workflow.run(result.workflowName, { parameters: result.parameters })
    };

    return response;

};
