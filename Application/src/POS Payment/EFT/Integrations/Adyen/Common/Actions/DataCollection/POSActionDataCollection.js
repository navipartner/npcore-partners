let main = async ({ workflow, context, popup, captions, parameters }) => {

  debugger;
  switch(parameters.requestCollectInformation.toInt())
  {
    case parameters.requestCollectInformation["ReturnInformation"]:
      let _dialogRef = await popup.simplePayment({
        title: captions.dataCollectionTitle,
        abortEnabled: true,
        amount: " ",
        amountStyle: {"fontSize": "0px"},
        initialStatus: captions.initialStatus,
        showStatus: true,
        onAbort: async () => {
          await workflow.respond("requestAbort");
        }
      });

      try {
        let startTrxResponse = await workflow.respond("collectData");
        if (startTrxResponse.newEntryNo) {
            context.EntryNo = startTrxResponse.newEntryNo;
        }
        _dialogRef && _dialogRef.updateStatus(captions.collectingDataStatus);
        _dialogRef && _dialogRef.enableAbort(true);
        await trxPromise(context, popup, workflow);
      }
      finally {
        _dialogRef && _dialogRef.close();
      }
      
      return ({ "success": context.success, "tryEndSale": context.success });
    case parameters.requestCollectInformation["AcquireSignature"]:
      const signaturePoints = await popup.inputSignature({
        title: "Insert Signature",
      });
      if (signaturePoints !== null) {
        await workflow.respond("collectSignature", {
          signaturePoints: signaturePoints,
        });
      }
  }
};

function trxPromise(context, popup, workflow) {
  return new Promise((resolve, reject) => {
    let pollFunction = async () => {
        try {
          debugger;
          let pollResponse = await workflow.respond("poll");
          if (pollResponse.newEntryNo) {
            context.EntryNo = pollResponse.newEntryNo;
            setTimeout(pollFunction, 1000);
            return;
          }
          if (pollResponse.dataVerificationRequired) {
            debugger;
            let signatureResult = false;
            let signatureData = JSON.parse(pollResponse.signatureBitmap || "{}");
            let signaturePopup = await popup.signatureValidation();
            setTimeout(() => {signaturePopup.updateSignature(signatureData, {phoneNoData:pollResponse.phoneNoData, 
                                                                            emailData:pollResponse.emailData, 
                                                                            showSignature:pollResponse.showSignature, 
                                                                            showPhoneNo:pollResponse.showPhoneNo, 
                                                                            showEmail:pollResponse.showEmail})}, 1000);
            signatureResult = await signaturePopup.completeAsync();
            if (!signatureResult) {
                let declineResponse = await workflow.respond("signatureDecline");
                context.success = declineResponse.success;
                resolve();
                return;
            } else {
                await workflow.respond("signatureApprove");
            }
          };
          if (pollResponse.done) {
            debugger;
            context.success = pollResponse.success;
            resolve();
            return;
          };
        }
        catch (exception) {
            debugger;
            try { await workflow.respond("requestAbort"); } catch { }
            reject(exception);
            return;
        }
        setTimeout(pollFunction, 1000);
      };
      setTimeout(pollFunction, 1000);
    });
};