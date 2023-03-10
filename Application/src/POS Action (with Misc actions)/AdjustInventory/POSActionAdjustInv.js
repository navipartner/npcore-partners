let main = async ({ workflow, context, parameters, popup, captions }) => {

    const { AdjustInventoyCaption } = await workflow.respond("GetInventoryCaption")

    var result = await popup.numpad({ title: AdjustInventoyCaption, caption: captions.QtyCaption });
    if (result === null) {
        return (" ");
    };

    await workflow.respond('GetReasonCode');
    if (workflow.context.reasonCode && parameters.CustomReasonDescription) {
        workflow.context.customDescription = await popup.input({ caption: captions.ReasonCodeCpt, value: workflow.context.defaultDescription });
    }

    await workflow.respond("AdjustInventory", { quantity: result })

}