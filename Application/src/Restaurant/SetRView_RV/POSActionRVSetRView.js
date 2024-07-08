let main = async ({ context }) => {
    await workflow.respond();

    if (context.ShowResultMessage) {
        popup.message(context.ResultMessageText);
    };
}