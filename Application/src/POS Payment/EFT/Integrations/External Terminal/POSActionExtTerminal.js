let main = async ({ context, workflow, popup, captions }) => {
  let result = { "success": false, "endSale": false };

  if (context.hwcRequest.AmountIn > 0) {
    if (context.hwcRequest.PromptCardDigits) {
      context.hwcRequest.CardDigits = await popup.intpad({ caption: captions.PromptCardDigits });
      if (context.hwcRequest.CardDigits === null || context.hwcRequest.CardDigits === 0) return (result);
    };

    if (context.hwcRequest.PromptCardHolder) {
      context.hwcRequest.CardHolder = await popup.input({ caption: captions.PromptCardHolder });
      if (context.hwcRequest.CardHolder === null) return (result);
    };

    if (context.hwcRequest.PromptApprovalCode) {
      confirmAns = await popup.confirm(captions.PromptConfirmation + context.hwcRequest.AmountIn + "?");
      if (!confirmAns) return (result);
      context.hwcRequest.ApprovalCode = await popup.input({ caption: captions.PromptApprovalCode });
      if (context.hwcRequest.ApprovalCode === "") {
        popup.error(captions.InvalidApprovalCode);
        return (result);
      };
      if (context.hwcRequest.ApprovalCode === null) return (result);
    };
  };
  const { success, endSale } = await workflow.respond("FinalizeRequest");
  result.success = success;
  result.endSale = endSale;
  return (result);
}