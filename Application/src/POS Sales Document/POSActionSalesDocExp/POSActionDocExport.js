const main = async ({ workflow, parameters, captions }) => {
  let attention, extDocNo, yourref;
  if (parameters.ConfirmExport) {
    const confirm = await popup.confirm(
      captions.confirmLead,
      captions.confirmTitle
    );
    if (!confirm) return;
  }
  if (parameters.AskExtDocNo) {
    extDocNo = await popup.input(captions.ExtDocNo);
    if (extDocNo === null) return;
  }
  if (parameters.AskAttention) {
    attention = await popup.input(captions.Attention);
    if (attention === null) return;
  }
  if (parameters.AskYourRef) {
    yourref = await popup.input(captions.YourRef);
    if (yourref === null) return;
  }

  const { preWorkflows, additionalParameters } = await workflow.respond(
    "preparePreWorkflows"
  );

  if (preWorkflows) {
    for (const preWorkflow of Object.entries(preWorkflows)) {
      const [preWorkflowName, preWorkflowParameters] = preWorkflow;
      if (preWorkflowName) {
        const preWorkflowResponse = await workflow.run(preWorkflowName, {
          parameters: preWorkflowParameters,
        });
        const preWorkflowResponseResult = await processPreWorkflowsResponse(
          preWorkflowName,
          preWorkflowResponse
        );
        if (preWorkflowResponseResult.stopExecution) return;
      }
    }
  }
  if (additionalParameters.pos_payment_reservation) {
    await workflow.respond("validateSaleBeforeReservation", {
      extDocNo: extDocNo,
      attention: attention,
      yourref: yourref,
      additionalParameters: additionalParameters,
    });
    const paymentResponse = await workflow.run("PAYMENT_2", {
      parameters: {
        paymentNo: parameters.POSPaymentMethodCode,
        HideAmountDialog: true,
        tryEndSale: false,
      },
    });
    if (!paymentResponse.success) return;
  }
  const { createdSalesHeader, createdSalesHeaderDocumentType } =
    await workflow.respond("exportDocument", {
      extDocNo: extDocNo,
      attention: attention,
      yourref: yourref,
      additionalParameters: additionalParameters,
    });

  let prepaymentAmt;
  if (additionalParameters.prompt_prepayment) {
    if (additionalParameters.prepayment_is_amount) {
      prepaymentAmt = await popup.numpad(
        captions.prepaymentAmountLead,
        captions.prepaymentDialogTitle
      );
    } else {
      prepaymentAmt = await popup.numpad(
        captions.prepaymentPctLead,
        captions.prepaymentDialogTitle
      );
    }
  } else prepaymentAmt = parameters.FixedPrepaymentValue;

  await workflow.respond("endSaleAndDocumentPayment", {
    additionalParameters: additionalParameters,
    createdSalesHeader,
    createdSalesHeaderDocumentType,
    prepaymentAmt,
  });
};

async function processPreWorkflowsResponse(
  preWorkflowName,
  preWorkflowResponse
) {
  const preWorkflowResponseResult = { stopExecution: false };

  if (!preWorkflowName) return {};
  if (!preWorkflowResponse) return {};

  switch (preWorkflowName) {
    case "CUSTOMER_SELECT":
      preWorkflowResponseResult.stopExecution = !preWorkflowResponse.success;
      break;
    case "SELECT_SHIP_METHOD":
      preWorkflowResponseResult.stopExecution = !preWorkflowResponse.success;
      break;
  }
  return preWorkflowResponseResult;
}
