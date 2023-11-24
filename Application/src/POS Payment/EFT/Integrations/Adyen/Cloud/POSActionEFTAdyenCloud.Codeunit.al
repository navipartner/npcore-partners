codeunit 6184608 "NPR POS Action EFT Adyen Cloud" implements "NPR IPOS Workflow"
{
    Access = Internal;
    SingleInstance = true;

    var
        _trxStatus: Dictionary of [Integer, Integer]; //EntryNo, AdyenCloudTrxStatusEnum
        _trxAbortStatus: Dictionary of [Integer, Boolean]; //EntryNo, BackgroundTaskIsRunning
        _trxResponse: Dictionary of [Integer, List of [Text]];

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Adyen Cloud EFT Transaction';
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
            'startTransaction':
                FrontEnd.WorkflowResponse(StartTransaction(Context.GetInteger('EntryNo')));
            'poll':
                FrontEnd.WorkflowResponse(PollResponse(Context.GetInteger('EntryNo')));
            'signatureDecline':
                FrontEnd.WorkflowResponse(SignatureDecline(Context.GetInteger('EntryNo')));
            'requestAbort':
                RequestTrxAbort(Context.GetInteger('EntryNo'));
        end;
    end;

    local procedure PollResponse(EntryNo: Integer): JsonObject
    var
        TrxStatus: Enum "NPR EFT Adyen Task Status";
        Response: JsonObject;
    begin
        TrxStatus := Enum::"NPR EFT Adyen Task Status".FromInteger(_trxStatus.Get(EntryNo));

        case TrxStatus of
            TrxStatus::AcquireCardResponseReceived:
                begin
                    exit(ProcessAcquireCardResponse(EntryNo));
                end;
            TrxStatus::ResultReceived:
                begin
                    exit(ProcessResult(EntryNo));
                end;
            TrxStatus::LookupNeeded:
                begin
                    exit(StartLookup(EntryNo));
                end;
            else begin
                Response.Add('done', false);
                Response.Add('success', false);
                exit(Response);
            end;
        end;
    end;

    local procedure StartTransaction(EntryNo: Integer): JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        EftSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        Parameters: Dictionary of [Text, Text];
        Response: JsonObject;
        TaskId: Integer;
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        AcquireCardEntryNo: Integer;
    begin
        ClearGlobalState();
        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        EftTransactionRequest.Get(EntryNo);
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        if EFTAdyenIntegration.AcquireCardBeforeTransaction(EftTransactionRequest, AcquireCardEntryNo) then begin
            //We start by acquiring the card in background task, then later continue to purchase request once done.
            Response.Add('newEntryNo', AcquireCardEntryNo);
            EftTransactionRequest.Get(AcquireCardEntryNo);
            _trxStatus.Set(EntryNo, Enum::"NPR EFT Adyen Task Status"::Initiated.AsInteger());
        end;

        Parameters.Add('EntryNo', Format(EftTransactionRequest."Entry No."));

        case EftTransactionRequest."Processing Type" of
            EftTransactionRequest."Processing Type"::PAYMENT,
            EftTransactionRequest."Processing Type"::REFUND,
            EftTransactionRequest."Processing Type"::VOID:
                begin
                    _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::Initiated.AsInteger());
                    POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_TRX, Parameters, 1000 * 60 * 5);
                end;
            EftTransactionRequest."Processing Type"::LOOK_UP:
                begin
                    _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::Initiated.AsInteger());
                    POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_LOOKUP, Parameters, 1000 * 60 * 5);
                end;
            EftTransactionRequest."Processing Type"::SETUP:
                begin
                    _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::Initiated.AsInteger());
                    POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_SETUP_CHECK, Parameters, 1000 * 60 * 5);
                end;
            EftTransactionRequest."Processing Type"::AUXILIARY:
                case EftTransactionRequest."Auxiliary Operation ID" of
                    2, 4, 5, 6:
                        begin
                            _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::AcquireCardInitiated.AsInteger());
                            POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_ACQ_CARD, Parameters, 1000 * 60 * 5);
                        end;
                    else
                        Error('Unsupported operation. This is programming bug, not a user error.');
                end;
            else
                Error('Unsupported operation. This is programming bug, not a user error.');
        end;

        Response.Add('taskId', TaskId);
        exit(Response);
    end;

    local procedure ProcessAcquireCardResponse(EntryNo: Integer): JsonObject
    var
        EFTAdyenIntegration: Codeunit "NPR EFT Adyen Integration";
        ContinueOnEntryNo: Integer;
        Response: JsonObject;
        Parameters: Dictionary of [Text, Text];
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        TaskId: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        ResultMessageOut: Text;
    begin
        if not ProcessResponse(EntryNo) then
            exit;

        EFTTransactionRequest.Get(EntryNo);
        if EFTTransactionRequest."Result Code" = -10 then begin
            // Previous Trx is still in progress on terminal. Fire off abort in background to help it back to idle while processing this failure.
            TryAbortMostRecentTrx(EFTTransactionRequest);
        end;

        if EFTAdyenIntegration.ContinueAfterAcquireCard(EntryNo, ContinueOnEntryNo) then begin
            //Carry the acquire card operation into a payment operation on the terminal.

            Parameters.Add('EntryNo', Format(ContinueOnEntryNo));
            _trxStatus.Set(ContinueOnEntryNo, Enum::"NPR EFT Adyen Task Status"::Initiated.AsInteger());

            POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
            POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_TRX, Parameters, 1000 * 60 * 5);

            Response.Add('taskId', TaskId);
            Response.Add('done', false);
            Response.Add('newEntryNo', ContinueOnEntryNo);
        end else begin
            if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then begin
                Message(ResultMessageOut);
            end;

            // Fire off cancel of the acquire card operation in the background so terminal goes back to idle again.
            CancelAcquisition(EntryNo);
            _trxStatus.Set(EntryNo, Enum::"NPR EFT Adyen Task Status"::ResultReceived.AsInteger());

            Response.Add('done', true);
            Response.Add('success', false);
        end;

        exit(Response);
    end;

    local procedure ProcessResult(EntryNo: Integer): JsonObject
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        POSSession: Codeunit "NPR POS Session";
        Response: JsonObject;
        EFTAdyenSignatureBuffer: Codeunit "NPR EFT Adyen Signature Buffer";
        SignatureEntryNo: Integer;
        SignatureJson: Text;
        MissingBitmapLbl: Label 'Missing signature bitmap';
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
        ResultMessageOut: Text;
    begin
        if not ProcessResponse(EntryNo) then
            exit;

        EFTTransactionRequest.Get(EntryNo);

        if not Codeunit.Run(Codeunit::"NPR EFT Try Print Receipt", EftTransactionRequest) then
            Message(GetLastErrorText);
        Commit();

        if (not EftTransactionRequest.Successful) then begin
            if EFTTransactionRequest."Result Code" = -10 then begin
                // Previous Trx is still in progress on terminal. Fire off abort in background to help it back to idle while processing this failure.
                TryAbortMostRecentTrx(EFTTransactionRequest);
            end;
        end;

        if EFTAdyenResponseHandler.GetResultMessage(EFTTransactionRequest, ResultMessageOut) then begin
            Message(ResultMessageOut);
        end;

        // Needed because POS lines could have been updated in the background task continuation
        // so the delta calculation on user session does not work as it happened outside the action.
        POSSession.RequestFullRefresh();

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

    local procedure SignatureDecline(EntryNo: Integer): JsonObject
    var
        Parameters: Dictionary of [Text, Text];
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        TaskId: Integer;
        EftSetup: Record "NPR EFT Setup";
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
    begin
        EftTransactionRequest.Get(EntryNo);
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        EFTFrameworkMgt.CreateVoidRequest(VoidEFTTransactionRequest, EftSetup, EftTransactionRequest."Register No.", EftTransactionRequest."Sales Ticket No.", EntryNo, false);
        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        Parameters.Add('EntryNo', Format(VoidEFTTransactionRequest."Entry No."));
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_TRX, Parameters, 1000 * 60 * 5);
        _trxStatus.Set(VoidEFTTransactionRequest."Entry No.", Enum::"NPR EFT Adyen Task Status"::Initiated.AsInteger());

        Response.Add('taskId', TaskId);
        Response.Add('done', false);
        Response.Add('newEntryNo', VoidEFTTransactionRequest."Entry No.");
        exit(Response);
    end;

    local procedure StartLookup(EntryNo: Integer): JsonObject
    var
        Parameters: Dictionary of [Text, Text];
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        TaskId: Integer;
        EftSetup: Record "NPR EFT Setup";
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
    begin
        EftTransactionRequest.Get(EntryNo);
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        Parameters.Add('EntryNo', Format(EntryNo));
        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_LOOKUP, Parameters, 1000 * 60 * 5);
        _trxStatus.Set(EntryNo, Enum::"NPR EFT Adyen Task Status"::LookupInitiated.AsInteger());

        Response.Add('taskId', TaskId);
        Response.Add('done', false);
        exit(Response);
    end;

    local procedure RequestTrxAbort(EntryNo: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AbortReqEntryNo: Integer;
        eftSetup: Record "NPR EFT Setup";
        Parameters: Dictionary of [Text, Text];
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        TaskId: Integer;
        AbortTaskActive: Boolean;
        EFTAdyenAbortMgmt: Codeunit "NPR EFT Adyen Abort Mgmt";
    begin
        if _trxAbortStatus.Get(EntryNo, AbortTaskActive) then begin
            if AbortTaskActive then begin
                exit; //Only start at most 1 task for attempting to abort trx. When task is done it will reset this boolean.
            end;
        end;

        EFTTransactionRequest.Get(EntryNo);
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        AbortReqEntryNo := EFTAdyenAbortMgmt.CreateAbortTransactionRequest(EFTTransactionRequest);

        Parameters.Add('EntryNo', Format(AbortReqEntryNo));
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_ABORT, Parameters, 1000 * 10);
        _trxAbortStatus.Set(EFTTransactionRequest."Entry No.", true);
    end;

    local procedure CancelAcquisition(EntryNo: Integer)
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AbortReqEntryNo: Integer;
        eftSetup: Record "NPR EFT Setup";
        Parameters: Dictionary of [Text, Text];
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        TaskId: Integer;
        EFTAdyenAbortMgmt: Codeunit "NPR EFT Adyen Abort Mgmt";
    begin
        EFTTransactionRequest.Get(EntryNo);
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        AbortReqEntryNo := EFTAdyenAbortMgmt.CreateAbortAcquireCardRequest(EFTTransactionRequest);

        Parameters.Add('EntryNo', Format(AbortReqEntryNo));
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_ADYEN_CLOUD_ACQ_ABORT, Parameters, 1000 * 10);
        _trxAbortStatus.Set(EFTTransactionRequest."Entry No.", true);
    end;

    local procedure TryAbortMostRecentTrx(EFTTransactionRequest: Record "NPR EFT Transaction Request")
    var
        EFTAdyenAbortMgmt: Codeunit "NPR EFT Adyen Abort Mgmt";
        EntryNoToAbort: Integer;
    begin
        if not EFTAdyenAbortMgmt.CanAbortLastUnfinishedTrx(EFTTransactionRequest, EntryNoToAbort) then
            exit;

        RequestTrxAbort(EntryNoToAbort);
    end;

    local procedure ProcessResponse(EntryNo: Integer): Boolean
    var
        ResponseList: List of [Text];
        Completed: Boolean;
        Started: Boolean;
        EFTAdyenResponseHandler: Codeunit "NPR EFT Adyen Response Handler";
    begin
        if not _trxResponse.Get(EntryNo, ResponseList) then
            exit(false);

        Evaluate(Completed, ResponseList.Get(2));
        Evaluate(Started, ResponseList.Get(3));
        EFTAdyenResponseHandler.ProcessResponse(EntryNo, ResponseList.Get(1), Completed, Started, ResponseList.Get(4));
        Commit();
        exit(true);
    end;

    local procedure ClearGlobalState()
    begin
        clear(_trxStatus);
        clear(_trxAbortStatus);
    end;

    procedure SetTrxStatus(EntryNo: Integer; StatusIn: Enum "NPR EFT Adyen Task Status")
    begin
        _trxStatus.Set(EntryNo, StatusIn.AsInteger());
    end;

    procedure SetAbortStatus(EntryNo: Integer; StatusIn: Boolean)
    begin
        _trxAbortStatus.Set(EntryNo, StatusIn);
    end;

    procedure SetTrxResponse(EntryNo: Integer; Response: Text; Completed: Boolean; Started: Boolean; ErrorText: Text)
    var
        ResponseList: List of [Text];
    begin
        ResponseList.Add(Response);
        ResponseList.Add(Format(Completed));
        ResponseList.Add(Format(Started));
        ResponseList.Add(ErrorText);
        _trxResponse.Set(EntryNo, ResponseList);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTAdyenCloud.js###
