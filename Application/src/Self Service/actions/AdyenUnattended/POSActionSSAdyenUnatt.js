let main = async ({ workflow, popup, captions, context }) => {
    context.EntryNo = context.request.EntryNo;

    await workflow.respond("StartTrx");

    let _dialog = await popup.open({
        title: "Payment",
        ui: [
            {
                type: "label",
                id: "label1",
                caption: captions.selfserviceStatus
            }
        ],
        buttons: []
    });

    let trxPromise = new Promise((resolve, reject) => {
      let checkResponse = async () => {
          try {
              let bcResponse = await workflow.respond("CheckResponse");
              if (bcResponse.trxDone) {
                  context.success = bcResponse.BCSuccess;
                  _dialog.close();
                  resolve();
                  return;
              };
              setTimeout(checkResponse, 1000);
          }
          catch (e) {
              reject(e);
          }
      };
      setTimeout(checkResponse, 1000);
    });

    await trxPromise;
    return ({ "success": context.success, "tryEndSale": context.success});
}