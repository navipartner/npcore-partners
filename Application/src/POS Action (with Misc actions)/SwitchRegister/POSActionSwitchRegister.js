let main = async ({workflow, parameters,popup, captions}) => { 
    const Type = {TextField: 0,Numpad: 1,List: 2};
    switch (parameters._parameters.DialogType) {
        case Type.TextField:
            var result = await popup.input({caption: captions.registerprompt});
            if (result === null) {
               return(" ");}  
            await workflow.respond("EnterRegister", { RegisterNo: result });
            break;
        case Type.Numpad:
            var result = await popup.numpad({caption: captions.registerprompt});
            if (result === null) {
               return(" ");}  
            await workflow.respond("EnterRegister", { RegisterNo: result});
            break;
        case Type.List:
            await workflow.respond();
            break;
    }
 }
