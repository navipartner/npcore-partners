const main = async ({ workflow, parameters, popup, context, captions }) => {
  let voucher_input;
  const response = {
    tryEndSale: false,
    legacy: false,
    success: false,
    remainingAmount: 0,
  };

  if (parameters.VoucherTypeCode) {
    context.voucherType = parameters.VoucherTypeCode;
  } else if (parameters.AskForVoucherType) {
    context.voucherType = await workflow.respond("setVoucherType");
    if (!context.voucherType) return response;
  }

  if (parameters.ReferenceNo) {
    voucher_input = parameters.ReferenceNo;
  } else {
    voucher_input = await popup.input({
      title: captions.VoucherPaymentTitle,
      caption: captions.ReferenceNo,
    });
  }

  if (voucher_input === null) return response;

  const {
    selectedVoucherReferenceNo,
    askForAmount,
    suggestedAmount,
    paymentDescription,
    amountPrompt,
    voucherType,
  } = await workflow.respond("calculateVoucherInformation", {
    VoucherRefNo: voucher_input,
  });
  context.voucherType = voucherType;
  if (!context.voucherType) return response;

  voucher_input = selectedVoucherReferenceNo;
  if (!voucher_input) return response;

  let selectedAmount = suggestedAmount;
  if (askForAmount) {
    let validateSuggestedAmount = true;
    while (validateSuggestedAmount) {
      selectedAmount = suggestedAmount;
      if (suggestedAmount > 0) {
        selectedAmount = await popup.numpad({
          title: paymentDescription,
          caption: amountPrompt,
          value: suggestedAmount,
        });
        if (selectedAmount === null) return response; // user cancelled dialog
      }

      validateSuggestedAmount = selectedAmount > suggestedAmount;
      if (validateSuggestedAmount) {
        await popup.message(
          captions.ProposedAmountDifferenceConfirmation.replace(
            "{0}",
            selectedAmount
          ).replace("{1}", suggestedAmount)
        );
      }
    }
  }

  const result = await workflow.respond("prepareRequest", {
    VoucherRefNo: voucher_input,
    selectedAmount: selectedAmount,
  });
  if (result.tryEndSale) {
    if (parameters.EndSale) {
      await workflow.run("END_SALE", {
        parameters: {
          calledFromWorkflow: "SCAN_VOUCHER_2",
          paymentNo: result.paymentNo,
        },
      });
    }
  } else {
    if (result.workflowVersion == 1) {
      await workflow.respond("doLegacyWorkflow", {
        workflowName: result.workflowName,
      });
    } else {
      if (result.workflowName) {
        await workflow.run(result.workflowName, {
          parameters: result.parameters,
        });
      }
    }
  }
  response.success = true;
  response.remainingAmount = result.remainingAmount;
  return response;
};
