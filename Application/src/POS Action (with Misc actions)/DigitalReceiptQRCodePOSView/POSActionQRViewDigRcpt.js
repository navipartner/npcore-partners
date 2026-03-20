let main = async ({ workflow }) => {
  debugger;
  let { qrCodeText, timeoutIntervalSec, footerText, scanReceiptText, showQRCodeOn } = await workflow.respond();
  if (qrCodeText) {
    switch (showQRCodeOn) {
      case 0:
        await popup.qr(
          {
            caption: footerText,
            qrData: qrCodeText,
            timeoutInSeconds: timeoutIntervalSec,
          },
          scanReceiptText
        );
        break;
      case 1:
        await workflow.run("SHOW_TERMINAL_QRCODE", {
          parameters: {
            qrCodeLink: qrCodeText,
          },
        });
        break;
    }
  };
};