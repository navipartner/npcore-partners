let main = async ({ workflow, popup, parameters, captions }) => {
    let voucher_input = await popup.stringpad({ title: captions.ApplyVoucherCaption, caption: captions.EnterRefNoCaption });
    if ((voucher_input === null) || (voucher_input === "")) { return };

    let result = await workflow.respond("prepareRequest", { VoucherRefNo: voucher_input });
    if (result.tryEndSale) {
        if (parameters.EndSale) {
            await workflow.respond("endSale");
        };
        return;
    };

    if (result.workflowVersion == 1) {
        await workflow.respond("doLegacyWorkflow", { workflowName: result.workflowName });
    } else {
        await workflow.run(result.workflowName, { parameters: result.parameters })
    };
};