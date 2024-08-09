const main = async (obj) => {
  const { workflow, context, popup, captions } = obj;

  context.EFTEntryNo = context.request.EFTEntryNo;
  context.PaymentSetupCode = context.request.PaymentSetupCode;
  context.Type = context.request.Type.toUpperCase();
  context.ReferenceNumberInput = context.request.ReferenceNumberInput;
  context.LastStatusDescription = captions.InitialStatus;
  context.Success = false;
  context.TryEndSale = false;
  context.CaptureTransaction = false;
  context.UserCheckInAborted = false;

  let title = "";
  switch (context.Type) {
    case "PAYMENT":
      title = captions.TitlePayment;
      break;
    case "REFUND":
      title = captions.TitleRefund;
      break;
  }

  const _dialogRef = await popup.mobilePay({
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
    _dialogRef.enableAbort(true);
    await ShowQrOnCustomerDisplay(context);
    await RunProtocol(_dialogRef, context, workflow);
  } catch (ex) {
    if (ex !== null && ex !== undefined) {
      const msg = ex.message ? ex.message : ex;
      if (msg !== "Aborted") popup.error(msg, "Vipps Mobilepay Error");
    } else {
      popup.error("Unknown Error", "Vipps Mobilepay Error");
    }

    await workflow.respond("Abort");
  } finally {
    if (_dialogRef) {
      _dialogRef.close();
    }
    await HideQrOnCustomerDisplay(context);
  }
  return { success: context.Success, tryEndSale: context.TryEndSale };
};

async function RunProtocol(_dialogRef, context, workflow) {
  if (context.Type === "PAYMENT") {
    await workflow.respond("BeginWaitCustomer");
    _dialogRef.updateStatus(context.LastStatusDescription);
    await PollPromise("WaitCustomerCheckin", workflow);
    _dialogRef.updateStatus(context.LastStatusDescription);
  }
  if (!context.UserCheckInAborted) {
    await workflow.respond("CreateTransaction");
    _dialogRef.updateStatus(context.LastStatusDescription);
    await PollPromise("WaitCreateTransaction", workflow);
    _dialogRef.updateStatus(context.LastStatusDescription);
    if (context.Type === "PAYMENT") {
      await PollPromise("WaitCustomerPayment", workflow);
      _dialogRef.updateStatus(context.LastStatusDescription);
      if (context.CaptureTransaction) {
        await workflow.respond("CaptureTransaction");
        _dialogRef.updateStatus(context.LastStatusDescription);
        await PollPromise("WaitCaptureTransaction", workflow);
        _dialogRef.updateStatus(context.LastStatusDescription);
      }
    }
  }
}

async function ShowQrOnCustomerDisplay(context) {
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
      } catch (ex) {
        console.error("Could not display Qr code on Customer Display: " + ex);
      }
    }
  }
}

async function HideQrOnCustomerDisplay(context) {
  if (context.request.QrOnCustomerDisplay) {
    try {
      await workflow.run("HTML_DISPLAY_QR", {
        context: {
          IsNestedWorkflow: true,
          QrShow: false,
          QrTitle: "MobilePay",
        },
      });
    } catch (ex) {
      console.error("Could not close qr on customer display: " + ex);
    }
  }
}

function PollPromise(Step, workflow) {
  return new Promise((resolve, reject) => {
    const pollFunction = async () => {
      try {
        const bc = await workflow.respond(Step);
        if (bc.Abort) {
          reject(new Error("Aborted"));
          return;
        }
        if (bc.Done) {
          resolve();
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
