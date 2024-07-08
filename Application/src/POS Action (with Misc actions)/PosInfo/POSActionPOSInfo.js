let main = async ({ workflow, context, popup, parameters, captions}) => {
    await workflow.respond("SelectPosInfo")
    while (context.AskForPosInfoText) {
        context.UserInputString = await popup.input({title: context.PopupTitle, caption: context.FieldDescription, required: context.InputMandatory})
        if ((context.InputMandatory) && (!context.UserInputString)) { 
            let DoRetry = await popup.confirm({title: context.FieldDescription, caption: captions.ConfirmRetry})
            if (!DoRetry) {
                return;
            }
        } else {
            await workflow.respond("ValidateUserInput")
        }
    }
}