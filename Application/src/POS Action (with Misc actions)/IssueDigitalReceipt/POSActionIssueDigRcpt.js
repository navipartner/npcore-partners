let main = async ({ workflow }) => {
  debugger;
  let { digitalReceiptLink } = await workflow.respond();
  if (digitalReceiptLink) {
    await workflow.run('VIEW_DIG_RCPT_QRCODE', { parameters: { qrCodeLink: digitalReceiptLink } });
  };
};