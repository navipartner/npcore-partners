let main = async ({parameters, context, captions}) => {
    const {DimCaption}= await workflow.respond ("GetDimCaption");

    if (parameters.ValueSelection ==2 )
    {
        var result = await popup.numpad({title: DimCaption, caption: captions.DimTitle});
        if (result === null) {
            return (" ");
        }
    }
    if (parameters.ValueSelection ==3 )
    {
        var result = await popup.input({title: DimCaption, caption: captions.DimTitle});
        if (result === null) {
            return (" ");
        }
    }
    await workflow.respond ("InsertDim",{DimCode: result})
};