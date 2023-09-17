let main = async ({workflow, popup, captions}) => {

    let result = await popup.input({title: captions.title, caption: captions.voucherprompt});
    if (result === null) {
        return;
    }
    await workflow.respond("VerifyCoupon", { ReferenceNo: result })
};