let main = async ({ workflow }) => {
  debugger;
  let { qrCodeText, timeoutIntervalSec, footerText } = await workflow.respond();
  if (qrCodeText) {
    let dialogRef = await popup.open({
      size: {
        width: "500px",
        height: "550px",
      },
      noScroll: true,
      isSupportedOnMobile: true,
      ui: [
        {
          id: "title",
          type: "label",
          caption: "Scan your receipt",
          style: {
            fontWeight: "bold",
            textAlign: "center",
            fontSize: "20px"
          }
        },
        {
          id: "html",
          type: "html",
          html: "<div style='text-align: center; margin-top: 30px'><img src='data:image/png;base64," + qrCodeText + "' width='300' height='300'/></div><br>" + footerText,
          className: "qrcode-dialog-html",
        }
      ],
      buttons: [
        {
          id: "button_1",
          caption: "Close",
          enabled: true,
          click: () => {
            dialogRef.close({ close: true });
          },
          style: {
            textAlign: "center"
          }
        }
      ]
    });
    if (timeoutIntervalSec) {
      setTimeout(function () { dialogRef.close() }, timeoutIntervalSec * 1000);
    }
  };
};