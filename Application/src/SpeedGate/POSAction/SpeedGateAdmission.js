let main = async ({workflow , parameters, context, popup, captions}) => {
    let memberCardDetails;
    windowTitle = captions.Welcome;
    if (!parameters.input_reference_no) {
    context.input_reference_no = await popup.input({ title: captions.InputReferenceNoTitle, caption: captions.InputReferenceNo });
    if (!context.input_reference_no) { return };    
} else 
{
        context.input_reference_no = parameters.input_reference_no;       
    }
    const actionResponse = await workflow.respond("validate_reference");
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
        toast.success (`Welcome ${actionResponse.table_capt} ${actionResponse.reference_no}`, {title: windowTitle});
      }        
    }
};