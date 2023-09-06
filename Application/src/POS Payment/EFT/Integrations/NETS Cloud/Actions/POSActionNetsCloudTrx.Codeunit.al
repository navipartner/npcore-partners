codeunit 6059906 "NPR POS Action: NetsCloud Trx" implements "NPR IPOS Workflow"
{
    Access = Internal;
    SingleInstance = true;

    var
        _trxStatus: Dictionary of [Integer, Integer]; //EntryNo, NETSCloudTrxStatusEnum
        _trxAbortStatus: Dictionary of [Integer, Boolean]; //EntryNo, BackgroundTaskIsRunning

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'NETS BAXI Cloud EFT Transaction';
        InitialStatusLbl: Label 'Initializing';
        ActiveStatusLbl: Label 'Waiting For Response';
        TitleLbl: Label 'Transaction';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('initialStatus', InitialStatusLbl);
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('activeStatus', ActiveStatusLbl);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'startTransaction':
                FrontEnd.WorkflowResponse(StartTransaction(Context));
            'poll':
                FrontEnd.WorkflowResponse(PollResponse(Context));
            'requestAbort':
                RequestAbort(Context);
        end;
    end;

    local procedure PollResponse(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        TrxStatus: Enum "NPR EFT NETSCloud Trx Status";
        EntryNo: Integer;
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Response: JsonObject;
        TrxErrorLbl: Label '%1 %2 failed\%3\%4';
        EFTNETSCloudIntegrat: Codeunit "NPR EFT NETSCloud Integrat.";
        POSSession: Codeunit "NPR POS Session";
    begin
        EntryNo := Context.GetInteger('EntryNo');
        TrxStatus := Enum::"NPR EFT NETSCloud Trx Status".FromInteger(_trxStatus.Get(EntryNo));

        case TrxStatus of
            TrxStatus::LookupNeeded:
                begin
                    StartLookup(EntryNo);
                end;
            TrxStatus::ResponseReceived:
                begin
                    EFTTransactionRequest.Get(EntryNo);

                    POSSession.RequestFullRefresh();
                    // Needed because payment line was inserted in the background task continuation
                    // so the delta calculation on user session does not work as it happened outside the action.


                    if (not EftTransactionRequest.Successful) then
                        Message(TrxErrorLbl, EftTransactionRequest."Integration Type", Format(EftTransactionRequest."Processing Type"), EftTransactionRequest."Result Display Text", EftTransactionRequest."NST Error");

                    Commit();
                    if not Codeunit.Run(Codeunit::"NPR EFT Try Print Receipt", EftTransactionRequest) then
                        Message(GetLastErrorText);
                    Commit();
                    EFTNETSCloudIntegrat.SignaturePrompt(EFTTransactionRequest);

                    Response.Add('done', true);
                    Response.Add('success', EFTTransactionRequest.Successful);
                    exit(Response);
                end;
        end;

        Response.Add('done', false);
        Response.Add('success', false);
        exit(Response);
    end;

    local procedure StartTransaction(Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        EftTransactionRequest: Record "NPR EFT Transaction Request";
        EftSetup: Record "NPR EFT Setup";
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        Parameters: Dictionary of [Text, Text];
        Response: JsonObject;
        TaskId: Integer;
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
    begin
        ClearGlobalState();
        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        EftTransactionRequest.Get(Context.GetInteger('EntryNo'));
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        Parameters.Add('EntryNo', Format(EftTransactionRequest."Entry No."));
        Parameters.Add('APIToken', EFTNETSCloudProtocol.GetToken(EFTSetup));
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_NETS_CLOUD_TRX, Parameters, 1000 * 60 * 5);

        _trxStatus.Set(EftTransactionRequest."Entry No.", Enum::"NPR EFT NETSCloud Trx Status"::Initiated.AsInteger());
        Response.Add('TaskId', TaskId);
        exit(Response);
    end;

    local procedure StartLookup(EntryNo: Integer)
    var
        Parameters: Dictionary of [Text, Text];
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        TaskId: Integer;
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        EftSetup: Record "NPR EFT Setup";
        EftTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EftTransactionRequest.Get(EntryNo);
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        Parameters.Add('EntryNo', Format(EntryNo));
        Parameters.Add('APIToken', EFTNETSCloudProtocol.GetToken(EFTSetup));
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_NETS_CLOUD_LOOKUP, Parameters, 1000 * 60 * 5);
        _trxStatus.Set(EntryNo, Enum::"NPR EFT NETSCloud Trx Status"::LookupInitiated.AsInteger());
    end;

    local procedure RequestAbort(Context: Codeunit "NPR POS JSON Helper")
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        eftSetup: Record "NPR EFT Setup";
        Parameters: Dictionary of [Text, Text];
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        TaskId: Integer;
        EntryNo: Integer;
        EFTNETSCloudProtocol: Codeunit "NPR EFT NETSCloud Protocol";
        AbortTaskActive: Boolean;
        TrxStatus: Integer;
    begin
        EntryNo := Context.GetInteger('EntryNo');
        if _trxAbortStatus.Get(EntryNo, AbortTaskActive) then begin
            if AbortTaskActive then begin
                exit; //Only start at most 1 task for attempting to abort trx. When task is done it will reset this boolean.
            end;
        end;
        if not _trxStatus.Get(EntryNo, TrxStatus) then
            exit;
        if TrxStatus <> Enum::"NPR EFT NETSCloud Trx Status"::Initiated.AsInteger() then
            exit; //Too late to abort if we have received response or moved to lookup lost result

        EFTTransactionRequest.Get(EntryNo);
        EftSetup.FindSetup(EftTransactionRequest."Register No.", EftTransactionRequest."Original POS Payment Type Code");

        Parameters.Add('EntryNo', Format(EftTransactionRequest."Entry No."));
        Parameters.Add('APIToken', EFTNETSCloudProtocol.GetToken(EFTSetup));
        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_NETS_CLOUD_ABORT, Parameters, 1000 * 10);
        _trxAbortStatus.Set(EFTTransactionRequest."Entry No.", true);
    end;

    local procedure ClearGlobalState()
    begin
        clear(_trxStatus);
        clear(_trxAbortStatus);
    end;

    procedure SetTrxStatus(EntryNo: Integer; StatusIn: Enum "NPR EFT NETSCloud Trx Status")
    begin
        _trxStatus.Set(EntryNo, StatusIn.AsInteger());
    end;

    procedure SetAbortStatus(EntryNo: Integer; StatusIn: Boolean)
    begin
        _trxAbortStatus.Set(EntryNo, StatusIn);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionNetsCloudTrx.Codeunit.js###
'let main=async({workflow:e,context:t,popup:u,captions:r})=>{t.EntryNo=t.request.EntryNo;let s=await u.simplePayment({title:r.title,initialStatus:r.initialStatus,showStatus:!0,amount:t.request.formattedAmount,onAbort:async()=>{await e.respond("requestAbort")}}),n=new Promise((l,o)=>{let i=async()=>{try{let a=await e.respond("poll");if(a.done){debugger;t.success=a.success,l();return}}catch(a){try{await e.respond("requestAbort")}catch{}o(a);return}setTimeout(i,1e3)};setTimeout(i,1e3)});try{await e.respond("startTransaction"),s.updateStatus(r.activeStatus),s.enableAbort(!0),await n}finally{s&&s.close()}return{success:t.success,tryEndSale:t.success}};'
        );
    end;

}
