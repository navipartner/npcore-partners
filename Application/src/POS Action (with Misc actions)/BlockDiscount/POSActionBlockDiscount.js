let main = async ({workflow,captions}) => {

    const {ShowPasswordPrompt} = await workflow.respond("ShowPassPrompt")
    
    if (ShowPasswordPrompt) {
        
        var result = await popup.input({title: captions.title, caption: captions.PasswordPromptLbl})
        if (result === null) {
            return(" ");
        }
        
        await workflow.respond ("VerifyPassword",{password: result})

    };
    await workflow.respond ("ToggleBlockState")
};