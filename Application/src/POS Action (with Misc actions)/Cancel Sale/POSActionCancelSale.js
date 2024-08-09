const main = async ({ workflow, captions, popup, parameters }) => {
  if (!parameters.silent)
    if (
      !(await popup.confirm({
        title: captions.title,
        caption: captions.prompt,
      }))
    )
      return " ";

  await workflow.respond("CheckSaleBeforeCancel");
  await workflow.respond("CancelSale");
};
