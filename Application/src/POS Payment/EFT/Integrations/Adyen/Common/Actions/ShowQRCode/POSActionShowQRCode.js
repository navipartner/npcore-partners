const main = async ({ workflow, parameters }) => {
  await workflow.respond("showQRCodeOnTerminal", {
    qrCodeLink: parameters.qrCodeLink,
  });
};
