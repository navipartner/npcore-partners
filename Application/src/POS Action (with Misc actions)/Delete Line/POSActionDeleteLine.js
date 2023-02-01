let main = async ({workflow,parameters, captions}) => {
    let saleLines = runtime.getData("BUILTIN_SALELINE");
    if ((!saleLines.length) || (saleLines._invalid)) {
        await popup.error(captions.notallowed);
        return;
    };

    if (parameters.ConfirmDialog) {
        if (!await popup.confirm({ title: captions.title, caption: captions.Prompt.substitute(saleLines._current[10]) })) {
            return;
        };
    };
    workflow.respond();
};