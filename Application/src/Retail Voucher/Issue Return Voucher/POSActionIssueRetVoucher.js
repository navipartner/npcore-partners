let main = async ({ workflow, parameters, popup, captions }) => {
    debugger;
    let amountInput;
    const { endSaleWorkflowEnabled } = await workflow.respond('validateRequest');

    if (parameters.VoucherTypeCode) {
        workflow.context.voucherType = parameters.VoucherTypeCode
    } else {
        workflow.context.voucherType = await workflow.respond("setVoucherType");
    }
    if (workflow.context.voucherType == null || workflow.context.voucherType == "") return;

    if (!workflow.context.IsUnattendedPOS) {
        amountInput = await popup.numpad({ title: captions.IssueReturnVoucherTitle, caption: captions.Amount, value: workflow.context.voucher_amount, notBlank: true });
        if (amountInput === 0 || amountInput === null) return;
    } else { amountInput = workflow.context.voucher_amount };

    let ReturnVoucherAmount = await workflow.respond('validateAmount', { amountInput: amountInput });
    if (ReturnVoucherAmount == 0) return;

    let send = await workflow.respond("select_send_method");
    if (send.SendMethodEmail) {
        send.SendToEmail = await popup.input({ title: captions.SendViaEmail, caption: captions.Email, value: send.SendToEmail, notBlank: true });
    }
    if (send.SendMethodSMS) {
        send.SendToPhoneNo = await popup.input({ title: captions.SendViaSMS, caption: captions.Phone, value: send.SendToPhoneNo, notBlank: true });
    }

    workflow.context = Object.assign(workflow.context, send);

    const { paymentNo } = await workflow.respond("issueReturnVoucher", { ReturnVoucherAmount: ReturnVoucherAmount });

    if (parameters.ContactInfo) {
        await workflow.respond("contactInfo");
    }
    if (parameters.ScanReferenceNos) {
        await workflow.respond("scanReference");
    }
    if (parameters.EndSale) {
        if (endSaleWorkflowEnabled) {
            await workflow.run('END_SALE', { parameters: {calledFromWorkflow: 'ISSUE_RETURN_VCHR_2', paymentNo: paymentNo } });
        } else {
            await workflow.respond("endSale");
        }
    }
    return;
}

