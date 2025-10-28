let main = async ({ workflow, context, popup, captions, parameters }) => {
  if (parameters.Function < 0) {
    parameters.Function = parameters.Function["Member Arrival"];
  }
  debugger;
  let memberCardNo = await workflow.respond("CheckMemberInitialized");

  if (
    memberCardNo != null &&
    memberCardNo.memberExternalCardNo != null &&
    memberCardNo.memberExternalCardNo !== ""
  ) {
    context.memberCardInput = memberCardNo.memberExternalCardNo;
  }

  let windowTitle = captions.DialogTitle.substitute(parameters.Function);

  // Prompt for member card number
  if (
    parameters.DefaultInputValue.length == 0 &&
    parameters.DialogPrompt <= parameters.DialogPrompt["Member Card Number"]
  ) {
    context.memberCardInput = await popup.input({
      caption: captions.MemberCardPrompt,
      title: captions.windowTitle,
      value: context.memberCardInput,
    });
    if (context.memberCardInput === null) {
      return;
    }
  }

  // When data is pass from EAN box f.ex.
  if (parameters.DefaultInputValue.length > 0) {
    context.memberCardInput = parameters.DefaultInputValue;
  }

  // If function is one of the membership alteration actions, fetch the options and prompt teller to choose
  if (
    parameters.Function >= parameters.Function["Regret Membership Entry"] &&
    parameters.Function <= parameters.Function["Cancel Membership"]
  ) {
    let lookupProperties = await workflow.respond(
      "GetMembershipAlterationLookup"
    );
    context.memberCardInput = lookupProperties.cardnumber;
    if (lookupProperties.data?.length == 0) {
      await popup.error({
        title: captions.windowTitle,
        caption: lookupProperties.notFoundMessage,
      });
      return;
    }

    let driver = data.createArrayDriver(lookupProperties.data);
    let source = data.createDataSource(driver);
    source.loadAll = false;
    let result = await popup.lookup({
      title: lookupProperties.title,
      configuration: {
        className: "custom-lookup",
        styleSheet: "",
        layout: lookupProperties.layout,
        result: (rows) =>
          rows ? rows.map((row) => (row ? row.itemno : null)) : null,
      },
      source: source,
    });

    if (result === null || result.length === 0) return;

    context.itemNumber = result[0].itemno;
  }

  // Process the main request
  let membershipResponse = await workflow.respond("DoManageMembership");

  if (parameters.Function == parameters.Function["View Membership Entry"]) {
    let driver = data.createArrayDriver(membershipResponse.data);
    let source = data.createDataSource(driver);
    let result = await popup.lookup({
      title: membershipResponse.title,
      configuration: {
        className: "custom-lookup",
        styleSheet: "",
        layout: membershipResponse.layout,
      },
      source: source,
    });
  }

  debugger;
  const hideAfter =
    parameters.ToastMessageTimer !== null &&
    parameters.ToastMessageTimer !== undefined &&
    parameters.ToastMessageTimer !== 0
      ? parameters.ToastMessageTimer
      : 15;
  if (membershipResponse.MemberScanned && hideAfter > 0) {
    toast.memberScanned({
      memberImg: membershipResponse.MemberScanned.ImageDataUrl,
      memberName: membershipResponse.MemberScanned.Name,
      validForAdmission: membershipResponse.MemberScanned.Valid,
      hideAfter: hideAfter,
      memberExpiry: membershipResponse.MemberScanned.ExpiryDate,
      content: [
        {
          caption: membershipResponse.MemberScanned.MembershipCodeCaption,
          value: membershipResponse.MemberScanned.MembershipCodeDescription,
        },
      ],
    });
  }

  // Configure success message timer (defaults to 5 seconds)
  const hideSuccessAfter = (parameters.ToastSuccessMessageTimer ?? 0) !== 0 ? parameters.ToastSuccessMessageTimer : 5;
  
  // Handle success messages
  if (membershipResponse && (membershipResponse.success === true || !membershipResponse.error)) {
    let successMessage = captions.SuccessMessage;
    
    // Convert function type to number to ensure proper case matching
    const FunctionNo = Number(parameters.Function);
    
    // Set appropriate success message based on function type
    switch(FunctionNo){
        case 1: {
            successMessage = captions.SelectMembershipSuccess; // Select membership
            break;
        }
        case 11: {
            successMessage = captions.CancelAutoRenewSuccess; // Cancel auto-renew
            break;
        }
        case 12: {
            if (membershipResponse.success === false) { return; }
            successMessage = captions.TerminateSubscriptionSuccess; // Terminate subscription
            break;
        }
        case 0:  // Member Arrival
        case 2:  // View Membership Entry - view operation so no toast needed
        case 3:  // Regret Membership - requires payment
        case 4:  // Renew Membership - requires payment
        case 5:  // Extend Membership - requires payment
        case 6:  // Upgrade Membership - requires payment
        case 7:  // Cancel Membership - may have refund/fees
        case 8:  // Edit Membership - may have cost difference
        case 9:  // Show Member - view operation so no toast needed
        case 10: // Edit Current Membership - may add cost difference to POS
        {
            return; // Don't show success toast - wait for payment completion
        }
    }
    
    // Display success toast notification
    toast.success(successMessage, {
        title: captions.SuccessTitle,
        hideAfter: hideSuccessAfter
    });
  }
}