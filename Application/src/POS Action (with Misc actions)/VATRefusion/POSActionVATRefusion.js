let main = async ({workflow, parameters, context, popup, captions, respond}) => {
    await workflow.respond("onBeforeRefusion");
    //Confirm Refussion 
    if ( (parameters.AskForConfirm == true) && (context.VATAmount != 0) ) {
        result = await popup.confirm({caption: captions.confirmRefussionTitle, label: captions.confirmRefussionLead.replace("%1",context.VATAmount)}); 
        if (!result) { return };      
    };
    //Inform user that Refussion is not possible
    if (context.VATAmount == 0) { 
        await popup.message({caption: captions.informRefussionNotPossibleTitle, label: captions.informRefussionNotPossibleLead});
        return;
    };
    //Do the Refussion
    if (context.VATAmount != 0) { 
        await workflow.respond("doRefussion"); 
    };
}