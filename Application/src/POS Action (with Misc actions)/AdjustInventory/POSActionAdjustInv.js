let main = async ({ workflow, context, parameters, popup, captions }) => {
    debugger;
    var { AdjustInventoyCaption, UnitOfMeasureAssignmentPopUpSettings, UnitOfMeasureCode } = await workflow.respond("GetInventorySettings")
 
    if (parameters.AdjustmentUnitOfMeasure == 3) {
        var unitOfMeasureResponse = await popup.configuration(UnitOfMeasureAssignmentPopUpSettings);
        if (unitOfMeasureResponse === null) return;
        UnitOfMeasureCode = unitOfMeasureResponse.unitOfMeasure
    }

    var result = await popup.numpad({ title: AdjustInventoyCaption, caption: captions.QtyCaption });
    if (result === null) {
        return (" ");
    };
   
    await workflow.respond('GetReasonCode');
    if (workflow.context.reasonCode && parameters.CustomReasonDescription) {
        workflow.context.customDescription = await popup.input({ caption: captions.ReasonCodeCpt, value: workflow.context.defaultDescription });
    }

    await workflow.respond("AdjustInventory", { quantity: result, unitOfMeasureCode: UnitOfMeasureCode })

}