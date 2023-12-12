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
        ApproveSignatureLbl: Label 'Approve signature on receipt?';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddLabel('initialStatus', InitialStatusLbl);
        WorkflowConfig.AddLabel('title', TitleLbl);
        WorkflowConfig.AddLabel('activeStatus', ActiveStatusLbl);
        WorkflowCOnfig.AddLabel('approveSignature', ApproveSignatureLbl);
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
            'signatureDecline':
                SignatureDecline(Context.GetInteger('EntryNo'));
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
                    if EFTNETSCloudIntegrat.SignaturePrompt(EFTTransactionRequest) then begin
                        Response.Add('signatureRequired', true);
                    end;
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

    local procedure SignatureDecline(EntryNo: Integer)
    var
        VoidEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTSetup: Record "NPR EFT Setup";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        POSSession: Codeunit "NPR POS Session";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        Request: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
        VoidEntryNo: Integer;
    begin
        Sleep(5 * 1000);
        //Gap in integration - we need to void if signature was declined, however we have no way of knowing if terminal is ready to accept a void request yet,
        //because we are not receiving events from it. We have observed "terminal busy" errors for this scenario.
        //Sleeping 5 seconds is a pragmatic workaround to reduce impact of this problem.
        //A manual "void last" is the solution if this fails but it will confuse sales person.
        //The real fix requires a better API from NETS

        EFTTransactionRequest.Get(EntryNo);

        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRecord);

        VoidEntryNo := EFTTransactionMgt.PrepareVoid(EFTSetup, POSSaleRecord, EFTTransactionRequest."Entry No.", false, Request, Mechanism, Workflow);
        VoidEFTTransactionRequest.Get(VoidEntryNo);
        Commit();
        EFTFrameworkMgt.SendSynchronousRequest(VoidEFTTransactionRequest);
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
'let main=async({workflow:t,context:e,popup:i,captions:s})=>{e.EntryNo=e.request.EntryNo;let r=await i.simplePayment({title:s.title,initialStatus:s.initialStatus,showStatus:!0,amount:e.request.formattedAmount,onAbort:async()=>{await t.respond("requestAbort")}}),n=new Promise((l,c)=>{let u=async()=>{try{let a=await t.respond("poll");if(a.done){a.signatureRequired&&(await i.confirm(s.approveSignature)||await t.respond("signatureDecline"));debugger;e.success=a.success,l();return}}catch(a){try{await t.respond("requestAbort")}catch{}c(a);return}setTimeout(u,1e3)};setTimeout(u,1e3)});try{await t.respond("startTransaction"),r.updateStatus(s.activeStatus),r.enableAbort(!0),await n}finally{r&&r.close()}return{success:e.success,tryEndSale:e.success}};'
        );
    end;

}
