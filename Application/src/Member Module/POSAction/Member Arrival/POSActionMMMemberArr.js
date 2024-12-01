const main = async ({ workflow, popup, captions, parameters }) => {
  let memberCardDetails;
  debugger;
  if (
    parameters.DefaultInputValue.length == 0 &&
    parameters.DialogPrompt == 1
  ) {
    const result = await popup.input({
      caption: captions.MemberCardPrompt,
      title: captions.MembershipTitle,
      value: parameters.DefaultInputValue,
    });
    if (result === null) {
      return " ";
    }
    memberCardDetails = await workflow.respond("MemberArrival", {
      membercard_number: result,
    });
  } else {
    memberCardDetails = await workflow.respond("MemberArrival");
  }

  const hideAfter =
    parameters.ToastMessageTimer !== null &&
    parameters.ToastMessageTimer !== undefined &&
    parameters.ToastMessageTimer !== 0
      ? parameters.ToastMessageTimer
      : 15;
  if (memberCardDetails.MemberScanned && hideAfter > 0) {
    toast.memberScanned({
      memberImg: memberCardDetails.MemberScanned.ImageDataUrl,
      memberName: memberCardDetails.MemberScanned.Name,
      validForAdmission: memberCardDetails.MemberScanned.Valid,
      hideAfter: hideAfter,
      memberExpiry: memberCardDetails.MemberScanned.ExpiryDate,
    });
  }
};
