/*
    POSActionCashPayment.Codeunit.js
*/
const main = async ({ workflow, context }) => {
  return workflow.respond("CapturePayment", {
    amountToCapture: context.suggestedAmount,
    defaultAmountToCapture: context.remainingAmount,
  });
};
