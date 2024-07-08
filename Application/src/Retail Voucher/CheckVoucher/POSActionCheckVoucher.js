let main = async ({ workflow, captions, popup }) => {
    let result = await popup.input({ title: captions.title, caption: captions.referencenoprompt, required: true });
    if (result === null || result === "") return;

    if (Object.keys(result).length > 50) {
        await popup.error(captions.tooLongErr);
        return;
    }
    return await workflow.respond("ProcessVoucher", { ReferenceNo: result })
};