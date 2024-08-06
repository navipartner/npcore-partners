/*
    POSActionForeignVoucher.Codeunit.js
*/
const main = async ({ workflow, context, captions }) => {
  context.voucherNumber = await popup.input({
    title: captions.VoucherPaymentTitle,
    caption: captions.ReferenceNo,
  });
  if (!context.voucherNumber) return {};

  return workflow.respond("CapturePayment", {
    amountToCapture: context.suggestedAmount,
    defaultAmountToCapture: context.remainingAmount,
  });
};
