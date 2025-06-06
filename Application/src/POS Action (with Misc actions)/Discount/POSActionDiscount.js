let main = async ({ workflow, captions, parameters, popup }) => {
    debugger;
    let discountNumber, discountLabel, dimensionCode;
    //not in backend due to workflow steps order
    let discountReason = { "discountReason": parameters.FixedReasonCode };

    if (discountReason.discountReason == "") {
        if (parameters.LookupReasonCode || parameters.ReasonCodeMandatory) {
            discountReason = await workflow.respond("LookupReasonCode");
        };
    };

    dimensionCode = parameters.DimensionCode;
    let dimensionValue = { "dimensionValue": parameters.DimensionValue };
    if (dimensionCode != "") {
        if (dimensionValue.dimensionValue == "") {
            dimensionValue = await workflow.respond("AddDimensionValue");
        }
    };

    discountNumber = parameters.FixedDiscountNumber;
    switch (parameters._parameters.DiscountType) {
        case 0:
            discountLabel = captions.DiscountLabel0;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 1:
            discountLabel = captions.DiscountLabel1;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 2:
            discountLabel = captions.DiscountLabel2;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 3:
            discountLabel = captions.DiscountLabel3;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 4:
            discountLabel = captions.DiscountLabel4;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 5:
            discountLabel = captions.DiscountLabel5;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 6:
            discountLabel = captions.DiscountLabel6;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 7:
            discountLabel = captions.DiscountLabel7;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 8:
            discountLabel = captions.DiscountLabel8;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 9:
            break;
        case 10:
            break;
        case 11:
            discountLabel = captions.DiscountLabel11;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
        case 12:
            discountLabel = captions.DiscountLabel12;
            if (discountNumber == 0) {
                discountNumber = await popup.numpad(discountLabel);
            }
            break;
    };

    if (discountNumber === null) return;

    await workflow.respond("ProcessRequest", { discountNumber: discountNumber, discountReason, dimensionValue });
    
    let {postWorkflows} = await workflow.respond("PreparePostWorkflows");
    await processWorkflows(postWorkflows);
    return;
};

async function processWorkflows(workflows) {
  if (!workflows) return;

  for (const [workflowName, { mainParameters, customParameters },] of Object.entries(workflows)) {
    await workflow.run(workflowName, {context: { customParameters },parameters: mainParameters,});
  }
}
