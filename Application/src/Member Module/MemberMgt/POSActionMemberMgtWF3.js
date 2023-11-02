let main = async ({workflow, context, popup, captions,parameters}) => {
    if (parameters.Function < 0) {
        parameters.Function = parameters.Function["Member Arrival"];
    };
    
    let windowTitle = captions.DialogTitle.substitute(parameters.Function);

    // Prompt for member card number    
    if (parameters.DefaultInputValue.length == 0 && parameters.DialogPrompt <= parameters.DialogPrompt ["Member Card Number"]) {
        context.memberCardInput = await popup.input({caption: captions.MemberCardPrompt, title: captions.windowTitle});
        if (context.memberCardInput === null) {return;}
    }

    // When data is pass from EAN box f.ex.
    if (parameters.DefaultInputValue.length > 0) {
        context.memberCardInput = parameters.DefaultInputValue;
    }

    // If function is one of the membership alteration actions, fetch the options and prompt teller to choose 
    if (parameters.Function >= parameters.Function["Regret Membership Entry"] && parameters.Function <= parameters.Function["Cancel Membership"] ) {
        let lookupProperties = JSON.parse(await workflow.respond("GetMembershipAlterationLookup"));
        context.memberCardInput = lookupProperties.cardnumber;
        let lookupDataArray = JSON.parse(lookupProperties.data);
        if (lookupDataArray.length == 0) {
            await popup.error ({title: captions.windowTitle, caption: lookupProperties.notFoundMessage});
            return;
        }

        let driver = data.createArrayDriver(lookupDataArray);
        let source = data.createDataSource(driver);
        source.loadAll = false;
        let result = await popup.lookup({
            title: lookupProperties.title, 
            configuration: {
                className: "custom-lookup", 
                styleSheet: "", 
                layout: JSON.parse(lookupProperties.layout), 
                result: rows => rows ? rows.map (row => row ? row.itemno : null) : null
            }, 
            source: source
        });

        if (result === null || result.length === 0) 
            return;
        
        context.itemNumber = result[0].itemno;
    }

    // Process the main request
    let membershipResponse = await workflow.respond ("DoManageMembership");
    if (parameters.Function == parameters.Function["View Membership Entry"]) {
        let membershipEntries = JSON.parse (membershipResponse);
        let driver = data.createArrayDriver(JSON.parse(membershipEntries.data));
        let source = data.createDataSource(driver);
        let result = await popup.lookup({title: membershipEntries.title, configuration: {className: "custom-lookup", styleSheet: "", layout: JSON.parse(membershipEntries.layout)}, source: source});
    }
}