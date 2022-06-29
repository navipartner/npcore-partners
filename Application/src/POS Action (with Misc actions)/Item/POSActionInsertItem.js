let main = async ({ workflow, context, scope, popup, parameters, captions }) => {

    workflow.context.GetPrompt = false;

    if (parameters.EditDescription) {
        workflow.context.Desc1 = await popup.input({ title: captions.editDesc_title, caption: captions.editDesc_lead, value: context.defaultDescription })
        if (workflow.context.Desc1 === null) {
            return (" ");
        }
    }

    if (parameters.EditDescription2) {
        workflow.context.Desc2 = await popup.input({ title: captions.editDesc2_title, caption: captions.editDesc2_lead, value: context.defaultDescription })
        if (workflow.context.Desc2 === null) {
            return (" ");
        }
    }

    const { ItemGroupSale, useSpecTracking, Success } = await workflow.respond("addSalesLine");

    if (!Success) {
        workflow.context.GetPrompt = true;

        if (ItemGroupSale && !parameters.usePreSetUnitPrice) {
            workflow.context.UnitPrice = await popup.numpad({ title: captions.UnitpriceTitle, caption: captions.UnitPriceCaption })
            if (workflow.context.UnitPrice === null) {
                return (" ");
            }
        }

        if (useSpecTracking && !parameters.SelectSerialNo) {
            workflow.context.SerialNo = await popup.input({ title: captions.itemTracking_title, caption: captions.itemTracking_lead })
            if (workflow.context.SerialNo === null) {
                return (" ");
            }
        }
        workflow.context.useSpecTracking = useSpecTracking;
        await workflow.respond("addSalesLine");

    }


}