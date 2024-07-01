let main = async ({ workflow }) => {
  debugger;
  let { qrCodeText, timeoutIntervalSec, footerText } = await workflow.respond();
  if (qrCodeText) {
    await popup.qr(
      {
        caption: footerText, 
        qrData: qrCodeText,
        timeoutInSeconds: timeoutIntervalSec
      },
      "Scan your receipt"
    );
  };
};