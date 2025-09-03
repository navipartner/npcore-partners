let main = async ({ workflow, context, parameters, popup, captions }) => {
  await workflow.respond("OnBeforeWorkflow");
  const optionNames = [
    "Select Membership",
    "View Points",
    "Redeem Points",
    "Available Coupons",
    "Select Membership (EAN Box)",
  ];
  let functionInt = parameters.Function.toInt();

  if (functionInt < 0) {
    functionInt = 0;
  }
  if (parameters.DefaultInputValue.length > 0) {
    context.show_dialog = false;
  }

  const windowTitle = captions.LoyaltyWindowTitle.substitute(
    optionNames[functionInt]
  );

  let membercard_number = "";
  if (context.show_dialog) {
    membercard_number = await popup.input({
      caption: captions.MemberCardPrompt,
      title: windowTitle,
    });
    if (membercard_number === null) {
      return;
    }
  }

  const result = await workflow.respond("do_work", {
    membercard_number: membercard_number,
  });

  const hideAfter =
    parameters.ToastMessageTimer !== null &&
    parameters.ToastMessageTimer !== undefined &&
    parameters.ToastMessageTimer !== 0
      ? parameters.ToastMessageTimer
      : 15;
  if (result.MemberScanned && hideAfter > 0) {
    toast.memberScanned({
      memberImg: result.MemberScanned.ImageDataUrl,
      memberName: result.MemberScanned.Name,
      validForAdmission: result.MemberScanned.Valid,
      hideAfter: hideAfter,
      memberExpiry: result.MemberScanned.ExpiryDate,
    });
  }

  if (result.workflowName === "") {
    return;
  }
  await workflow.run(result.workflowName, { parameters: result.parameters });
};
