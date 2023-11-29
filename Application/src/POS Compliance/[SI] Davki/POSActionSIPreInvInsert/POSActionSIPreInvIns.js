let main = async ({ workflow, popup, captions }) => {
    let SetNumber = await popup.input({ title: captions.setnumbertitle, caption: captions.setnumberprompt});
    if (SetNumber.length>20){
        await popup.error(captions.setlengtherror);
        return(" ");
    }
    let SerialNumber = await popup.input({ title: captions.serialnumbertitle, caption: captions.serialnumberprompt});
    if (SerialNumber.length>40){
        await popup.error(captions.seriallengtherror);
        return(" ");
    }
    if (SetNumber === null || SetNumber === "" || SerialNumber === null || SerialNumber === "") return;
    return await workflow.respond("InsertSetSerialNumbers", { SetNumberNo: SetNumber, SerialNumberNo: SerialNumber });
}