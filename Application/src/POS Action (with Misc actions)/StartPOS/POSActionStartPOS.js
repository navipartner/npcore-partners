let main = async ({workflow, context, captions, popup}) => {
    debugger;
    const{ConfirmBin, BinContents, BalancingIsNotAllowed, EoDActionCode} = await workflow.respond("OnBeforeStartPOS");
    if (ConfirmBin) {
        await workflow.respond('OpenCashDrawer');
        context.confirm = await popup.confirm({title: captions.bincontenttitle, caption: BinContents});
        if (!context.confirm) {
            if (BalancingIsNotAllowed) {
                popup.error(captions.BalancingIsNotAllowedError);
            } else {
                await workflow.run(EoDActionCode, {parameters: {Type: 1}})
            }
        } else {
            await workflow.respond("ConfirmBin");
        }
    }
}