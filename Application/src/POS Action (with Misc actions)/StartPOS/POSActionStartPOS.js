let main = async ({workflow, context, captions, popup}) => {
    debugger;
    const{ConfirmBin, BinContents, BalancingIsNotAllowed, EoDActionCode} = await workflow.respond("OnBeforeStartPOS");
    if (ConfirmBin) {
        context.confirm = await popup.confirm({title: captions.bincontenttitle, caption: BinContents});
        if (!context.confirm) {
            if (BalancingIsNotAllowed) {
                popup.error(captions.BalancingIsNotAllowedError);
            } else {
                let confirmBalancing = await popup.confirm({title: captions.binbalancetitle, caption: captions.balancenow});
                if (confirmBalancing) {
                    workflow.run(EoDActionCode, {parameters: {Type: 1}})
                } else {
                    popup.message({ title: captions.notconfirmedbintitle, caption: captions.NotConfirmedBin, });
                }
            }
        } else {
            await workflow.respond("ConfirmBin");
        }
    }
}