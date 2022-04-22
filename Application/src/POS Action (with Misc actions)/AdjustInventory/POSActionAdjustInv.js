let main = async ({workflow, context, parametars, popup, captions}) => {

    const {AdjustInventoyCaption}= await workflow.respond ("GetInventoryCaption")

    var result = await popup.numpad({title: AdjustInventoyCaption, caption: captions.QtyCaption});
    if (result === null) {
        return (" ");
    }
    await workflow.respond ("AdjustInventory",{quantity: result})
    
}