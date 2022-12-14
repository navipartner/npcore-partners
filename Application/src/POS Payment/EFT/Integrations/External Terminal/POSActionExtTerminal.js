let main = async ({ context, workflow, popup, captions }) => {
  debugger;
  let result = { "success": false, "tryEndSale": false };

  if (context.request.AmountIn > 0) {
    if (context.request.PromptCardDigits) {
      context.request.CardDigits = await popup.stringpad({ caption: captions.PromptCardDigits });
      if (context.request.CardDigits === null || context.request.CardDigits === "") return (result);
      var isNumber = /^(\d+,)*(\d+)$/.test(context.request.CardDigits);
      if (!isNumber) {
        await popup.error('Please enter numbers only.')
        return (result);
      };
    };

    if (context.request.PromptCardHolder) {
      context.request.CardHolder = await popup.input({ caption: captions.PromptCardHolder });
      if (context.request.CardHolder === null) return (result);
    };

    if (context.request.PromptApprovalCode) {
      confirmAns = await popup.confirm(captions.PromptConfirmation + context.request.AmountIn + "?");
      if (!confirmAns) return (result);
      context.request.ApprovalCode = await popup.input({ caption: captions.PromptApprovalCode });
      if (context.request.ApprovalCode === "") {
        popup.error(captions.InvalidApprovalCode);
        return (result);
      };
      if (context.request.ApprovalCode === null) return (result);
    };
  };
  const { success, endSale } = await workflow.respond("FinalizeRequest");
  result.success = success;
  result.tryEndSale = endSale;
  return (result);
};
