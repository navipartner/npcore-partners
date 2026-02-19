const main = async ({ workflow, popup, captions, parameters }) => {
  let memberCardDetails;
  let result;
  
  if (
    parameters.DefaultInputValue.length == 0 &&
    parameters.DialogPrompt == 1
  ) {
    memberCardDetails = await workflow.respond("CheckMemberInitialized");

    let tempCardNumber = parameters.DefaultInputValue;
    if (
      memberCardDetails != null &&
      memberCardDetails.MemberScanned != null &&
      memberCardDetails.MemberScanned.CardNumber !== "" &&
      (tempCardNumber === null || tempCardNumber === "")
    ) {
      tempCardNumber = memberCardDetails.MemberScanned.CardNumber;
    }

    if (parameters.DoNotSuggestTrackedMemberCard) {
      tempCardNumber = "";
    }

    result = await popup.input({
      caption: captions.MemberCardPrompt,
      title: captions.MembershipTitle,
      value: tempCardNumber,
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
      : 5;
  if (memberCardDetails.MemberScanned && hideAfter > 0) {
    toast.memberScanned({
      memberImg: memberCardDetails.MemberScanned.ImageDataUrl,
      memberName: memberCardDetails.MemberScanned.Name,
      validForAdmission: memberCardDetails.MemberScanned.Valid,
      hideAfter: hideAfter,
      memberExpiry: memberCardDetails.MemberScanned.ExpiryDate,
      content: [
        {
          caption: memberCardDetails.MemberScanned.MembershipCodeCaption,
          value: memberCardDetails.MemberScanned.MembershipCodeDescription,
        },
      ],
    });
  }
};
