let main = async ({workflow,parameters, context, popup, captions}) => {
    let memberCardDetails;    
    windowTitle = captions.Welcome;
    if (!parameters.input_reference_no) {
    context.input_reference_no = await popup.input({ title: captions.InputReferenceNoTitle, caption: captions.InputReferenceNo });
    if (!context.input_reference_no) { return };    
} else 
{
        context.input_reference_no = parameters.input_reference_no;       
    }
    const actiontryadmit = await workflow.respond("try_admit"); 
    if (actiontryadmit.isUnconfirmedGroup) {
      context.quantityToAdmUnconfirmedGroup = await popup.numpad({ caption: captions.QuantityAdmitLbl, title: captions.QuantityAdmitLbl, value: actiontryadmit.defaultQuantity });  
  } else
  {
    context.quantityToAdmUnconfirmedGroup = 0;}
    const actionResponse = await workflow.respond("admit_token");
    memberCardDetails = await workflow.respond("membercard_validation");
    if (actionResponse.success) {
    if (memberCardDetails.MemberScanned)
    {toast.memberScanned({
        memberImg: memberCardDetails.MemberScanned.ImageDataUrl,
        memberName: memberCardDetails.MemberScanned.Name,
        validForAdmission: memberCardDetails.MemberScanned.Valid,
        memberExpiry: memberCardDetails.MemberScanned.ExpiryDate,
      });}
      else
      {
        if (actionResponse.confirmedGroup)
        {toast.success (`Welcome group of ${actionResponse.qtyToAdmit} people`, {title: windowTitle});}
        else
        {
          toast.success (`Welcome ${actionResponse.table_capt} ${actionResponse.reference_no}`, {title: windowTitle});
        }        
      }        
    }
};