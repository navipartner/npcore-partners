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

    var { bomComponentLinesWithoutSerialNo, requiresUnitPriceInputPrompt, requiresSerialNoInputPrompt, requiresAdditionalInformationCollection, addItemAddOn, baseLineNo, postAddWorkflows } = await workflow.respond("addSalesLine");

    if (requiresAdditionalInformationCollection) {

        if (requiresUnitPriceInputPrompt) {
            context.unitPriceInput = await popup.numpad({ title: captions.UnitPriceTitle, caption: captions.unitPriceCaption })
            if (context.unitPriceInput === null) return;
        }

        if (requiresSerialNoInputPrompt) {
            context.serialNoInput = await popup.input({ title: captions.itemTracking_title, caption: captions.itemTracking_lead })
            if (context.serialNoInput === null) return;
        }

        context.additionalInformationCollected = true;
        var { bomComponentLinesWithoutSerialNo, addItemAddOn, baseLineNo, postAddWorkflows } = await workflow.respond("addSalesLine");
    }

    await processBomComponentLinesWithoutSerialNo(bomComponentLinesWithoutSerialNo, workflow, context, parameters, popup, captions);

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

async function processBomComponentLinesWithoutSerialNo(bomComponentLinesWithoutSerialNo, workflow, context, parameters, popup, captions) {
    if (!bomComponentLinesWithoutSerialNo) return

    for (var i = 0; i < bomComponentLinesWithoutSerialNo.length; i++) {

        let continueExecution = true;
        let response;

        while (continueExecution) {
            continueExecution = false;

            context.serialNoInput = '';
            context.bomComponentLineWithoutSerialNo = bomComponentLinesWithoutSerialNo[i];

            if (parameters.SelectSerialNo && context.bomComponentLineWithoutSerialNo.requiresSpecificSerialNo) {
                response = await workflow.respond("assignSerialNo");

                if (!response.assignSerialNoSuccess && response.assignSerialNoSuccessErrorText) {
                    if (await popup.confirm({ title: captions.serialNoError_title, caption: response.assignSerialNoSuccessErrorText })) continueExecution = true;
                }
            }
            else {
                context.serialNoInput = await popup.input({ title: captions.itemTracking_title, caption: format(captions.bomItemTracking_Lead, context.bomComponentLineWithoutSerialNo.description, context.bomComponentLineWithoutSerialNo.parentBOMDescription) })

                if (context.serialNoInput) {
                    response = await workflow.respond("assignSerialNo");

                    if (!response.assignSerialNoSuccess && response.assignSerialNoSuccessErrorText) {
                        if (await popup.confirm({ title: captions.serialNoError_title, caption: response.assignSerialNoSuccessErrorText })) continueExecution = true;
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