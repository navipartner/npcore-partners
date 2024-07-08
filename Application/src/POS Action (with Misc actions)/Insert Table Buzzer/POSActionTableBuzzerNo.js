let main = async ({ workflow, captions, parameters, context }) => {
    if (parameters.DialogType == parameters.DialogType["TextField"]) {
        context.input = await popup.input({ caption: captions.prompt });
    }
    else {
        context.input = await popup.numpad({ caption: captions.prompt });
    }
    //blank input ok, cancel is not
    if (context.input === null) {
        return;
    }
    await workflow.respond();
};