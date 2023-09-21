let main = async ({ workflow, context, captions }) => {
    await workflow.respond("checkSeating");
    
    let newWaiterpad = {
        "caption": captions.Welcome, "title": captions.NewWaiterpad, "settings": [
            { "type": "plusminus", "id": "guests", "caption": captions.NumberOfGuests, "minvalue": 0, "maxvalue": 100, "value": context.defaultNumberOfGuests },
            { "type": "text", "id": "tablename", "caption": captions.Name },]
    };

    context.waiterpadInfo = await popup.configuration(newWaiterpad);
    if (context.waiterpadInfo) {
        await workflow.respond();
    }
}