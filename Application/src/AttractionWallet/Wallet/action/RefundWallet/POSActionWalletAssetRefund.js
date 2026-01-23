const main = async ({ popup, captions, workflow }) => {
  const referenceNumber = await popup.input(captions.inputReference);
  if (!referenceNumber) {
    return;
  }

  const { success, reason } = await workflow.respond("refundAllWalletAssets", {
    input: referenceNumber,
  });

  if (Boolean(success) === true) {
    return;
  }

  await popup.message(reason);
};
