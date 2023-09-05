let main = async ({ workflow, context, scope, popup, parameters, captions }) => {

    debugger;
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

    const {childBOMLinesWithoutSerialNo, ItemGroupSale, useSpecTracking, GetPromptSerial, Success, AddItemAddOn, BaseLineNo, postAddWorkflows} = await workflow.respond("addSalesLine");

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

        if (!useSpecTracking && GetPromptSerial) {
            workflow.context.SerialNo = await popup.input({ title: captions.itemTracking_title, caption: captions.itemTracking_lead })
            if (workflow.context.SerialNo === null) {
                return (" ");
            }
        }
        workflow.context.useSpecTracking = useSpecTracking;
        await workflow.respond("addSalesLine");
    }
    else {

        for(var bomLineKey = 0; bomLineKey < childBOMLinesWithoutSerialNo.length; bomLineKey++) {
            
            var ContinueExecution = true;
            var response;

            while (ContinueExecution) {
                ContinueExecution = false;

                if ((bomLineKey != "remove") && (bomLineKey != "add") && (bomLineKey != "addRange") && (bomLineKey != "aggregate")) {
                    
                    workflow.context.SerialNo = '';
                    workflow.context.childBOMLineWithoutSerialNo = childBOMLinesWithoutSerialNo[bomLineKey];

                    if (parameters.SelectSerialNo && workflow.context.childBOMLineWithoutSerialNo.useSpecTracking){
                        response = await workflow.respond("assignSerialNo");
                        
                        if(!response.AssignSerialNoSuccess && response.AssignSerialNoSuccessErrorText)
                        {
                            if (await popup.confirm({title: captions.serialNoError_title, caption: response.AssignSerialNoSuccessErrorText})) {
                                ContinueExecution = true;
                            }
    
                        }
                    } 
                    else{
                        workflow.context.SerialNo = await popup.input({ title: captions.itemTracking_title, caption: format(captions.bomItemTracking_Lead, workflow.context.childBOMLineWithoutSerialNo.description, workflow.context.childBOMLineWithoutSerialNo.parentBOMDescription)})
                            
                        if (workflow.context.SerialNo) {

                            response = await workflow.respond("assignSerialNo");
                                    
                            if(!response.AssignSerialNoSuccess && response.AssignSerialNoSuccessErrorText)
                            {
                                if (await popup.confirm({title: captions.serialNoError_title, caption: response.AssignSerialNoSuccessErrorText})) {
                                    ContinueExecution = true;
                                }
        
                            }
                        }
                    }
                }
            }
        }

        
        
    }

    if (AddItemAddOn) {
        await workflow.run('RUN_ITEM_ADDONS', { context: { BaseLineNo: BaseLineNo }, parameters: { SkipItemAvailabilityCheck: true } });
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