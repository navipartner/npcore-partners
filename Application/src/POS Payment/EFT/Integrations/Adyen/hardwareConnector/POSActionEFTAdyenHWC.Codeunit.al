codeunit 6248280 "NPR POS Action EFT Adyen HWC" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Adyen HWC EFT Transaction';
        InitialStatusLbl: Label 'Initializing';
        ActiveStatusLbl: Label 'Waiting For Response';
        ApproveSignatureLbl: Label 'Approve signature on receipt?';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('initialStatus', InitialStatusLbl);
        WorkflowConfig.AddLabel('activeStatus', ActiveStatusLbl);
        WorkflowCOnfig.AddLabel('approveSignature', ApproveSignatureLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'transactionDone':
                FrontEnd.WorkflowResponse(TransactionDone(Context.GetInteger('EntryNo'), Context));
            'signatureRejectVoidStart':
                FrontEnd.WorkflowResponse(BuildSignatureVoidRequest(Context.GetInteger('EntryNo')));
            'abortStart':
                FrontEnd.WorkflowResponse(BuildAbortRequest(Context.GetInteger('EntryNo')));
        end;
    end;

    local procedure TransactionDone(EntryNo: Integer; Context: codeunit "NPR POS JSON Helper"): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EntryNo);

        case EFTTransactionRequest."Processing Type" of
            EFTTransactionRequest."Processing Type"::PAYMENT,
            EFTTransactionRequest."Processing Type"::REFUND,
            EFTTransactionRequest."Processing Type"::VOID,
            EFTTransactionRequest."Processing Type"::LOOK_UP,
            EFTTransactionRequest."Processing Type"::SETUP:
                exit(ProcessResult(EntryNo, Context));
            else
                Error('Unsupported operation. This is programming bug, not a user error.');
        end;
    end;


    local procedure ProcessResult(EntryNo: Integer; Context: codeunit "NPR POS JSON Helper"): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        EFTAdyenSignatureBuffer: Codeunit "NPR EFT Adyen Signature Buffer";
        SignatureEntryNo: Integer;
        SignatureJson: Text;
        MissingBitmapLbl: Label 'Missing signature bitmap';
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        ResultMessageOut: Text;
        EFTAdyenAbortMgmt: Codeunit "NPR EFT Adyen Abort Mgmt";
        EntryNoToAbort: Integer;
        hwcResponse: JsonObject;
        JToken: JsonToken;
        TerminalResponse: Text;
        Completed: Boolean;
        Started: Boolean;
        Error: Boolean;
        ErrorMessage: Text;
    begin
        Context.GetJsonObject('hwcResponse', hwcResponse);

        hwcResponse.Get('terminalResponse', JToken);
        terminalResponse := JToken.AsValue().AsText();

        hwcResponse.Get('completed', JToken);
        Completed := JToken.AsValue().AsBoolean();

        hwcResponse.Get('started', JToken);
        Started := JToken.AsValue().AsBoolean();

        hwcResponse.Get('error', JToken);
        Error := JToken.AsValue().AsBoolean();

        hwcResponse.Get('errorMessage', JToken);
        ErrorMessage := JToken.AsValue().AsText();

        EFTAdyenResponseHandler.ProcessResponse(EntryNo, TerminalResponse, (Completed and (not Error)), (Started and (not Completed)), ErrorMessage);
        Commit();

        EFTTransactionRequest.Get(EntryNo);

        if not Codeunit.Run(Codeunit::"NPR EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
        Commit();

        if (not EftTransactionRequest.Successful) then begin
            if EFTTransactionRequest."Result Code" = -10 then begin
                // Previous Trx is still in progress on terminal. Fire off abort in background to help it back to idle while processing this failure.
                if EFTAdyenAbortMgmt.CanAbortLastUnfinishedTrx(EFTTransactionRequest, EntryNoToAbort) then begin
                    Response.Add('silentAbort', true);
                    Response.Add('hwcRequest', BuildAbortRequest(EntryNoToAbort));
                end;
            end;
        end;

        if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then begin
            Message(ResultMessageOut);
        end;

        case EFTTransactionRequest."Signature Type" of
            EFTTransactionRequest."Signature Type"::"On Receipt":
                begin
                    Response.Add('signatureRequired', true);
                    Response.Add('signatureType', 'Receipt');
                end;
            EFTTransactionRequest."Signature Type"::"On Terminal":
                begin
                    EFTAdyenSignatureBuffer.GetSignatureData(SignatureJson, SignatureEntryNo);
                    Response.Add('signatureRequired', true);
                    Response.Add('signatureType', 'Bitmap');
                    Response.Add('signatureBitmap', SignatureJson);
                    if SignatureEntryNo <> EntryNo then begin
                        Response.Replace('signatureType', 'Receipt');
                        Message(MissingBitmapLbl);
                    end;
                end;
        end;

        Response.Add('done', true);
        Response.Add('success', EFTTransactionRequest.Successful);
        exit(Response);
    end;


    local procedure BuildSignatureVoidRequest(EntryNo: Integer): JsonObject
    var
        EftSetup: Record "NPR EFT Setup";
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        EFTAdyenVoidReq: Codeunit "NPR EFT Adyen Void Req";
        requestJson: Text;
        EFTAdyenHWCIntegrat: Codeunit "NPR EFT Adyen HWC Integrat.";
    begin
        EftTransactionRequest.Get(EntryNo);
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        EFTFrameworkMgt.CreateVoidRequest(VoidEFTTransactionRequest, EftSetup, EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.", EntryNo, false);
        Commit();
        requestJson := EFTAdyenVoidReq.GetRequestJson(VoidEFTTransactionRequest, EftSetup);

        Response.Add('hwcRequest', EFTAdyenHWCIntegrat.BuildHwcRequest(EntryNo, EftSetup, requestJson));
        Response.Add('newEntryNo', VoidEFTTransactionRequest."Entry No.");
        exit(Response);
    end;

    local procedure BuildAbortRequest(EntryNo: Integer): JsonObject
    var
        EFTAdyenAbortTrxReq: Codeunit "NPR EFT Adyen AbortTrx Req";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTSetup: Record "NPR EFT Setup";
        Response: JsonObject;
        EFTAdyenHWCIntegrat: Codeunit "NPR EFT Adyen HWC Integrat.";
        EFTAdyenAbortMgmt: Codeunit "NPR EFT Adyen Abort Mgmt";
        AbortRequestEntryNo: Integer;
        AbortTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(EntryNo);
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");

        AbortRequestEntryNo := EFTAdyenAbortMgmt.CreateAbortTransactionRequest(EFTTransactionRequest);
        Commit();
        AbortTransactionRequest.Get(AbortRequestEntryNo);

        Response.Add('hwcRequest', EFTAdyenHWCIntegrat.BuildHwcRequest(EntryNo, EFTsetup, EFTAdyenAbortTrxReq.GetRequestJson(AbortTransactionRequest, EFTSetup)));
        exit(Response);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTAdyenHWC.js###
'const main=async({workflow:t,context:e,popup:u,captions:o,hwc:a})=>{e.EntryNo=e.request.EntryNo,e.success=!1,e.abortRequested=!1;let s;e.request.unattended||(s=await u.simplePayment({title:e.request.TypeCaption,initialStatus:o.initialStatus,showStatus:!0,amount:e.request.formattedAmount,onAbort:async()=>{debugger;if(e.abortRequested)return;e.abortRequested=!0;const n=await t.respond("abortStart");await a.invoke("EFTAdyenLocal",n.hwcRequest)}}));let i;try{i=a.registerResponseHandler(async n=>{debugger;try{e.hwcResponse=n;const r=await t.respond("transactionDone");if(!await transactionIsDone(r,t,e,a,o,u,i))return;e.success=r.success,a.unregisterResponseHandler(i)}catch(r){a.unregisterResponseHandler(i,r)}}),await a.invoke("EFTAdyenLocal",e.request.hwcRequest,i),s&&(s.updateStatus(o.activeStatus),s.enableAbort(!0)),await a.waitForContextCloseAsync(i)}finally{s&&s.close()}return{success:e.success,tryEndSale:e.success}};async function transactionIsDone(t,e,u,o,a,s,i){if(t.signatureRequired){let n=!1;if(!u.request.unattended&&t.signatureType==="Receipt"&&(n=await s.confirm(a.approveSignature)),!u.request.unattended&&t.signatureType==="Bitmap"){const r=JSON.parse(t.signatureBitmap);n=await(await s.signatureValidation({signature:r.SignaturePoint})).completeAsync()}if(!n){const r=await e.respond("signatureRejectVoidStart");debugger;return u.EntryNo=r.newEntryNo,await o.invoke("EFTAdyenLocal",r.hwcRequest,i),!1}}return t.silentAbort&&await o.invoke("EFTAdyenLocal",t.hwcRequest),!0}'
        );
    end;
}
