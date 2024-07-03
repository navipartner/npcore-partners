let main = async ({ workflow }) => {
  debugger;
  let { qrCodeText, timeoutIntervalSec, footerText, scanReceiptText } = await workflow.respond();
  if (qrCodeText) {
    await popup.qr(
      {
        caption: footerText, 
        qrData: qrCodeText,
        timeoutInSeconds: timeoutIntervalSec
      },
      scanReceiptText
    );
  };
};