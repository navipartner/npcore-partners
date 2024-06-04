let main = async ({ workflow, context, scope, popup, parameters, captions }) => {
    
    const { hasSerialNo, hasSerialNoResponseMessage, requiresSerialNo, useSpecificTracking} = await workflow.respond("CheckLineTracking");
    if (hasSerialNo) {
          if (!await popup.confirm(hasSerialNoResponseMessage)) {
                return("");
            }
    }

    if (!parameters.SelectSerialNo || !useSpecificTracking || (parameters.SelectSerialNo && parameters.SelectSerialNoListEmptyInput)) {
        workflow.context.SerialNoInput = await popup.input({ title: captions.itemTracking_title, caption: captions.itemTracking_lead })
        if (workflow.context.SerialNoInput === null) {
            return ("");
        }
    } 

    await workflow.respond("AssignSerialNo");

}