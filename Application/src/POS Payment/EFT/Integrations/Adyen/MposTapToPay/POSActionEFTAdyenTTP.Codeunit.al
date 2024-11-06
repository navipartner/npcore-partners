codeunit 6184885 "NPR POS Action EFT Adyen TTP" implements "NPR IPOS Workflow"
{
    Access = Internal;
    SingleInstance = true;

    var
        _TrxStatus: Dictionary of [Integer, Integer]; //"NPR Adyen TTP Status" Enum

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Adyen mPos TTP EFT Transaction';
        InitialStatusLbl: Label 'Initializing..';
        ActiveStatusLbl: Label 'Waiting For Response';
        ApproveSignatureLbl: Label 'Approve signature on receipt?';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());

        WorkflowConfig.AddLabel('initialStatus', InitialStatusLbl);
        WorkflowConfig.AddLabel('activeStatus', ActiveStatusLbl);
        WorkflowCOnfig.AddLabel('approveSignature', ApproveSignatureLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup")
    begin
        case Step of
            'PrepareRequest':
                begin
                    PrepareRequest(Context);
                end;
            'GetBoardingToken':
                begin
                    GetBoardingToken(Context);
                end;
            'TerminalApiResponse':
                begin
                    ParseTerminalResponse(Context);
                end;
            'Error':
                begin
                    OnError(Context);
                end;
        end;
    end;

    local procedure PrepareRequest(Context: codeunit "NPR POS JSON Helper")
    var
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        EFTAdyenPaymTypeSetup.Get(Context.GetString('PaymentSetupCode'));
        Context.SetContext('derivedKeyMaterial', EFTAdyenPaymTypeSetup.GetEncryptionKeyMaterialJson());
        PrepareAdyenRequest(Context);
        _TrxStatus.Set(Context.GetInteger('EntryNo'), Enum::"NPR Adyen TTP Status"::"TAPI Sent".AsInteger());
    end;

    local procedure GetBoardingToken(Context: codeunit "NPR POS JSON Helper")
    var
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
        EFTAdyenUnitSetup: Record "NPR EFT Adyen Unit Setup";
        EFTAdyneBoardingToken: Codeunit "NPR EFT Adyen Boarding Token";
        BoardingTokenB64: Text;
    begin
        _TrxStatus.Set(Context.GetInteger('EntryNo'), Enum::"NPR Adyen TTP Status"::"Fetching BoardingToken".AsInteger());
        EFTAdyenPaymTypeSetup.Get(Context.GetString('PaymentSetupCode'));
        EFTAdyenUnitSetup.Get(Context.GetString('PosUnitNumber'));
        EFTAdyneBoardingToken.RequestBoardingToken(EFTAdyenPaymTypeSetup, EFTAdyenUnitSetup."In Person Store Id", Context.GetString('BoardingRequestToken'), BoardingTokenB64);
        Context.SetContext('boardingTokenBase64', BoardingTokenB64);
    end;


    local procedure PrepareAdyenRequest(Context: codeunit "NPR POS JSON Helper")
    var
        EFTAdyenTrxRequest: Codeunit "NPR EFT Adyen Trx Request";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";

    begin
        EFTTransactionRequest.Get(Context.GetString('EntryNo'));
        EFTSetup.Get(EFTTransactionRequest."POS Payment Type Code", EFTTransactionRequest."Register No.");
        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT,
            EFTTransactionRequest."Processing Type"::REFUND:
                begin
                    Context.SetContext('terminalApiReq', EFTAdyenTrxRequest.GetRequestJson(EFTTransactionRequest, EFTSetup));
                end;
            //Only implementening cached response if webview crashed.
            EFTTransactionRequest."Processing Type"::LOOK_UP:
                begin
                    Context.SetContext('IsLookup', true);
                    Context.SetContext('LookupReference', Format(EFTTransactionRequest."Processed Entry No."));
                end;
        end;

    end;

    local procedure ParseTerminalResponse(Context: codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        EFTInterface: Codeunit "NPR EFT Interface";
        EntryNo: Integer;
    begin
        _TrxStatus.Set(Context.GetInteger('EntryNo'), Enum::"NPR Adyen TTP Status"::"TAPI Recieved".AsInteger());
        EntryNo := Context.GetInteger('EntryNo');
        EFTTransactionRequest.Get(EntryNo);
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP) then begin
            if (Context.GetBoolean('FoundResponse')) then begin
                HandleCachedLookupResponse(EFTTransactionRequest, Context);
                exit;
            end else begin
                OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
                OriginalEFTTransactionRequest.Recoverable := false;
                OriginalEFTTransactionRequest.Modify();
                EFTTransactionRequest."Result Description" := 'Request not found.';
                EFTTransactionRequest.Successful := false;
                EFTTransactionRequest.Modify();
                EFTInterface.EftIntegrationResponse(EFTTransactionRequest);
                Context.SetContext('success', false);
                exit;
            end;
        end;
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, Context.GetString('TerminalApiResult'), true, true, '');
        if not Codeunit.Run(Codeunit::"NPR EFT Try Print Receipt", EFTTransactionRequest) then
            Message(GetLastErrorText);
        Commit();
        EFTTransactionRequest.Get(EntryNo);
        EFTTransactionRequest."Hardware ID" := CopyStr(Context.GetString('InstallationId'), 1, MaxStrLen(EFTTransactionRequest."Hardware ID"));
        EFTTransactionRequest.Modify();
        Context.SetContext('success', EFTTransactionRequest.Successful);
    end;

    local procedure HandleCachedLookupResponse(var EftTransactionRequest: Record "NPR EFT Transaction Request"; Context: codeunit "NPR POS JSON Helper")
    var
        EFTAdyenResponseParser: Codeunit "NPR EFT Adyen Response Parser";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        ParseSuccess: Boolean;
    begin
        EFTAdyenResponseParser.SetResponseData(Enum::"NPR EFT Adyen Response Type"::CacheRecoveredResponse, Context.GetString('TerminalApiResult'), EftTransactionRequest."Entry No.");
        ParseSuccess := EFTAdyenResponseParser.Run();

        EftTransactionRequest.Get(EftTransactionRequest."Entry No.");
        OriginalEFTTransactionRequest.Get(EftTransactionRequest."Processed Entry No.");
        if not ParseSuccess then begin
            EFTTransactionRequest.Successful := false;
            EFTTransactionRequest."External Result Known" := false; //Could not parse response correctly - needs to go to lookup.
            EFTTransactionRequest."Amount Output" := 0;
            EFTTransactionRequest."Result Amount" := 0;
            EFTTransactionRequest."NST Error" := CopyStr(GetLastErrorText(), 1, MaxStrLen(EFTTransactionRequest."NST Error"));
            EftTransactionRequest.Modify();
        end;
        OriginalEFTTransactionRequest.Recoverable := EFTTransactionRequest.Successful;
        OriginalEFTTransactionRequest.Recovered := EFTTransactionRequest.Successful;
        OriginalEFTTransactionRequest.Modify();
        EFTAdyenResponseHandler.HandleProtocolResponse(EftTransactionRequest);
    end;

    local procedure OnError(Context: codeunit "NPR POS JSON Helper")
    var
        TrxStatus: Enum "NPR Adyen TTP Status";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        TrxStatus := Enum::"NPR Adyen TTP Status".FromInteger(_TrxStatus.Get(Context.GetInteger('EntryNo')));
        EFTTransactionRequest.Get(Context.GetString('EntryNo'));
        case TrxStatus of
            Enum::"NPR Adyen TTP Status"::"Fetching BoardingToken":
                begin
                    EFTTransactionRequest.Recoverable := false;
                    EFTTransactionRequest."External Result Known" := true;
                end;
            Enum::"NPR Adyen TTP Status"::"TAPI Sent":
                begin
                    EFTTransactionRequest."External Result Known" := false;
                end;
        end;
        EFTTransactionRequest."POS Description" := 'Tap-To-Pay: Transaction Failed';
        EFTTransactionRequest."Result Description" := 'Error';
        EFTTransactionRequest."Client Error" := CopyStr(Context.GetString('Error'), 1, 250);
        EFTInterface.EftIntegrationResponse(EFTTransactionRequest);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTAdyenTTP.js###
