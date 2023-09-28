let main = async ({workflow, parameters, captions, popup, context}) => {
    debugger;
    await workflow.respond("AddPresetValuesToContext");
    if ((parameters.Setting == parameters.Setting["Package"]) || (parameters.Setting == parameters.Setting["Selection"])) {
        var result = await popup.calendarPlusLines({
            title: captions.title, 
            caption: captions.calendar, 
            date: context.defaultdate, 
            dataSource: "BUILTIN_SALELINE",
            filter: (line) => {
                return ((line.fields[5] == 1) && (parseFloat(line.fields[12]) > 0));
            }
        });
    } else {
       var result = await popup.datepad({ title: captions.title, caption: captions.validfrom, required: true, value: context.defaultdate });
    };
    if (result === null) { return };
    
    if (parameters.Setting != parameters.Setting["All Lines"] ){ 
        await workflow.respond("PrintExchangeLabels", { UserSelection: result });
    }
    else{
        var getPrintLineKeysResult = await workflow.respond("GetPrintLineKeys");
        
        for(var i = 0; i < getPrintLineKeysResult.printLineKeys.length; i++) {
            workflow.context.printLineKey = getPrintLineKeysResult.printLineKeys[i];
            await workflow.respond("PrintExchangeLabelPerQty", { UserSelection: result });
        }
    }
}