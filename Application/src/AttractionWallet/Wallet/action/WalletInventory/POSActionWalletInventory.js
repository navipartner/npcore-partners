const main = async ({ popup, captions, workflow, parameters }) => {
  // popup.configuration reports an unselected radio group as the string "{}" (not null); a selected
  // radio is its option value. Anything else - null, undefined, an object - is no selection either.
  const hasSelection = (value) =>
    value !== null &&
    value !== undefined &&
    typeof value !== "object" &&
    String(value) !== "" &&
    String(value) !== "{}";

  // Run from the POS input box the wallet reference arrives as a parameter; otherwise prompt for it
  const referenceNumber =
    parameters.WalletReferenceNo || (await popup.input(captions.inputReference));
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

  let selectedFromInventory;
  if (inventoryResponse.autoSelectedAsset) {
    // Exactly one usable coupon in the wallet - nothing to ask, advance straight to the next step
    selectedFromInventory = inventoryResponse.autoSelectedAsset;
  } else {
    // Display the inventory selection dialog. Any empty result is a cancel; OK without a usable
    // coupon explains why and shows the same list again.
    do {
      selectedFromInventory = await popup.configuration({
        title: inventoryResponse.title,
        caption: inventoryResponse.caption,
        settings: inventoryResponse.settings,
      });

      if (!selectedFromInventory) {
        return;
      }

      // "None" is the only option when nothing usable is left to pick - picking it closes the dialog.
      if (String(selectedFromInventory.couponSection).startsWith("__none__")) {
        return;
      }

      if (!hasSelection(selectedFromInventory.couponSection)) {
        // The invalid (spent/expired) coupons are listed in their own group and can be picked,
        // but never used - say so rather than claiming nothing was selected.
        if (hasSelection(selectedFromInventory.invalidCouponSection)) {
          await popup.message(captions.invalidCouponSelected);
        } else {
          await popup.message(captions.selectRequired);
        }
      }
    } while (!hasSelection(selectedFromInventory.couponSection));
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
    let selectedFromAppliesTo;
    do {
      selectedFromAppliesTo = await popup.configuration({
        title: appliesToResponse.title,
        caption: appliesToResponse.caption,
        settings: appliesToResponse.settings,
      });

      if (!selectedFromAppliesTo) {
        return;
      }

      if (!hasSelection(selectedFromAppliesTo.itemSection)) {
        await popup.message(captions.selectRequired);
      }
    } while (!hasSelection(selectedFromAppliesTo.itemSection));

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
