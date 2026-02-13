let main = async ({ workflow, popup, parameters, captions, context }) => {
    const { newEmailExperienceEnabled, sendGridTemplateId } = await workflow.respond('getContext');

    var hasOldTemplate = parameters.EmailTemplate && parameters.EmailTemplate !== '';
    var hasNewTemplate = sendGridTemplateId && sendGridTemplateId !== '';

    if (newEmailExperienceEnabled) {
        if (!hasNewTemplate) {
            popup.error('Please set an E-mail Template on the POS Receipt Profile before sending.');
            return;
        }
    } else {
        if (!hasOldTemplate) {
            popup.error('Please set an E-mail Template before sending.');
            return;
        }
    }

    if ((parameters.SelectionDialogType == parameters.SelectionDialogType["TextField"]) &&
        ((parameters.Setting == parameters.Setting["Choose Receipt"]) ||
            (parameters.Setting == parameters.Setting["Choose Receipt Large"]))) {
        var result = await popup.input({ title: captions.Title, caption: captions.EnterReceiptNoLbl, value: "" })
        if (result == null) {
            return (" ")
        }
    }

    await workflow.respond('setReceipt', { ManualReceiptNo: result });

    workflow.context.receiptAddress = await popup.input({ caption: captions.EmailCpt, title: captions.EmailTitle, value: context.defaultEmail });
    if (workflow.context.receiptAddress === null || workflow.context.receiptAddress === "") return;
    await workflow.respond("sendReceiptNo");
    if (context.status) {
        popup.error(context.status);
    } else {
        popup.message('E-mail has been successfully sent.');
    }
}