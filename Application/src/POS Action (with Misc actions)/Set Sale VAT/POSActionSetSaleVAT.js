let main = async ({workflow, parameters, popup, captions}) => { 
    if (parameters.ConfirmDialog)
    {
        if (!await popup.confirm({ title: captions.confirmTitle, caption: captions.confirmLead })) {
            return;
        };
    };
    await workflow.respond();
 };