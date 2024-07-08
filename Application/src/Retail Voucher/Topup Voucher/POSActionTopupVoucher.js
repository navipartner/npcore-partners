let main = async ({ workflow, parameters, popup, captions }) => {
  let referenceNo,amount,disc_amount;  

  if (parameters.ReferenceNo) {
    referenceNo = parameters.ReferenceNo;
    }else    
      referenceNo = await popup.input({ title: captions.TopupVoucherTitle, caption: captions.ReferenceNo,value: ""});  
  if (referenceNo == null) return;

    const { VoucherNo } = await workflow.respond("validate_voucher", {referenceNo:referenceNo});
    if (VoucherNo == null || VoucherNo == "") return;

    if(parameters.Amount <= 0) {
      amount = await popup.numpad({title: captions.TopupVoucherTitle, caption: captions.Amount ,value: 0,notBlank: true});
      if (amount == null) return;
    }
    else
      amount = parameters.Amount;

    switch(parameters.DiscountType.toInt())
    {
        case parameters.DiscountType["Amount"]:
          if(parameters.DiscountAmount <= 0)
          {
            disc_amount = await popup.numpad({title: captions.TopupVoucherTitle, caption: captions.DiscountAmount ,value: 0});
            if (disc_amount == null) return;
          }else disc_amount = parameters.DiscountAmount
          break; 
        case parameters.DiscountType["Percent"]:
          if(parameters.DiscountAmount <= 0)
          {
            disc_amount = await popup.numpad({title: captions.TopupVoucherTitle, caption: captions.DiscountPercent ,value: 0});
            if (disc_amount == null) return;
          }else disc_amount = parameters.DiscountAmount
          break; 
        default:
          break;
    }

    if(parameters.ShowVoucherCard) await workflow.respond("show_voucher_card",{VoucherNo:VoucherNo});
    await workflow.respond("topup_voucher", {VoucherNo:VoucherNo,amount:amount,disc_amount:disc_amount});
}
