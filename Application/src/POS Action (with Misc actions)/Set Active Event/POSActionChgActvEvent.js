let main = async ({workflow, parameters, popup, captions}) => { 
    if ((!parameters.ClearEvent) && (parameters.DialogType == parameters.DialogType["TextField"]))
    {
        var result = await popup.input({ title: captions.confirmTitle, caption: captions.confirmLead, value: "" });
        if (result == null)
        {
            return;
        }
    };
    await workflow.respond('ProcessChange', {textfield: result});
 };