let main = async ({ workflow, popup, parameters, captions}) => {
    if (parameters.LineSetting == parameters.LineSetting["Selected Line"]) { 
        var result = await popup.numpad({ title: captions.title, caption: captions.PrintQuantity, value: 1, notBlank: true}, "value")
        if (result === 0 || result === null)
            return; 
    }
    await workflow.respond('PrintQuantity', {PrintQuantity: result})
}