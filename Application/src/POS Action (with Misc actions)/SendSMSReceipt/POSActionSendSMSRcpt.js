const main = async ({ workflow, popup, parameters, captions, context }) => {
    if (!parameters.SMSTemplate) {
        popup.error(captions.SMSTemplateErr);
        return;
    };

    if ((parameters.SelectionDialogType == parameters.SelectionDialogType.["TextField"]) &&
        ((parameters.Setting == parameters.Setting["Choose Receipt"]) ||
            (parameters.Setting == parameters.Setting["Choose Receipt Large"]))) {
        var result = await popup.input({ title: captions.Title, caption: captions.EnterReceiptNoLbl, value: "" })
        if (result == null) {
            return (" ")
        }
    }
    await workflow.respond('setReceipt', { ManualReceiptNo: result });

    workflow.context.receiptPhoneNo = await popup.input({ caption: captions.SMSCpt, title: captions.SMSTitle, value: context.defaultPhoneNo });
    if (workflow.context.receiptPhoneNo === null || workflow.context.receiptPhoneNo === "") return;
    await workflow.respond("sendSMS");
    if (context.status) {
        popup.error(context.status);
    } else {
        popup.message(captions.SMSSent);
    }
}