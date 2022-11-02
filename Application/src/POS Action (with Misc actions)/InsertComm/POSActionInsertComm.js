let main = async ({ workflow, captions, parameters }) => {
    let NewDescription;

    if (parameters.EditDescription == parameters.EditDescription["Yes"]) {
        NewDescription = await popup.input({ caption: captions.prompt, value: parameters.DefaultDescription });
    } else {
        NewDescription = parameters.DefaultDescription;
    }

    if (NewDescription === null || NewDescription === "") return;
    return await workflow.respond("InsertComment", { NewDescription: NewDescription });
};