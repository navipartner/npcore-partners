const DYNAMIC_CAPTION_CURR_PRICE = "#CURRPRICE#";
const DYNAMIC_CAPTION_HAS_CURR_PRICE = 1;

let main = async ({ workflow, context, popup, parameters, captions }) => {

    debugger;
    context.additionalInformationCollected = false;

    if (parameters.EditDescription) {
        context.desc1 = await popup.input({ title: captions.editDesc_title, caption: captions.editDesc_lead, value: context.defaultDescription })
        if (context.desc1 === null) return;
    }

    if (parameters.EditDescription2) {
        context.desc2 = await popup.input({ title: captions.editDesc2_title, caption: captions.editDesc2_lead, value: context.defaultDescription })
        if (context.desc2 === null) return;
    }

    var { bomComponentLinesWithoutSerialLotNo, requiresUnitPriceInputPrompt, requiresSerialNoInputPrompt,requiresLotNoInputPrompt, requiresAdditionalInformationCollection, addItemAddOn, baseLineNo, postAddWorkflows, ticketToken, itemNoId, itemReferenceId } = await workflow.respond("addSalesLine");

    if (ticketToken) {
        const scheduleSelection = await workflow.run('TM_SCHEDULE_SELECT', {
            context: {
                TicketToken: ticketToken,
                EditSchedule: true
            }
        })
        debugger;
        if (scheduleSelection.cancel) {
            await workflow.respond("cancelTicketItemLine");
            return;
        }
    }
    if (requiresAdditionalInformationCollection) {

        if (requiresUnitPriceInputPrompt) {
            context.unitPriceInput = await popup.numpad({ title: captions.UnitPriceTitle, caption: captions.unitPriceCaption })
            if (context.unitPriceInput === null) return;
        }

        if (requiresSerialNoInputPrompt) {
            context.serialNoInput = await popup.input({ title: captions.itemTracking_title, caption: captions.itemTracking_lead })
            if (context.serialNoInput === null) return;
        }
        if (requiresLotNoInputPrompt) {
            context.lotNoInput = await popup.input({ title: captions.itemTrackingLotNo_title, caption: captions.itemTrackingLot_lead })
            if (context.lotNoInput === null) return;
        }

        context.additionalInformationCollected = true;
        context.itemNoId = itemNoId;
        context.itemReferenceId = itemReferenceId;
        var { bomComponentLinesWithoutSerialLotNo, addItemAddOn, baseLineNo, postAddWorkflows } = await workflow.respond("addSalesLine");
        
    }

    await processBomComponentLinesWithoutSerialNoLotNo(bomComponentLinesWithoutSerialLotNo, workflow, context, parameters, popup, captions);

    if (addItemAddOn) {
        await workflow.run('RUN_ITEM_ADDONS', { context: { baseLineNo: baseLineNo }, parameters: { SkipItemAvailabilityCheck: true } });
        await workflow.respond("checkAvailability");
    }

    if (postAddWorkflows) {
        for (const postWorkflow of Object.entries(postAddWorkflows)) {
            let [postWorkflowName, postWorkflowParameters] = postWorkflow;
            if (postWorkflowName) {
                await workflow.run(postWorkflowName, { parameters: postWorkflowParameters });
            };
        };
    };
}

const getButtonCaption = async ({ workflow, context }) => {
  debugger;
  const types = getDynamicCaptionTypes(context.currentCaptions);
  if (types.length <= 0) {
    return context.currentCaptions;
  }

  let captions = { ...context.currentCaptions };

  if (types.includes(DYNAMIC_CAPTION_HAS_CURR_PRICE)) {
    const currentItemPrice = await workflow.respondInNewSession("getCurrentItemPriceCaption");
    if (currentItemPrice) {
      captions.caption = captions.caption?.replace(DYNAMIC_CAPTION_CURR_PRICE, currentItemPrice);
      captions.secondCaption = captions.secondCaption?.replace(DYNAMIC_CAPTION_CURR_PRICE, currentItemPrice);
      captions.thirdCaption = captions.thirdCaption?.replace(DYNAMIC_CAPTION_CURR_PRICE, currentItemPrice);
    }
  };

  return captions;
}

