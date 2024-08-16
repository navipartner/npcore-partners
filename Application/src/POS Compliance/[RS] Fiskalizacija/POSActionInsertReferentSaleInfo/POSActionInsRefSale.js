const main = async ({workflow, context, parameters, captions}) => {
    await workflow.respond("AddPresetValuesToContext");

    ReferenceNo = await popup.input({ title: captions.title, caption: captions.ReferenceNoPrompt, required: true, value: context.defaultReferenceNo});
    if (ReferenceNo === "" || ReferenceNo === context.defaultReferenceNo) return;
    ReferenceDate = await popup.datepad({ title: captions.title, caption: captions.ReferenceDatePrompt, required: true, value: context.defaultReferenceDate});
    if (ReferenceDate === "") return;
    ReferenceTime = await popup.input({ title: captions.title, caption: captions.ReferenceTimePrompt, required: true, value: context.defaultReferenceTime});
    if (ReferenceTime === "") return;

    if(!isValidTimeFormat(ReferenceTime))
        return await popup.error(captions.ReferenceTimeFormatError);


    return await workflow.respond("InsertReferenceInfo", { ReferenceNo: ReferenceNo, ReferenceDate: ReferenceDate, ReferenceTime: ReferenceTime });
};

function isValidTimeFormat(time) {
    const timePattern = /^([01]\d|2[0-3]):([0-5]\d):([0-5]\d)$/;
    return timePattern.test(time);
}