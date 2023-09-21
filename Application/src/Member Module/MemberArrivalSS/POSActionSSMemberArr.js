let main = async ({workflow, popup, captions,parameters}) => {
    if (parameters.DefaultInputValue.length == 0 && parameters.DialogPrompt == 1){
        let result = await popup.input({caption: captions.MemberCardPrompt, title: captions.MembershipTitle, value: parameters.DefaultInputValue})
        if (result === null) {
            return(" ");
        }
        await workflow.respond("MemberArrival", {membercard_number: result});
    }
    else
    {
        await workflow.respond("MemberArrival");  
    }
};