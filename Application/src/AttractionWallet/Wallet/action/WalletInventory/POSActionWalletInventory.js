const main = async ({ popup, captions, workflow }) => {
  const referenceNumber = await popup.input(captions.inputReference);
  if (!referenceNumber) {
    return;
  }

  const inventoryResponse = await workflow.respond("getWalletInventory", {
    input: referenceNumber,
  });

  if (Boolean(inventoryResponse.success) !== true) {
    await popup.message(inventoryResponse.reason);
    return;
  }

  const configurationResponse = await popup.configuration({
    title: inventoryResponse.title,
    caption: inventoryResponse.caption,
    settings: inventoryResponse.settings,
  });

  if (configurationResponse !== null) {
    await workflow.respond("processWalletInventorySelection", {
      selection: configurationResponse,
    });
  }
};
