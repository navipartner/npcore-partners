let main = async ({workflow, context, popup, parameters, captions}) => {
    let AddPhotoTo = parameters.AddPhotoToSelection;

    if (AddPhotoTo == 3){
        workflow.context.PosEntry_DocumentNo = await popup.input({title: captions.SelectPosEntryByDocumentNo, caption: captions.DocumentNo});
        if (workflow.context.PosEntry_DocumentNo === null){
            return;
        } 
        if (workflow.context.PosEntry_DocumentNo == "" || workflow.context.PosEntry_DocumentNo.length > 20){
            popup.error(captions.InvalidDocumentNo);
            return;
        }
    }
    return await workflow.respond();
};