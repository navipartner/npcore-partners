let main = async ({workflow , context, popup, captions}) => {
    windowTitle = captions.Welcome;
    context.input_reference_no = await popup.input({ title: captions.InputReferenceNoTitle, caption: captions.InputReferenceNo });
    if (context.input_reference_no === null) return;
    const actionResponse = await workflow.respond("validate_reference");

    if (actionResponse.success) {
        toast.success (`Welcome ${actionResponse.table_capt} ${actionResponse.reference_no}`, {title: windowTitle});
    }
};