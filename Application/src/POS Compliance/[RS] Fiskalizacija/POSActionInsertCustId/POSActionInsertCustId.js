let main = async ({ workflow, captions, parameters }) => {
    let NewCustIdentification;

    if (parameters.EditCustIdentification == parameters.EditCustIdentification["Yes"]) {
        NewCustIdentification = parameters.DefaultCustIdentification + await popup.input({ caption: captions.prompt });
    }

    if (NewCustIdentification === null || NewCustIdentification === "") return;
    return await workflow.respond("InsertCustIdentification", { NewCustIdentification: NewCustIdentification });
};