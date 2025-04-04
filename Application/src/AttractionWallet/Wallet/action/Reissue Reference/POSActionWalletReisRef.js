const main = async ({ popup, captions, workflow }) => {
  const referenceNumber = await popup.input(captions.inputReference);
  if (!referenceNumber) {
    return;
  }

  const { success, reason } = await workflow.respond("reIssue", {
    input: referenceNumber,
  });

  if (Boolean(success) === true) {
    return;
  }

  switch (reason) {
    case "walletNotFound": {
      await popup.message(captions.noWalletFound);
      return;
    }
    case "walletRefAlreadyBlocked": {
      await popup.message(captions.walletRefAlreadyBlocked);
      return;
    }
  }
};
