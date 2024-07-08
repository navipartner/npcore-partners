let main = async (obj) => {
  let { workflow, context, popup, captions } = obj;

  context.EFTEntryNo = context.request.EFTEntryNo;
  context.PaymentSetupCode = context.request.PaymentSetupCode;
  context.Type = context.request.Type.toUpperCase();
  context.ReferenceNumberInput = context.request.ReferenceNumberInput;
  context.LastStatusDescription = captions.InitialStatus;
  context.Success = false;
  context.TryEndSale = false;

  let title = "";
  switch (context.Type) {
    case "PAYMENT":
      title = captions.TitlePayment;
      break;
    case "REFUND":
      title = captions.TitleRefund;
      break;
  }

  let _dialogRef = await popup.mobilePay({
    title: title,
    initialStatus: context.LastStatusDescription,
    showStatus: true,
    amount: context.request.FormattedAmount,
    qr: {
      value: context.request.QrContent,
    },
    onAbort: async () => {
      _dialogRef.updateStatus(captions.Aborting);
      await workflow.respond("Abort");
    },
  });
  try {
    let WorkflowRespond = async (Step) => {
      let bc = await workflow.respond(Step);
      if (bc.Error) throw Error(bc.ErrorMessage);
      return bc;
    };
    let bc = {};
    _dialogRef.enableAbort(true);
    if (context.Type === "PAYMENT") {
      if (context.request.QrOnCustomerDisplay) {
        try {
          await workflow.run("HTML_DISPLAY_QR", {
            context: {
              IsNestedWorkflow: true,
              QrShow: true,
              QrTitle: "MobilePay",
              QrMessage: context.request.FormattedAmount,
              QrContent: context.request.QrContent,
            },
          });
        } catch (e) {
          console.error("Could not display Qr code on Customer Display: " + e);
        }
      }
      await WorkflowRespond("BeginWaitCustomer");
      _dialogRef.updateStatus(context.LastStatusDescription);
      bc = await PollPromise("WaitCustomerCheckin", workflow);
      _dialogRef.updateStatus(context.LastStatusDescription);
    }
    if (!bc.UserCheckInAborted) {
      await WorkflowRespond("CreateTransaction");
      _dialogRef.updateStatus(context.LastStatusDescription);
      await PollPromise("WaitCreateTransaction", workflow);
      _dialogRef.updateStatus(context.LastStatusDescription);
      if (context.Type === "PAYMENT") {
        bc = await PollPromise("WaitCustomerPayment", workflow);
        _dialogRef.updateStatus(context.LastStatusDescription);
        if (bc.CaptureTransaction) {
          await WorkflowRespond("CaptureTransaction");
          _dialogRef.updateStatus(context.LastStatusDescription);
          await PollPromise("WaitCaptureTransaction", workflow);
          _dialogRef.updateStatus(context.LastStatusDescription);
        }
      }
    }
  } catch (e) {
    console.error("Vipps Mobilepay Error");
    console.error(e);
    let err = e.message ? e.message : e;
    popup.error(err, "Vipps Mobilepay Error");
    await workflow.respond("Abort");
  } finally {
    if (_dialogRef) {
      _dialogRef.close();
    }
    if (context.request.QrOnCustomerDisplay) {
      try {
        await workflow.run("HTML_DISPLAY_QR", {
          context: {
            IsNestedWorkflow: true,
            QrShow: false,
            QrTitle: "MobilePay",
          },
        });
      } catch (e) {
        console.error("Could not close qr on customer display: " + e);
      }
    }
  }
  return { success: context.Success, tryEndSale: context.TryEndSale };
};

function PollPromise(Step, workflow) {
  return new Promise((resolve, reject) => {
    let pollFunction = async () => {
      try {
        let bc = await workflow.respond(Step);
        if (bc.Done) {
          resolve(bc);
          return;
        }
        if (bc.Error) {
          reject(bc.ErrorMessage);
          return;
        }
      } catch (exception) {
        await workflow.respond("Abort");
        reject(exception);
        return;
      }
      setTimeout(pollFunction, 1000);
    };
    setTimeout(pollFunction, 1000);
  });
}
