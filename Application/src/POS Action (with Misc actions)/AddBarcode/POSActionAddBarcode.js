let main = async ({workflow, popup, captions}) => {
    
    let result = await popup.input({title: captions.title, caption: captions.barcodeprompt});
    if (result === null) {
        return(" ");
    }
    await workflow.respond("InsertBarCode", { BarCode: result })

}