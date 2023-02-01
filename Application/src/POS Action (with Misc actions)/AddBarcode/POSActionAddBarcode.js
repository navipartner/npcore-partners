let main = async ({workflow, popup, captions}) => {
    
    let result = await popup.input({title: captions.title, caption: captions.barcodeprompt});
    if (result === null) {
        return(" ");
    }
    if (result.length > 50) {
        await popup.error(captions.lengtherror);
        return(" ");
    }
    await workflow.respond("InsertBarCode", { BarCode: result })

}