codeunit 6059890 "NPR POS Action: EFT Softpay" implements "NPR IPOS Workflow"
{
#pragma warning disable AA0139
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'EFT Request Workflow';
        WorkflowTitle: Label 'Softpay Payment';
        Aborting: Label 'Aborting...';
        ConfirmAbort: Label 'Are you sure you want to abort this transaction?';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('workflowTitle', WorkflowTitle);
        WorkflowConfig.AddLabel('statusAborting', Aborting);
        WorkflowConfig.AddLabel('confirmAbort', ConfirmAbort);
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        EftInterface: Codeunit "NPR EFT Interface";
        EftTransactionRequest: Record "NPR EFT Transaction Request";

        ContextRequest: JsonObject;
        SoftpayResponse: JsonObject;
        SoftpayRequest: JsonObject;
        JToken: JsonToken;

        Success: Boolean;
        EndSale: Boolean;
        ErrorTitle: Text;
        ErrorCaption: Text;
    begin

        ContextRequest := Context.GetJsonObject('request');
        SoftpayResponse := Context.GetJsonObject('SoftpayResponse');
        SoftpayRequest := Context.GetJsonObject('SoftpayRequest');

        ContextRequest.Get('EFTEntryNo', JToken);
        EftTransactionRequest.Get(JToken.AsValue().AsInteger());
        RemoveSensitiveInfo(SoftpayRequest);
        Log(JToken.AsValue().AsInteger(), Step, SoftpayRequest, SoftpayResponse);

        Success := False;
        EndSale := False;

        case Step of
            'IDRecieved':
                begin
                    if (SoftpayResponse.Get('RequestSuccessfull', JToken) and JToken.AsValue().AsBoolean()) then begin
                        SoftpayResponse.Get('RequestID', JToken);
                        EftTransactionRequest."Reference Number Output" := JToken.AsValue().AsText();
                        EftTransactionRequest."External Transaction ID" := JToken.AsValue().AsText();
                        Success := True;
                    end else begin
                        ErrorTitle := 'Request creation error';
                        ErrorCaption := 'Could not create a request for softpay';
                        if (SoftpayResponse.Get('Message', JToken)) then begin
                            ErrorCaption := ErrorCaption + ': ' + JToken.AsValue().AsText();
                        end;
                        EftTransactionRequest."Result Description" := ErrorCaption;
                        EftTransactionRequest.Recoverable := False;
                        EftTransactionRequest.Successful := False;
                        EftTransactionRequest."External Result Known" := True;
                    end;
                    EftTransactionRequest.Modify();
                end;
            'TransactionFinished':
                begin
                    if (SoftpayResponse.Get('HasSoftpayResult', JToken) and JToken.AsValue().AsBoolean()) then begin
                        if (SoftpayResponse.Get('RequestSuccessfull', JToken) and JToken.AsValue().AsBoolean()) then begin
                            HandleTransactionResponseInfo(EftTransactionRequest, SoftpayResponse);
                            EftTransactionRequest."External Result Known" := True;
                            EftTransactionRequest.Successful := True;
                            Success := True;
                            EndSale := True;
                        end else begin
                            HandleTransactionResponseInfo(EftTransactionRequest, SoftpayResponse);
                            SoftpayResponse.Get('Message', JToken);
                            ErrorTitle := 'Softpay request Failed';
                            ErrorCaption := 'The softpay request failed: ' + JToken.AsValue().AsText();
                            EftTransactionRequest."Client Error" := ErrorCaption;
                            EftTransactionRequest."External Result Known" := True;
                            EftTransactionRequest.Successful := False;
                        end;
                    end else begin
                        SoftpayResponse.Get('Message', JToken);
                        ErrorTitle := 'Error';
                        ErrorCaption := 'The softpay request crashed unexpectedly: ' + JToken.AsValue().AsText();
                        EftTransactionRequest."Client Error" := ErrorCaption;
                        EftTransactionRequest."External Result Known" := False;
                        EftTransactionRequest.Successful := False;
                    end;
                end;
            'Failed':
                begin
                    ErrorTitle := 'Failure';
                    ErrorCaption := 'Unknown error occoured';
                    EftTransactionRequest."External Result Known" := False;
                    EftTransactionRequest.Successful := False;
                    EftTransactionRequest."Client Error" := Context.GetString('ErrorMessage');
                end;
        end;
        if (Step <> 'IDRecieved') then
            EftInterface.EftIntegrationResponse(EftTransactionRequest);
        FrontEnd.WorkflowResponse(FinalizeFrontendJSON(Success, EndSale, ErrorTitle, ErrorCaption));
    end;

    local procedure FinalizeFrontendJSON(Success: Boolean; EndSale: Boolean; ErrorTitle: Text; ErrorCaption: Text): JsonObject
    var
        ResponseJSON: JsonObject;
    begin
        ResponseJSON.Add('success', Success);
        ResponseJSON.Add('endSale', EndSale);
        ResponseJSON.Add('errorcaption', ErrorCaption);
        ResponseJSON.Add('errortitle', ErrorTitle);
        exit(ResponseJSON);
    end;

    local procedure Log(EntryNumber: Integer; Description: Text; SoftpayRequest: JsonObject; SoftpayResponse: JsonObject)
    var
        LogJson: JsonObject;
        LogCU: Codeunit "NPR EFT Trx Logging Mgt.";
        LogResult: Text;
    begin
        LogJson.Add('Request', SoftpayRequest);
        LogJson.Add('Response', SoftpayResponse);
        if (LogJson.WriteTo(LogResult)) then begin
            LogCU.WriteLogEntry(EntryNumber, Description, LogResult);
        end else begin
            LogCU.WriteLogEntry(EntryNumber, Description, 'JSON Object could not be retrieved from the JS Layer');
        end;
    end;

    local procedure RemoveSensitiveInfo(var SoftpayRequest: JsonObject)
    begin
        SoftpayRequest.Remove('IntegratorID');
        SoftpayRequest.Remove('IntegratorCredentials');
        SoftpayRequest.Remove('SoftpayPassword');
    end;

    local procedure HandleTransactionResponseInfo(var EFTTransactionRequest: Record "NPR EFT Transaction Request"; SoftpayResponse: JsonObject)
    var
        JToken: JsonToken;
        EFTPaymentMapping: Codeunit "NPR EFT Payment Mapping";
        POSPaymentMethod: Record "NPR POS Payment Method";
        Out: OutStream;
    begin
        if (SoftpayResponse.Get('TransactionState', JToken) and not JToken.AsValue().IsNull()) then
            EftTransactionRequest."Result Description" := JToken.AsValue().AsText();
        if (SoftpayResponse.Get('PartialPan', JToken) and not JToken.AsValue().IsNull()) then
            EftTransactionRequest."Card Number" := JToken.AsValue().AsText();
        if (SoftpayResponse.Get('ApplicationID', JToken) and not JToken.AsValue().IsNull()) then
            EftTransactionRequest."Card Application ID" := JToken.AsValue().AsText();
        if (SoftpayResponse.Get('CardScheme', JToken) and not JToken.AsValue().IsNull()) then
            EftTransactionRequest."Card Name" := JToken.AsValue().AsText();
        if (SoftpayResponse.Get('Amount', JToken) and not JToken.AsValue().IsNull()) then begin
            EftTransactionRequest."Amount Output" := JToken.AsValue().AsDecimal();
            EftTransactionRequest."Result Amount" := JToken.AsValue().AsDecimal();
            if (EftTransactionRequest."Processing Type" = EftTransactionRequest."Processing Type"::REFUND) then
                EftTransactionRequest."Result Amount" := JToken.AsValue().AsDecimal() * -1;
        end;
        if (SoftpayResponse.Get('ReceiptContent', JToken) and not JToken.AsValue().IsNull) then begin
            if (not EftTransactionRequest."Receipt 1".HasValue) then begin
                EftTransactionRequest."Receipt 1".CreateOutStream(Out);
                Out.WriteText(JToken.AsValue().AsText());
            end;
        end;
        if EFTPaymentMapping.FindPaymentType(EftTransactionRequest, POSPaymentMethod) then begin
            EftTransactionRequest."POS Payment Type Code" := POSPaymentMethod.Code;
            EftTransactionRequest."Card Name" := CopyStr(POSPaymentMethod.Description, 1, MaxStrLen(EftTransactionRequest."Card Name"));
        end;
    end;


    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTSoftpay.Codeunit.js###
'let main=async r=>{const{context:a,workflow:o,popup:s}=r;if(window.parent.jsBridge==null||navigator.userAgent.indexOf("Android")==-1)return await s.error("You can only use Softpay on Android devices.","Device error"),{success:!1};if(window.parent.jsBridge.SoftpayProtocol==null||window.parent.jsBridge.SoftpayProtocol===void 0)return await s.error("Softpay integration not found. Either you are using an outdated version of the Mobile App or the device is not supported.","Device error"),{success:!1};let e={SoftpayAction:a.request.SoftpayAction,Step:null,RequestID:null,Amount:a.request.Amount,Currency:a.request.Currency,IntegratorID:a.request.IntegratorID,IntegratorCredentials:a.request.IntegratorCredentials.split(""),SoftpayUsername:a.request.SoftpayUsername,SoftpayPassword:a.request.SoftpayPassword.split("")},t=null;try{switch(e.SoftpayAction){case"Refund":case"Payment":var i=await SendMPOSAsync(e);if(t=await o.respond("IDRecieved",{SoftpayResponse:i,SoftpayRequest:e}),t.success){e.RequestID=i.RequestID;let n=await SendMPOSAsync(e);t=await o.respond("TransactionFinished",{SoftpayResponse:n,SoftpayRequest:e})}break;case"GetTransaction":e.RequestID=a.request.RequestID;var p=await SendMPOSAsync(e);t=await o.respond("TransactionFinished",{SoftpayResponse:p,SoftpayRequest:e});break;default:t=await o.respond("Failed",{ErrorMessage:"Command: "+e.SoftpayAction+" Is not supported",SoftpayRequest:e,SoftpayResponse:null})}}catch(n){t=await o.respond("Failed",{ErrorMessage:n.message,SoftpayRequest:e,SoftpayResponse:null})}return t.success||await s.error(t.errorcaption,t.errortitle),{success:t.succes,tryEndSale:t.endSale}},step=1;async function SendMPOSAsync(r){let a=window.parent.jsBridge;return r.Step=step++,JSON.parse(await a.SoftpayProtocol(JSON.stringify(r)))}'
        );
    end;
#pragma warning restore AA0139
}
