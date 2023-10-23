let main = async ({ workflow, parameters, popup, context, captions }) => {
    debugger;
    let voucher_input;
    let response = { tryEndSale: false, legacy: false };

    if (parameters.VoucherTypeCode) {
        workflow.context.voucherType = parameters.VoucherTypeCode
    } else if (parameters.AskForVoucherType) {
        workflow.context.voucherType = await workflow.respond("setVoucherType");
        if (!workflow.context.voucherType) return response;
    }

    if (parameters.ReferenceNo) {
        voucher_input = parameters.ReferenceNo;
    } else {
        voucher_input = await popup.input({ title: captions.VoucherPaymentTitle, caption: captions.ReferenceNo })
    };

    if (voucher_input === null) return response;

    const { selectedVoucherReferenceNo, askForAmount, suggestedAmount, paymentDescription, amountPrompt, voucherType } = await workflow.respond("calculateVoucherInformation", { VoucherRefNo: voucher_input });
    workflow.context.voucherType = voucherType;
    if (!workflow.context.voucherType) return response;

    voucher_input = selectedVoucherReferenceNo
    if (!voucher_input) return response;

    let selectedAmount = suggestedAmount;
    if (askForAmount) {

        var validateSuggestedAmount = true;
        while (validateSuggestedAmount) {

            selectedAmount = suggestedAmount;
            if (suggestedAmount > 0) {
                selectedAmount = await popup.numpad({ title: paymentDescription, caption: amountPrompt, value: suggestedAmount });
                if (selectedAmount === null) return response; // user cancelled dialog
            }

            validateSuggestedAmount = selectedAmount > suggestedAmount;
            if (validateSuggestedAmount) {
                await popup.message(strSubstNo(captions.ProposedAmountDifferenceConfirmation, selectedAmount, suggestedAmount));
            }
        };
    }

    let result = await workflow.respond("prepareRequest", { VoucherRefNo: voucher_input, selectedAmount: selectedAmount });
    if (result.tryEndSale) {
        if ((parameters.EndSale) && (!result.endSaleWithoutPosting)) {
            await workflow.respond("endSale");
        };
        return response;
    };

    if (result.workflowVersion == 1) {
        await workflow.respond("doLegacyWorkflow", { workflowName: result.workflowName });
    } else {
        await workflow.run(result.workflowName, { parameters: result.parameters })
    };

    return response;

};

function strSubstNo(fmt, ...args) {
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