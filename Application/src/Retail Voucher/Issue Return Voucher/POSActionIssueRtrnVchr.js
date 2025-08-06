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

  debugger;
  let CustomReferenceNo;
  if (parameters.ScanReferenceNos) {
    let GetCustomReferences = true;
    while (GetCustomReferences) {
      let ScanCustomReferenceNo = true;
      while (ScanCustomReferenceNo) {
        CustomReferenceNo = await popup.input({
          title: captions.CustomReferenceNoTitle,
          caption: captions.CustomReferenceNoCaption,
        });
        if (CustomReferenceNo === null) return {};
        ScanCustomReferenceNo = CustomReferenceNo === "";
        if (CustomReferenceNo !== null) {
          if (ScanCustomReferenceNo) {
            ScanCustomReferenceNo = await popup.confirm({
              title: captions.CustomReferenceNoTitle,
              caption: captions.ScanReferenceNoError,
            });
            if (!ScanCustomReferenceNo) return {};
          }
        }
        const { ReferenceNoAlreadyUsed, ReferenceNoAlreadyUsedMessage } =
          await workflow.respond("check_reference_no_already_used", {
            CustomReferenceNo: CustomReferenceNo,
          });
        if (ReferenceNoAlreadyUsed) {
          CustomReferenceNo = "";
          ScanCustomReferenceNo = await popup.confirm({
            title: captions.CustomReferenceNoCaption,
            caption: ReferenceNoAlreadyUsedMessage,
          });
          if (!ScanCustomReferenceNo) return {};
        }
      }
      GetCustomReferences = CustomReferenceNo === null;
    }
  }
  const { paymentNo, collectReturnInformation } = await workflow.respond(
    "issueReturnVoucher",
    {
      ReturnVoucherAmount: ReturnVoucherAmount,
      CustomReferenceNo: CustomReferenceNo,
    }
  );

  response.returnVoucherAmt = ReturnVoucherAmount;

  if (parameters.ContactInfo) {
    await workflow.respond("contactInfo");
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
