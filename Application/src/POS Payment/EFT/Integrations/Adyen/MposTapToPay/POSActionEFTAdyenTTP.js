const main = async ({ workflow, context, popup, captions }) => {
  if (!window.top.jsBridge.AdyenProtocol) {
    popup.error(
      "The Tap to pay integration only works for Android devices.",
      "Invalid Platform"
    );
    return;
  }
  context.EntryNo = context.request.EntryNo;
  context.PaymentSetupCode = context.request.PaymentSetupCode;
  context.IsLiveEnvironment = context.request.IsLiveEnvironment;
  context.PosUnitNumber = context.request.PosUnitNumber;
  try {
    await workflow.respond("PrepareRequest");
    if (context.IsLookup) {
      const lookupResult = await Lookup(context);
      if (!lookupResult.Success) {
        await workflow.respond("Error", { Error: lookupResult.Error });
        return { success: false, tryEndSale: false };
      } else {
        await workflow.respond("TerminalApiResponse", {
          FoundResponse: lookupResult.FoundCachedResponse,
          InstallationId: lookupResult.InstallationId,
          TerminalApiResult: JSON.stringify(lookupResult.TerminalApiResponse),
        });
        return { success: context.success, tryEndSale: context.success };
      }
    }

    let response = await IsBoarded(context);
    if (!response.Success) {
      await workflow.respond("Error", { Error: response.Error });
      return { success: false, tryEndSale: false };
    }

    const isBoardedRes = response.IsBoardedResponse;
    context.InstallationId = isBoardedRes.InstallationId;
    if (!isBoardedRes.Boarded) {
      context.BoardingRequestToken = isBoardedRes.BoardingRequestToken;
      const response = await Board(context);
      if (!response.Success) {
        await workflow.respond("Error", { Error: response.Error });
        return { success: false, tryEndSale: false };
      }
    }

    response = await TerminalAPIRequest(context);
    if (!response.Success) {
      await workflow.respond("Error", { Error: response.Error });
      return { success: false, tryEndSale: false };
    }

    await workflow.respond("TerminalApiResponse", {
      TerminalApiResult: JSON.stringify(response.TerminalApiResponse),
    });
  } catch (error) {
    let message;
    if (error.ALError && error.ALError.originalMessage) {
      message = error.ALError.originalMessage;
    } else {
      if (error.message) message = error.message;
      else message = error;
      popup.error(message, "Error in Tap to Pay flow");
    }
    await workflow.respond("Error", { Error: message });
  }
  return { success: context.success, tryEndSale: context.success };
};

function IsBoarded(context) {
  return new Promise(async (resolve, reject) => {
    const isBoardedRequest = JSON.stringify({
      RequestType: "IsBoarded",
      IsLiveEnvironment: context.IsLiveEnvironment,
    });
    const response = await window.top.jsBridge.AdyenProtocol(isBoardedRequest);
    resolve(JSON.parse(response));
  });
}

function Board(context) {
  return new Promise(async (resolve, reject) => {
    try {
      await workflow.respond("GetBoardingToken");
      const boardRequest = JSON.stringify({
        RequestType: "BoardWithToken",
        IsLiveEnvironment: context.IsLiveEnvironment,
        BoardingToken: context.boardingTokenBase64,
      });
      const response = await window.top.jsBridge.AdyenProtocol(boardRequest);
      resolve(JSON.parse(response));
    } catch (e) {
      reject(e);
    }
  });
}

function Lookup(context) {
  return new Promise(async (resolve, reject) => {
    const cachedLookupReq = JSON.stringify({
      RequestType: "CachedLookup",
      CahcedLookupServiceId: context.LookupReference,
      EncDetailsJson: context.derivedKeyMaterial,
    });
    const response = await window.top.jsBridge.AdyenProtocol(cachedLookupReq);
    resolve(JSON.parse(response));
  });
}

function TerminalAPIRequest(context) {
  return new Promise(async (resolve, reject) => {
    const terminalApiRequest = JSON.stringify({
      RequestType: "TerminalApiRequest",
      IntegrationType: "TapToPay",
      TerminalApiSaletoPoiRequestJson: context.terminalApiReq,
      IsLiveEnvironment: context.IsLiveEnvironment,
      EncDetailsJson: context.derivedKeyMaterial,
    });
    const response =
      await window.top.jsBridge.AdyenProtocol(terminalApiRequest);
    resolve(JSON.parse(response));
  });
}
