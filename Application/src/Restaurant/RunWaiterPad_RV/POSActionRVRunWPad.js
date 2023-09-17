let main = async ({workflow, context, popup}) => {
    await workflow.respond();
    if (context.ShowResultMessage) {
    popup.message(context.ResultMessageText);
    };
};