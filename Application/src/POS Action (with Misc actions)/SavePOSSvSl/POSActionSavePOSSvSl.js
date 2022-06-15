let main = async ({parameters,captions}) => {
    if (parameters.ConfirmBeforeSave){
        if (await popup.confirm(parameters.ConfirmText,captions.ConfirmLabel, true, true)){
            return await workflow.respond("save_as_quote");            
        }
        
    } else
    {
        return await workflow.respond("save_as_quote");
    }
    
};