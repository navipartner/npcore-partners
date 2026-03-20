let main = async ({ workflow }) => {
  debugger;
  let { digitalReceiptLink, footerText, timeoutIntervalSec, scanReceiptText, showQRCodeOn } = await workflow.respond();
  if (digitalReceiptLink) {
    switch (showQRCodeOn) {
      case 0:
        await popup.qr(
          {
            caption: footerText,
            qrData: digitalReceiptLink,
            timeoutInSeconds: timeoutIntervalSec,
          },
          scanReceiptText
        );
        break;
      case 1:
        await workflow.run("SHOW_TERMINAL_QRCODE", {
          parameters: {
            qrCodeLink: digitalReceiptLink,
          },
        });
        break;
    }
  }
}