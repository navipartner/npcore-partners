let main = async ({workflow, popup, captions}) => {
    
    let value = await popup.confirm({title: captions.title, caption: captions.prompt});
    await workflow.respond("SetTaxLiable", { value: value })
}