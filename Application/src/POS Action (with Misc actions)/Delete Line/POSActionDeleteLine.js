let main = async ({ workflow, parameters, captions }) => {
    debugger;
    var getCurrentViewTypeResponse = await workflow.respond('GetCurrentViewType');
    var currLine;

    switch (getCurrentViewTypeResponse.viewType) {
        case "Payment":
            currLine = runtime.getData("BUILTIN_PAYMENTLINE");
            break;
        default:
            currLine = runtime.getData("BUILTIN_SALELINE");
    }

    if ((!currLine.length) || (currLine._invalid)) {
        await popup.error(captions.notallowed);
        return;
    };

    if (parameters.ConfirmDialog) {
        if (!await popup.confirm({ title: captions.title, caption: captions.Prompt.substitute(currLine._current[10]) })) {
            return;
        };
    };
    workflow.respond('DeletePosLine');
};