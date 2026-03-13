const main = async ({ popup, captions, workflow }) => {
  // Prompt user for reference number to find the wallet inventory to display
  const referenceNumber = await popup.input(captions.inputReference);
  if (!referenceNumber) {
    return;
  }

  // Resolve the wallet inventory based on the user input
  // The workflow will return the necessary information to render the inventory selection dialog,
  // or an error message if the inventory cannot be found or accessed
  const inventoryResponse = await workflow.respond("getWalletInventory", {
    input: referenceNumber,
  });

  if (Boolean(inventoryResponse.success) !== true) {
    await popup.message(inventoryResponse.reason);
    return;
  }

  // Display the inventory selection dialog to the user based on the workflow response
  const selectedFromInventory = await popup.configuration({
    title: inventoryResponse.title,
    caption: inventoryResponse.caption,
    settings: inventoryResponse.settings,
  });

  if (selectedFromInventory === null) {
    return;
  }

  // Process the user's selection from the inventory dialog.
  // The workflow will determine if the selection is valid, and if it can be applied directly or if further item selection is needed.
  const appliesToResponse = await workflow.respond(
    "processWalletInventorySelection",
    {
      selectedAsset: selectedFromInventory,
    }
  );

  if (Boolean(appliesToResponse.success) !== true) {
    if (appliesToResponse.reason) await popup.message(appliesToResponse.reason);
    return;
  }

  // Multiple items may be applicable for the selected wallet asset,
  // if so we need to ask the user to select which item they want to apply to
  if (
    Boolean(appliesToResponse.selectItem) === true &&
    appliesToResponse.itemReference === ""
  ) {
    const selectedFromAppliesTo = await popup.configuration({
      title: appliesToResponse.title,
      caption: appliesToResponse.caption,
      settings: appliesToResponse.settings,
    });

    if (selectedFromAppliesTo === null) {
      return;
    }

    const applyResponse = await workflow.respond(
      "applyItemAndInventorySelection",
      {
        selectedAsset: selectedFromAppliesTo,
        couponReference: appliesToResponse.couponReference,
      }
    );

    if (Boolean(applyResponse.success) !== true) {
      if (applyResponse.reason) await popup.message(applyResponse.reason);
      return;
    }

    await workflow.run("ITEM", {
      parameters: {
        SkipItemAvailabilityCheck: true,
        itemNo: applyResponse.itemReference,
      },
    });

    await workflow.respond("applyCoupon", {
      couponReference: appliesToResponse.couponReference,
    });

    return;
  }

  // If only one item is applicable, we can apply it directly without asking the user to select
  if (
    Boolean(appliesToResponse.selectItem) !== true &&
    appliesToResponse.itemReference !== ""
  ) {
    await workflow.run("ITEM", {
      parameters: {
        SkipItemAvailabilityCheck: true,
        itemNo: appliesToResponse.itemReference,
      },
    });
  }

  await workflow.respond("applyCoupon", {
    couponReference: appliesToResponse.couponReference,
  });
};
