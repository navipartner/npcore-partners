/*
    POSActionForeignVoucher.Codeunit.js
*/ 
let main = async ({workflow, context, captions}) => {
    context.voucherNumber = await popup.input({title: captions.VoucherPaymentTitle, caption: captions.ReferenceNo})
    if (!context.voucherNumber) return;

    return await workflow.respond("CapturePayment",{amountToCapture: context.suggestedAmount});
}
