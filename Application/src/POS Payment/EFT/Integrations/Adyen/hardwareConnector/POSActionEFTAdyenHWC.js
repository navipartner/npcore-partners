const main = async ({ workflow, context, popup, captions, hwc }) => {
  context.EntryNo = context.request.EntryNo;
  context.success = false;
  context.abortRequested = false;

  let _dialogRef;
  if (!context.request.unattended) {
    _dialogRef = await popup.simplePayment({
      title: context.request.TypeCaption,
      initialStatus: captions.initialStatus,
      showStatus: true,
      amount: context.request.formattedAmount,
      onAbort: async () => {
        debugger;
        if (context.abortRequested) {
          return;
        }
        context.abortRequested = true;
        const abortRequest = await workflow.respond("abortStart");
        await hwc.invoke("EFTAdyenLocal", abortRequest.hwcRequest);
      },
    });
  }

  let _contextId;
  try {
    // Setup HWC connection to local machine
    _contextId = hwc.registerResponseHandler(async (hwcResponse) => {
      debugger;
      try {
        context.hwcResponse = hwcResponse;
        const bcResponse = await workflow.respond("transactionDone");
        if (
          !(await transactionIsDone(
            bcResponse,
            workflow,
            context,
            hwc,
            captions,
            popup,
            _contextId
          ))
        ) {
          return; //next transaction was started, wait for next hwc response
        }
        context.success = bcResponse.success;

        hwc.unregisterResponseHandler(_contextId); //done
      } catch (ex) {
        hwc.unregisterResponseHandler(_contextId, ex); //exception
      }
    });

    // Start transaction
    await hwc.invoke("EFTAdyenLocal", context.request.hwcRequest, _contextId);
    if (_dialogRef) {
      _dialogRef.updateStatus(captions.activeStatus);
      _dialogRef.enableAbort(true);
    }
    await hwc.waitForContextCloseAsync(_contextId);
  } finally {
    if (_dialogRef) {
      _dialogRef.close();
    }
  }
  return { success: context.success, tryEndSale: context.success };
};

async function transactionIsDone(
  bcResponse,
  workflow,
  context,
  hwc,
  captions,
  popup,
  contextId
) {
  if (bcResponse.signatureRequired) {
    let signatureResult = false;
    if (!context.request.unattended && bcResponse.signatureType === "Receipt") {
      signatureResult = await popup.confirm(captions.approveSignature);
    }
    if (!context.request.unattended && bcResponse.signatureType === "Bitmap") {
      const signatureData = JSON.parse(bcResponse.signatureBitmap);
      const signaturePopup = await popup.signatureValidation({
        signature: signatureData.SignaturePoint,
      });
      signatureResult = await signaturePopup.completeAsync();
    }
    if (!signatureResult) {
      const signatureDeclineBCResponse = await workflow.respond(
        "signatureRejectVoidStart"
      );
      debugger;
      context.EntryNo = signatureDeclineBCResponse.newEntryNo;
      await hwc.invoke(
        "EFTAdyenLocal",
        signatureDeclineBCResponse.hwcRequest,
        contextId
      );
      return false;
    }
  }
  if (bcResponse.silentAbort) {
    // transaction error indicates active transaction on terminal, attempt to cancel
    await hwc.invoke("EFTAdyenLocal", bcResponse.hwcRequest);
  }
  return true;
}
