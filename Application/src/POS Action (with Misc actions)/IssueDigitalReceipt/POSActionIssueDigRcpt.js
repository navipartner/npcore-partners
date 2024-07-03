let main = async ({ workflow }) => {
  debugger;
  let { digitalReceiptLink, footerText, timeoutIntervalSec, scanReceiptText } = await workflow.respond();
  if (digitalReceiptLink) {
    await popup.qr(
      {
        caption: footerText, 
        qrData: digitalReceiptLink,
        timeoutInSeconds: timeoutIntervalSec
      },
      scanReceiptText
    );
  };
};