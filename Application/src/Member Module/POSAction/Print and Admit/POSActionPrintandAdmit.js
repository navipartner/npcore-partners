const main = async ({
  workflow,
  parameters,
  popup,
  context,
  captions,
  toast,
}) => {
  if (!parameters.reference_input) {
    context.reference_input = await popup.input({
      title: captions.ReferenceTitle,
      caption: captions.ReferenceCaption,
    });

    if (context.reference_input === null) {
      return;
    }
  } else {
    context.reference_input = parameters.reference_input;
  }

  const result = await workflow.respond("fill_data");
  const response = await workflow.respond("handle_data", {
    buffer_data: result,
  });

  if (response.admittedReferences) {
    response.admittedReferences.forEach((reference) => {
      switch (reference.type) {
        // Member Card
        case 1: {
          if (reference.memberDetails) {
            toast.memberScanned({
              memberImg: reference.memberDetails.MemberScanned.ImageDataUrl,
              memberName: reference.memberDetails.MemberScanned.Name,
              validForAdmission: reference.memberDetails.MemberScanned.Valid,
              memberExpiry: reference.memberDetails.MemberScanned.ExpiryDate,
            });
          }
          break;
        }
        default: {
          toast.success(
            `${captions.welcomeMsg} ${reference.tableCaption} ${reference.referenceId}`,
            { title: captions.welcomeMsg }
          );
          break;
        }
      }
    });
  }

  if (!response.printSuccessful) {
    await popup.error(`${captions.printingFailed} ${response.printErrorMsg}`);
  }
};