'const main=async({workflow:s,context:e,popup:o,captions:n})=>{if(!window.top.jsBridge.AdyenProtocol){o.error("The Tap to pay integration only works for Android devices.","Invalid Platform");return}e.EntryNo=e.request.EntryNo,e.PaymentSetupCode=e.request.PaymentSetupCode,e.IsLiveEnvironment=e.request.IsLiveEnvironment,e.PosUnitNumber=e.request.PosUnitNumber;try{if(await s.respond("PrepareRequest"),e.IsLookup){const a=await Lookup(e);return a.Success?(await s.respond("TerminalApiResponse",{FoundResponse:a.FoundCachedResponse,InstallationId:a.InstallationId,TerminalApiResult:JSON.stringify(a.TerminalApiResponse)}),{success:e.success,tryEndSale:e.success}):(await s.respond("Error",{Error:a.Error}),{success:!1,tryEndSale:!1})}let r=await IsBoarded(e);if(!r.Success)return await s.respond("Error",{Error:r.Error}),{success:!1,tryEndSale:!1};const i=r.IsBoardedResponse;if(e.InstallationId=i.InstallationId,!i.Boarded){e.BoardingRequestToken=i.BoardingRequestToken;const a=await Board(e);if(!a.Success)return await s.respond("Error",{Error:a.Error}),{success:!1,tryEndSale:!1}}if(r=await TerminalAPIRequest(e),!r.Success)return await s.respond("Error",{Error:r.Error}),{success:!1,tryEndSale:!1};await s.respond("TerminalApiResponse",{TerminalApiResult:JSON.stringify(r.TerminalApiResponse)})}catch(r){let i;r.ALError&&r.ALError.originalMessage?i=r.ALError.originalMessage:(r.message?i=r.message:i=r,o.error(i,"Error in Tap to Pay flow")),await s.respond("Error",{Error:i})}return{success:e.success,tryEndSale:e.success}};function IsBoarded(s){return new Promise(async(e,o)=>{const n=JSON.stringify({RequestType:"IsBoarded",IsLiveEnvironment:s.IsLiveEnvironment}),r=await window.top.jsBridge.AdyenProtocol(n);e(JSON.parse(r))})}function Board(s){return new Promise(async(e,o)=>{try{await workflow.respond("GetBoardingToken");const n=JSON.stringify({RequestType:"BoardWithToken",IsLiveEnvironment:s.IsLiveEnvironment,BoardingToken:s.boardingTokenBase64}),r=await window.top.jsBridge.AdyenProtocol(n);e(JSON.parse(r))}catch(n){o(n)}})}function Lookup(s){return new Promise(async(e,o)=>{const n=JSON.stringify({RequestType:"CachedLookup",CahcedLookupServiceId:s.LookupReference,EncDetailsJson:s.derivedKeyMaterial}),r=await window.top.jsBridge.AdyenProtocol(n);e(JSON.parse(r))})}function TerminalAPIRequest(s){return new Promise(async(e,o)=>{const n=JSON.stringify({RequestType:"TerminalApiRequest",IntegrationType:"TapToPay",TerminalApiSaletoPoiRequestJson:s.terminalApiReq,IsLiveEnvironment:s.IsLiveEnvironment,EncDetailsJson:s.derivedKeyMaterial}),r=await window.top.jsBridge.AdyenProtocol(n);e(JSON.parse(r))})}'
);
    end;
}
