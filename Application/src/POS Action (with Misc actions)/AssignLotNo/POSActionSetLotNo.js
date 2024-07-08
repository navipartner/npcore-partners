let main = async ({ workflow, context, scope, popup, parameters, captions }) => {
    
    const { hasLotNo, hasLotNoResponseMessage, requiresLotNo, useSpecificTracking} = await workflow.respond("CheckLineTracking");
    if (hasLotNo) {
          if (!await popup.confirm(hasLotNoResponseMessage)) {
                return("");
            }
    }

    if (requiresLotNo || !useSpecificTracking) {
        workflow.context.LotNoInput = await popup.input({ title: captions.itemLotNo_title, caption: captions.itemLotNo_lead })
        if (workflow.context.LotNoInput === null) {
            return ("");
        }
    } 

    await workflow.respond("AssignLotNo");

}