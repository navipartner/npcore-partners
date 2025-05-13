const main = async ({ context, workflow, parameters, popup, captions }) => {
  let amountInput;
  await workflow.respond("validateRequest");

  const response = {
    returnVoucherAmt: 0,
  };

  if (parameters.VoucherTypeCode) {
    context.voucherType = parameters.VoucherTypeCode;
  } else {
    context.voucherType = await workflow.respond("setVoucherType");
  }
  if (context.voucherType == null || context.voucherType == "") return response;

  if (!context.IsUnattendedPOS && !context.issueReturnVoucherSilent) {
    amountInput = await popup.numpad({
      title: captions.IssueReturnVoucherTitle,
      caption: captions.Amount,
      value: context.voucher_amount,
    });
    if (amountInput === 0 || amountInput === null) return response;
  } else {
    amountInput = context.voucher_amount;
  }

  const ReturnVoucherAmount = await workflow.respond("validateAmount", {
    amountInput: amountInput,
  });
  if (ReturnVoucherAmount == 0) return response;

  const send = await workflow.respond("select_send_method");
  if (send.SendMethodEmail) {
    send.SendToEmail = await popup.input({
      title: captions.SendViaEmail,
      caption: captions.Email,
    });
  }
  if (send.SendMethodSMS) {
    send.SendToPhoneNo = await popup.input({
      title: captions.SendViaSMS,
      caption: captions.Phone,
    });
  }

  context = Object.assign(context, send);

  const { paymentNo, collectReturnInformation } = await workflow.respond(
    "issueReturnVoucher",
    {
      ReturnVoucherAmount: ReturnVoucherAmount,
    }
  );

  response.returnVoucherAmt = ReturnVoucherAmount;

  if (parameters.ContactInfo) {
    await workflow.respond("contactInfo");
  }
  if (parameters.ScanReferenceNos) {
    await workflow.respond("scanReference");
  }

  if (parameters.EndSale && collectReturnInformation) {
    const dataCollectionResponse = await workflow.run("DATA_COLLECTION", {
      parameters: {
        requestCollectInformation: "ReturnInformation",
      },
    });
    if (!dataCollectionResponse.success) {
      return {};
    }
  }

  if (parameters.EndSale) {
    await workflow.run("END_SALE", {
      parameters: {
        calledFromWorkflow: "ISSUE_RETURN_VCHR_2",
        paymentNo: paymentNo,
      },
    });
  }
  return response;
};