'let main=async({workflow:r,context:e,popup:i,captions:s})=>{e.EntryNo=e.request.EntryNo;let a;e.unattended||(a=await i.simplePayment({title:e.request.TypeCaption,initialStatus:s.initialStatus,showStatus:!0,amount:e.request.formattedAmount,onAbort:async()=>{await r.respond("requestAbort")}}));try{let n=await r.respond("startTransaction");n.newEntryNo&&(e.EntryNo=n.newEntryNo),a&&a.updateStatus(s.activeStatus),a&&a.enableAbort(!0),await trxPromise(e,s,i,r)}finally{a&&a.close()}return{success:e.success,tryEndSale:e.success}};function trxPromise(r,e,i,s){return new Promise((a,n)=>{let u=async()=>{try{let t=await s.respond("poll");if(t.newEntryNo){debugger;r.EntryNo=t.newEntryNo,setTimeout(u,1e3);return}if(t.signatureRequired){let o=!1;if(t.signatureType==="Receipt"&&(o=await i.confirm(e.approveSignature)),t.signatureType==="Bitmap"){debugger;let l=JSON.parse(t.signatureBitmap),g=await i.signatureValidation({signature:l.SignaturePoint});debugger;o=await g.completeAsync()}if(!o){let l=await s.respond("signatureDecline");r.EntryNo=l.newEntryNo,setTimeout(u,1e3);return}}if(t.done){debugger;r.success=t.success,a();return}}catch(t){debugger;try{await s.respond("requestAbort")}catch{}n(t);return}setTimeout(u,1e3)};setTimeout(u,1e3)})}'
        );
    end;
}
