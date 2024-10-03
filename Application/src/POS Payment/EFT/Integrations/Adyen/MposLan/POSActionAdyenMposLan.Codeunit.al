codeunit 6184999 "NPR POS Action Adyen Mpos Lan" implements "NPR IPOS Workflow"
{
    Access = Internal;
    SingleInstance = true;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Adyen mPos LAN EFT Transaction';
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
            'TerminalApiRequest':
                begin
                    PrepareTerminalApiRequest(Context);
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

    local procedure PrepareTerminalApiRequest(Context: codeunit "NPR POS JSON Helper")
    var
        EFTAdyenTrxRequest: Codeunit "NPR EFT Adyen Trx Request";
        EFTAdyenLookupReq: Codeunit "NPR EFT Adyen Lookup Req";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        EFTTransactionRequest.Get(Context.GetString('EntryNo'));
        EFTSetup.Get(EFTTransactionRequest."POS Payment Type Code", EFTTransactionRequest."Register No.");
        if (EFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then
            Context.SetContext('terminalApiReq', EFTAdyenTrxRequest.GetRequestJson(EFTTransactionRequest, EFTSetup));
        if (EFTTransactionRequest."Processing Type" = EFTTransactionRequest."Processing Type"::LOOK_UP) then begin
            OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
            Context.SetContext('terminalApiReq', EFTAdyenLookupReq.GetRequestJson(EFTTransactionRequest, OriginalEFTTransactionRequest, EFTSetup));
        end;
        EFTAdyenPaymTypeSetup.Get(EFTTransactionRequest."POS Payment Type Code");
        Context.SetContext('derivedKeyMaterial', EFTAdyenPaymTypeSetup.GetEncryptionKeyMaterialJson());
    end;


    local procedure ParseTerminalResponse(Context: codeunit "NPR POS JSON Helper"): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        EntryNo: Integer;
    begin
        EntryNo := Context.GetInteger('EntryNo');
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, Context.GetString('terminalApiResult'), true, true, '');
        EFTTransactionRequest.Get(EntryNo);

        if not Codeunit.Run(Codeunit::"NPR EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
        Commit();
        Context.SetContext('success', EFTTransactionRequest.Successful);
    end;

    local procedure OnError(Context: codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTInterface: Codeunit "NPR EFT Interface";
    begin
        EFTTransactionRequest.Get(Context.GetString('EntryNo'));
        EFTTransactionRequest."POS Description" := 'Mpos Lan Terminal: Transaction Failed';
        EFTTransactionRequest."Result Description" := 'Error';
        EFTTransactionRequest."Client Error" := CopyStr(Context.GetString('Error'), 1, 250);
        EFTInterface.EftIntegrationResponse(EFTTransactionRequest);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTAdyenLan.js###
'const main=async({workflow:s,context:e,popup:i,captions:o})=>{if(!window.top.jsBridge.AdyenProtocol){i.error("Not Android Device","Error");return}e.EntryNo=e.request.EntryNo,e.PaymentSetupCode=e.request.PaymentSetupCode,e.LocalTerminalIpAddress=e.request.LocalTerminalIpAddress,e.IsLiveEnvironment=e.request.IsLiveEnvironment;try{await s.respond("TerminalApiRequest");const n=JSON.stringify({RequestType:"TerminalApiRequest",IntegrationType:"LocalTerminal",LocalTerminalIpAddress:e.LocalTerminalIpAddress,TerminalApiSaletoPoiRequestJson:e.terminalApiReq,EncDetailsJson:e.derivedKeyMaterial,IsLiveEnvironment:e.IsLiveEnvironment}),r=JSON.parse(await window.top.jsBridge.AdyenProtocol(n));if(!r.Success)return await i.error(r.Error,"Mpos Lan Request Error"),await s.respond("Error",{Error:r.Error}),{success:!1,tryEndSale:!1};const a=r.TerminalApiResponse;await s.respond("TerminalApiResponse",{terminalApiResult:JSON.stringify(a)})}catch(n){i.error(n,"Unexpected error")}return{success:e.success,tryEndSale:e.success}};'
        );
    end;
}
