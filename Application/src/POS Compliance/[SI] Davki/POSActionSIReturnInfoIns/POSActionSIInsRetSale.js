const main = async ({workflow, context, parameters, captions}) => {
    await workflow.respond("AddPresetValuesToContext");

    ReturnReceiptNo = await popup.input({ title: captions.title, caption: captions.ReturnReceiptNoPrompt, required: true});
    if (ReturnReceiptNo === null) return;
    ReturnBusinessPremiseId = await popup.input({ title: captions.title, caption: captions.ReturnBusinessPremiseIdPrompt, required: true});
    if (ReturnBusinessPremiseId === null) return;
    ReturnCashRegisterId = await popup.input({ title: captions.title, caption: captions.ReturnCashRegisterIdPrompt, required: true});
    if (ReturnCashRegisterId === null) return;
    ReturnDate = await popup.datepad({ title: captions.title, caption: captions.ReturnDatePrompt, required: true, value: context.defaultReturnDate});
    if (ReturnDate === null) return;
    ReturnTime = await popup.input({ title: captions.title, caption: captions.ReturnTimePrompt, required: true, value: context.defaultReturnTime});
    if (ReturnTime === null) return;

    if(!isValidTimeFormat(ReturnTime))
        return await popup.error(captions.ReturnTimeFormatError);

    return await workflow.respond("InsertReturnInfo", { ReturnReceiptNo: ReturnReceiptNo, ReturnBusinessPremiseId: ReturnBusinessPremiseId, ReturnCashRegisterId: ReturnCashRegisterId, ReturnDate: ReturnDate, ReturnTime: ReturnTime });
};

function isValidTimeFormat(time) {
    const timePattern = /^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/;
    return timePattern.test(time);
}