async function main({ workflow, parameters, captions }) {
  let remainingAmount = 0;
  const createDocumentReservationAmountSaleResponse = await workflow.respond(
    "CreateDocumentReservationAmountSale"
  );
  if (!createDocumentReservationAmountSaleResponse.success) return {};
  remainingAmount = createDocumentReservationAmountSaleResponse.remainingAmount;

  if (parameters.AskForVouchers) {
    let scanVoucher = true;
    let scanVoucherResponse;
    while (scanVoucher) {
      scanVoucher = await popup.confirm(
        captions.ScanVoucherRequestCaption.replace("%1", remainingAmount)
      );
      if (scanVoucher) {
        scanVoucherResponse = await workflow.run("SCAN_VOUCHER_2", {
          parameters: {
            AskForVoucherType: parameters.AskForVoucherType,
            VoucherTypeCode: parameters.VoucherTypeCode,
            EnableVoucherList: parameters.EnableVoucherList,
            EndSale: false,
          },
        });
        if (scanVoucherResponse.success) {
          scanVoucher = scanVoucherResponse.remainingSalesBalanceAmount > 0;
          remainingAmount = scanVoucherResponse.remainingSalesBalanceAmount;
        }
      }
    }
  }
  if (remainingAmount > 0) {
    const paymentWorkflowResponse = await workflow.run("PAYMENT_2", {
      parameters: {
        HideAmountDialog: true,
        paymentNo: parameters.POSPaymentMethodCode,
        tryEndSale: false,
      },
    });
    if (!paymentWorkflowResponse.success) {
      await workflow.respond("DeletePaymentLines");
      await workflow.run("CANCEL_POS_SALE", {
        parameters: { silent: true },
      });
      return {};
    }
  }

  return workflow.respond("ReserverPayment", {
    salesDocumentID:
      createDocumentReservationAmountSaleResponse.salesDocumentID,
  });
}