function getDynamicCaptionTypes(captions) {
  const types = [];

  if (
    captions.caption?.includes(DYNAMIC_CAPTION_CURR_PRICE) ||
    captions.secondCaption?.includes(DYNAMIC_CAPTION_CURR_PRICE) ||
    captions.thirdCaption?.includes(DYNAMIC_CAPTION_CURR_PRICE)
  ) {
    types.push(DYNAMIC_CAPTION_HAS_CURR_PRICE);
  }

  return types;
}

async function processBomComponentLinesWithoutSerialNoLotNo(bomComponentLinesWithoutSerialLotNo, workflow, context, parameters, popup, captions) {
    if (!bomComponentLinesWithoutSerialLotNo) return
    debugger;

    for (var i = 0; i < bomComponentLinesWithoutSerialLotNo.length; i++) {

        let continueExecution = true;
        let response;

        while (continueExecution) {
            continueExecution = false;

            context.serialNoInput = '';
            context.lotNoInput = '';
            context.bomComponentLineWithoutSerialLotNo = bomComponentLinesWithoutSerialLotNo[i];
            
            if(context.bomComponentLineWithoutSerialLotNo.requiresSerialNoInput){
                if ((parameters.SelectSerialNo && !parameters.SelectSerialNoListEmptyInput) && context.bomComponentLineWithoutSerialLotNo.useSpecTrackingSerialNo) {
                    response = await workflow.respond("assignSerialNo");

                    if (!response.assignSerialNoSuccess && response.assignSerialNoSuccessErrorText) {
                        if (await popup.confirm({ title: captions.serialNoError_title, caption: response.assignSerialNoSuccessErrorText })) continueExecution = true;
                    }
                }
                else {                
                    context.serialNoInput = await popup.input({ title: captions.itemTracking_title, caption: format(captions.bomItemTracking_Lead, context.bomComponentLineWithoutSerialLotNo.description, context.bomComponentLineWithoutSerialLotNo.parentBOMDescription) })

                    if (context.serialNoInput || parameters.SelectSerialNoListEmptyInput) {
                        response = await workflow.respond("assignSerialNo");

                        if (!response.assignSerialNoSuccess && response.assignSerialNoSuccessErrorText) {
                            if (await popup.confirm({ title: captions.serialNoError_title, caption: response.assignSerialNoSuccessErrorText })) continueExecution = true;
                        }
                    }
                }
            }
            if (context.bomComponentLineWithoutSerialLotNo.requiresLotNoInput) {
                if ((parameters.SelectLotNo == 1) && context.bomComponentLineWithoutSerialLotNo.useSpecTrackingLotNo) {
                    response = await workflow.respond("assignLotNo");

                    if (!response.assignLotNoSuccess && response.assignLotNoSuccessErrorText) {
                        if (await popup.confirm({ title: captions.lotNoError_title, caption: response.assignLotNoSuccessErrorText })) continueExecution = true;
                    }
                }
                else {
                    context.lotNoInput = await popup.input({ title: captions.ItemTrackingLot_TitleLbl, caption: format(captions.bomItemTrackingLot_Lead, context.bomComponentLineWithoutSerialLotNo.description, context.bomComponentLineWithoutSerialLotNo.parentBOMDescription) })

                    if ((context.lotNoInput) || (parameters.SelectLotNo == 2))  {
                        response = await workflow.respond("assignLotNo");
    
                        if (!response.assignLotNoSuccess && response.assignLotNoSuccessErrorText) {
                            if (await popup.confirm({ title: captions.lotNoError_title, caption: response.assignLotNoSuccessErrorText })) continueExecution = true;
                        }
                    }
                }
            }
        }
    }
}


function format(fmt, ...args) {
    if (!fmt.match(/^(?:(?:(?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{[0-9]+\}))+$/)) {
        throw new Error('invalid format string.');
    }
    return fmt.replace(/((?:[^{}]|(?:\{\{)|(?:\}\}))+)|(?:\{([0-9]+)\})/g, (m, str, index) => {
        if (str) {
            return str.replace(/(?:{{)|(?:}})/g, m => m[0]);
        } else {
            if (index >= args.length) {
                throw new Error('argument index is out of range in format');
            }
            return args[index];
        }
    });
}