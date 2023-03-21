let main = async ({workflow, popup}) => {

    const{BaseLineNo, ApplyItemAddOnNo, CompulsoryAddOn, UserSelectionRequired,ItemAddonConfigAsString} = await workflow.respond("GetSalesLineAddonConfigJson");
    if (UserSelectionRequired){
        let AddonConfig = JSON.parse(ItemAddonConfigAsString); 
        UserSelectedAddons = await popup.configuration(AddonConfig);
        await workflow.respond("SetItemAddons",{BaseLineNo: BaseLineNo, ApplyItemAddOnNo:ApplyItemAddOnNo, CompulsoryAddOn: CompulsoryAddOn, UserSelectionRequired: UserSelectionRequired, UserSelectedAddons:UserSelectedAddons});
    }
    else
    {
        await workflow.respond("SetItemAddons",{BaseLineNo: BaseLineNo, ApplyItemAddOnNo:ApplyItemAddOnNo, CompulsoryAddOn: CompulsoryAddOn, UserSelectionRequired: UserSelectionRequired});

    }
    
}

