let main = async ({workflow,captions,parameters,popup}) => {
    let eventno;
    switch(parameters.DialogType.toInt())
    {
        case parameters.DialogType["TextField"]:
            eventno = await popup.input({caption: captions.Prompt});
            break; 
        case parameters.DialogType["List"]:
            eventno = await workflow.respond("select_event_from_list");
            break;
    }
    if (eventno == null) {
        return(" ");    
    }
    return await workflow.respond("import_event",{selected_eventno:eventno});
}
