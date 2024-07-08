let main = async ({ workflow, captions, parameters }) => {
    let NewAddCustField;

    if (parameters.EditAddCustField == parameters.EditAddCustField["Yes"]) {
        NewAddCustField = parameters.DefaultAddCustField + await popup.input({ caption: captions.prompt });
    }

    if (NewAddCustField === null || NewAddCustField === "") return;
    return await workflow.respond("InsertAddCustField", { NewAddCustField: NewAddCustField });
};