const main = async ({ workflow, context, popup, captions }) => {
  if (!window.top.jsBridge.AdyenProtocol) {
    popup.error("Not Android Device", "Error");
    return;
  }
  context.EntryNo = context.request.EntryNo;
  context.PaymentSetupCode = context.request.PaymentSetupCode;
  context.LocalTerminalIpAddress = context.request.LocalTerminalIpAddress;
  context.IsLiveEnvironment = context.request.IsLiveEnvironment;
  try {
    await workflow.respond("TerminalApiRequest");
    const terminalApiRequest = JSON.stringify({
      RequestType: "TerminalApiRequest",
      IntegrationType: "LocalTerminal",
      LocalTerminalIpAddress: context.LocalTerminalIpAddress,
      TerminalApiSaletoPoiRequestJson: context.terminalApiReq,
      EncDetailsJson: context.derivedKeyMaterial,
      IsLiveEnvironment: context.IsLiveEnvironment,
    });
    const protocolResponse = JSON.parse(
      await window.top.jsBridge.AdyenProtocol(terminalApiRequest)
    );
    if (!protocolResponse.Success) {
      const s = "Mpos Lan Request Error";
      await popup.error(protocolResponse.Error, s);
      await workflow.respond("Error", { Error: protocolResponse.Error });
      return { success: false, tryEndSale: false };
    }
    const terminalApiResult = protocolResponse.TerminalApiResponse;
    await workflow.respond("TerminalApiResponse", {
      terminalApiResult: JSON.stringify(terminalApiResult),
    });
  } catch (error) {
    popup.error(error, "Unexpected error");
  }
  return { success: context.success, tryEndSale: context.success };
};
