let main = async ({ workflow, popup, context, captions }) => {
    let { AskForApplyToLine, ApplyToDialogOptions } = await workflow.respond("DefineBaseLineNo");
    if (AskForApplyToLine) {
        let result = await popup.optionsMenu({ title: captions.SelectLine, oneTouch: true, options: ApplyToDialogOptions });
        if (!result) {
            return;
        };
        context.BaseLineNo = result.id;
    };
    let { ApplyItemAddOnNo, CompulsoryAddOn, UserSelectionRequired, ItemAddonConfigAsString } = await workflow.respond("GetSalesLineAddonConfigJson");
    if (UserSelectionRequired) {
        let AddonConfig = JSON.parse(ItemAddonConfigAsString);
        UserSelectedAddons = await popup.configuration(AddonConfig);
        await workflow.respond("SetItemAddons", { ApplyItemAddOnNo: ApplyItemAddOnNo, CompulsoryAddOn: CompulsoryAddOn, UserSelectionRequired: UserSelectionRequired, UserSelectedAddons: UserSelectedAddons });
    }
    else {
        await workflow.respond("SetItemAddons", { ApplyItemAddOnNo: ApplyItemAddOnNo, CompulsoryAddOn: CompulsoryAddOn, UserSelectionRequired: UserSelectionRequired });
    }
}
