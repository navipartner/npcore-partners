const main = async ({ workflow, parameters, popup, captions }) => {
  let VoucherTypeCode, amt_input, discount_input, qty_input;

  if (parameters.VoucherTypeCode) {
    VoucherTypeCode = { VoucherTypeCode: parameters.VoucherTypeCode };
  } else VoucherTypeCode = await workflow.respond("voucher_type_input");
  if (VoucherTypeCode == null || VoucherTypeCode == "") return;

  while (qty_input <= 0 || qty_input == null) {
    if (parameters.Quantity <= 0) {
      qty_input = await popup.numpad({
        title: captions.IssueVoucherTitle,
        caption: captions.Quantity,
        value: 1,
      });
    } else qty_input = parameters.Quantity;
    if (qty_input == null) return;
    await workflow.respond("check_qty", { qty_input: qty_input });
  }

  if (parameters.Amount <= 0) {
    amt_input = await popup.numpad({
      title: captions.IssueVoucherTitle,
      caption: captions.Amount,
      value: 0,
    });
    if (amt_input == null) return;
  } else amt_input = parameters.Amount;

  switch (parameters.DiscountType.toInt()) {
    case parameters.DiscountType["Amount"]:
      if (parameters.DiscountAmount <= 0) {
        discount_input = await popup.numpad({
          title: captions.IssueVoucherTitle,
          caption: captions.DiscountAmount,
          value: 0,
        });
        if (discount_input == null) return;
      } else discount_input = parameters.DiscountAmount;
      break;
    case parameters.DiscountType["Percent"]:
      if (parameters.DiscountAmount <= 0) {
        discount_input = await popup.numpad({
          title: captions.IssueVoucherTitle,
          caption: captions.DiscountPercent,
          value: 0,
        });
        if (discount_input == null) return;
      } else discount_input = parameters.DiscountAmount;
      break;
    default:
      break;
  }
  let {
    SendToEmail,
    SendToPhoneNo,
    SendMethodPrint,
    SendMethodEmail,
    SendMethodSMS,
  } = await workflow.respond("select_send_method", {
    VoucherTypeCode: VoucherTypeCode,
  });
  if (SendMethodEmail) {
    SendToEmail = await popup.input({
      title: captions.SendViaEmail,
      caption: captions.Email,
    });
    if (SendToEmail == null) return;
  }
  if (SendMethodSMS) {
    SendToPhoneNo = await popup.input({
      title: captions.SendViaSMS,
      caption: captions.Phone,
    });
    if (SendToPhoneNo == null) return;
  }

  let CustomReferenceNo;
  let CustomReferenceNoScanned = false;
  let i = 0;
  if (parameters.ScanReferenceNos) {
    let GetCustomReferences = true;
    while (GetCustomReferences) {
      let ScanCustomReferenceNo = true;
      while (ScanCustomReferenceNo) {
        CustomReferenceNo = await popup.input({
          title: captions.CustomReferenceNoTitle,
          caption: captions.CustomReferenceNoCaption,
        });
        ScanCustomReferenceNo = CustomReferenceNo == "";
        if (CustomReferenceNo !== null) {
          if (ScanCustomReferenceNo)
            ScanCustomReferenceNo = await popup.confirm({
              title: captions.CustomReferenceNoTitle,
              caption: captions.ScanReferenceNoError,
            });

          CustomReferenceNoScanned =
            !ScanCustomReferenceNo || CustomReferenceNoScanned;
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
        }
      }

      if (CustomReferenceNo)
        await workflow.respond("issue_voucher", {
          VoucherTypeCode: VoucherTypeCode,
          qty_input: 1,
          amt_input: amt_input,
          DiscountType: parameters.DiscountType,
          discount_input: discount_input,
          SendMethodPrint: SendMethodPrint,
          SendToEmail: SendToEmail,
          SendToPhoneNo: SendToPhoneNo,
          SendMethodEmail: SendMethodEmail,
          SendMethodSMS: SendMethodSMS,
          CustomReferenceNo: CustomReferenceNo,
        });

      i += 1;
      GetCustomReferences = CustomReferenceNo !== null && i < qty_input;
    }
  } else {
    await workflow.respond("issue_voucher", {
      VoucherTypeCode: VoucherTypeCode,
      qty_input: qty_input,
      amt_input: amt_input,
      DiscountType: parameters.DiscountType,
      discount_input: discount_input,
      SendMethodPrint: SendMethodPrint,
      SendToEmail: SendToEmail,
      SendToPhoneNo: SendToPhoneNo,
      SendMethodEmail: SendMethodEmail,
      SendMethodSMS: SendMethodSMS,
    });
  }
  if (
    (CustomReferenceNoScanned || !parameters.ScanReferenceNos) &&
    parameters.ContactInfo
  )
    await workflow.respond("contact_info");
};
