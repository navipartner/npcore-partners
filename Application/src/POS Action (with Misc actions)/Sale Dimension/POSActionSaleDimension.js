const main = async ({ parameters }) => {
  const { HeadlineTxt, DimCaption } = await workflow.respond("GetCaptions");

  if (parameters.ValueSelection == 2) {
    var result = await popup.numpad({
      title: HeadlineTxt,
      caption: DimCaption,
    });
    if (result === null) {
      if (!parameters.DimensionMandatory) return " ";
      else result = "";
    }
  }
  if (parameters.ValueSelection == 3) {
    var result = await popup.input({ title: HeadlineTxt, caption: DimCaption });
    if (result === null) {
      if (!parameters.DimensionMandatory) return " ";
      else result = "";
    }
  }
  await workflow.respond("InsertDim", { DimCode: result });
};
