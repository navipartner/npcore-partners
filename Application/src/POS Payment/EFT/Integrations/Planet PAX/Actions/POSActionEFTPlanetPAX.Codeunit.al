codeunit 6150841 "NPR POS Action: EFT Planet PAX" implements "NPR IPOS Workflow"
{
    Access = Internal;

    var
        StateMgt: Codeunit "NPR EFT Planet Pax State";
        LogCU: Codeunit "NPR EFT Planet PAX Logger";
        LogLvl: Enum "NPR EFT Planet Pax Log Lvl";

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'EFT Request Workflow';
        TitlePayment: Label 'Planet PAX Payment';
        TitleRefund: Label 'Planet PAX Refund';
        TitleLookup: Label 'Planet PAX Lookup';
        TitleVoid: Label 'Planet PAX Cancel';
        InitStatusPayment: Label 'Initializing payment';
        InitStatusRefund: Label 'Initializing refund';
        InitStatusLookup: Label 'Initializing lookup';
        InitStatusVoid: Label 'Initializing cancellation';
        ActiveStatusLbl: Label 'Waiting For Response';
        Aborting: Label 'Aborting...';

    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('TitlePayment', TitlePayment);
        WorkflowConfig.AddLabel('TitleRefund', TitleRefund);
        WorkflowConfig.AddLabel('TitleLookup', TitleLookup);
        WorkflowConfig.AddLabel('TitleVoid', TitleVoid);
        WorkflowConfig.AddLabel('InitStatusPayment', InitStatusPayment);
        WorkflowConfig.AddLabel('InitStatusRefund', InitStatusRefund);
        WorkflowConfig.AddLabel('InitStatusLookup', InitStatusLookup);
        WorkflowConfig.AddLabel('InitStatusVoid', InitStatusVoid);
        WorkflowConfig.AddLabel('activeStatus', ActiveStatusLbl);
        WorkflowConfig.AddLabel('statusAborting', Aborting);
    end;


    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        Response: JsonObject;
    begin
        case Step of
            'startRequest':
                begin
                    StartTransaction(Context);
                end;
            'pollRequest':
                begin
                    Response := PollTransaction(Context);
                end;
            'abortRequest':
                begin
                    AbortTransaction(Context);
                end;
            'promptSignature':
                begin
                    Response := SignaturePrompt(Context);
                end;
        end;
        FrontEnd.WorkflowResponse(Response);
    end;


    local procedure StartTransaction(var Context: Codeunit "NPR POS JSON Helper")
    var
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        Parameters: Dictionary of [Text, Text];
        TaskId: Integer;
        EftNo: Integer;
    begin
        StateMgt.ClearState();
        EftNo := Context.GetInteger('EFTEntryNo');
        Parameters.Add('EFTEntryNo', Format(Context.GetInteger('EFTEntryNo')));
        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_PLANET_PAX_TRX, Parameters, (120 * 1000));
        Context.SetContext('EftTrxTaskId', TaskId);
        StateMgt.SetEftReqStatus(Format(EftNo), "NPR EFT Planet PAX Status"::Running);
        LogCU.Log(LogLvl::Verbose, EftNo, 'StartTrx', 'Start with Task ID: ' + Format(TaskId));
    end;

    local procedure AbortTransaction(var Context: Codeunit "NPR POS JSON Helper")
    var
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        Util3cXml: Codeunit "NPR EFT Planet PAX Util.";
        Parameters: Dictionary of [Text, Text];
        TaskId: Integer;
        EftNo: Integer;
        AbortCount: Integer;
    begin
        EftNo := Context.GetInteger('EFTEntryNo');
        LogCU.Log(LogLvl::Verbose, EftNo, 'AttemptAbort', 'Attempt abort: ' + Format(EftNo));
        if (Context.HasProperty('EftAbortRef')) then begin
            if (StateMgt.GetEftReqStatus(Context.GetString('EftAbortRef')) in
            ["NPR EFT Planet PAX Status"::Running, "NPR EFT Planet PAX Status"::ResponseReceived]) then begin
                exit;
            end;
        end;
        if (StateMgt.GetEftReqStatus(EftNo) <> "NPR EFT Planet PAX Status"::Running) then
            exit;
        AbortCount := StateMgt.GetAndIncrementAbortCount();
        Parameters.Add('EFTEntryNo', Format(EftNo));
        Parameters.Add('AbortCount', Format(AbortCount));
        Parameters.Add('EftAbortRef', Util3cXml.AbortId(EftNo, AbortCount));
        POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
        POSBackgroundTaskAPI.EnqueuePOSBackgroundTask(TaskId, Enum::"NPR POS Background Task"::EFT_PLANET_PAX_ABORT, Parameters, (60 * 1000));
        Context.SetContext('EftAbortTaskId', TaskId);
        Context.SetContext('EftAbortRef', Util3cXml.AbortId(EftNo, AbortCount));
        StateMgt.SetEftReqStatus(Util3cXml.AbortId(EftNo, AbortCount), "NPR EFT Planet PAX Status"::Running);
        StateMgt.SetEftReqStatus(EftNo, "NPR EFT Planet PAX Status"::AbortRequested);
        LogCU.Log(LogLvl::Verbose, EftNo, 'StartAbort', 'Abort started on task: ' + Format(TaskId));
    end;

    local procedure PollTransaction(var Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        ResponseHandler: Codeunit "NPR EFT Planet PAX Response";
        POSSession: Codeunit "NPR POS Session";
        POSBackgroundTaskAPI: Codeunit "NPR POS Background Task API";
        Protocol: Codeunit "NPR 3cXml Protocol";
        EftInterface: Codeunit "NPR EFT Interface";
        Response: JsonObject;
        AbortResult: Enum "NPR EFT Planet PAX Status";
        EftReq: Record "NPR EFT Transaction Request";
        PosLineLbl: Label 'PlanetPax %1', Locked = true;
        AbortSuccessLbl: Label 'Aborted';
    begin
        EftReq.Get(Context.GetInteger('EFTEntryNo'));
        case StateMgt.GetEftReqStatus(EftReq."Entry No.") of
            "NPR EFT Planet PAX Status"::Uninitialized:
                begin
                    Response.Add('done', False);
                    Response.Add('mainStatus', 'Uninitialized');
                end;
            "NPR EFT Planet PAX Status"::Running:
                begin
                    Response.Add('done', False);
                    Response.Add('mainStatus', 'Running');
                end;
            "NPR EFT Planet PAX Status"::AbortRequested:
                begin
                    Response.Add('done', False);
                    Response.Add('mainStatus', 'AbortRequested');
                end;
            "NPR EFT Planet PAX Status"::ResponseReceived:
                begin
                    LogCU.Log(LogLvl::Verbose, EftReq, 'Request', StateMgt.GetRequest(EftReq."Entry No."));
                    LogCU.Log(LogLvl::Verbose, EftReq, 'ResponseReceived', StateMgt.GetResponse(EftReq."Entry No."));

                    Response.Add('done', True);
                    Response.Add('mainStatus', 'ResponseReceived');

                    Protocol.HandleEftResponse(StateMgt.GetResponse(EftReq."Entry No."), EftReq);
                    EftInterface.EftIntegrationResponse(EftReq);
                    Response.Add('success', EftReq.Successful);
                    Response.Add('needSignature', NeedSignature(EftReq));
                    StateMgt.ClearState();
                end;
            "NPR EFT Planet PAX Status"::Aborted:
                begin
                    EftReq."Result Description" := 'Aborted';
                    EftReq.Successful := False;
                    EftReq."POS Description" := CopyStr(StrSubstNo(PosLineLbl, AbortSuccessLbl), 1, 100);
                    EftReq."External Result Known" := True;
                    LogCU.Log(LogLvl::Verbose, EftReq, 'Aborted', '');
                    EftInterface.EftIntegrationResponse(EftReq);
                    Response.Add('done', True);
                    Response.Add('mainStatus', 'Aborted');
                    Response.Add('success', false);
                    StateMgt.ClearState();
                end;
            "NPR EFT Planet PAX Status"::Cancelled:
                begin
                    Message('A timeout ouccoured when processing the transaction. Looking up request.');
                    LogCU.Log(LogLvl::Verbose, EftReq, 'Cancelled', '');
                    EftReq."Result Description" := CopyStr(StateMgt.GetResponse(EftReq."Entry No."), 1, 50);
                    EftReq.Successful := False;
                    EftReq."POS Description" := CopyStr('EFT Error: ' + StateMgt.GetResponse(EftReq."Entry No."), 1, 100);
                    EftReq."External Result Known" := False;
                    EftInterface.EftIntegrationResponse(EftReq);
                    DoSyncEft(EftReq, 'lookup');
                    Response.Add('done', True);
                    Response.Add('mainStatus', 'Cancelled');
                    Response.Add('success', false);
                    StateMgt.ClearState();
                end;
            "NPR EFT Planet PAX Status"::Error:
                begin
                    Message('An error ouccoured when processing the transaction. Looking up request.');
                    LogCU.Log(LogLvl::Verbose, EftReq, 'ErrorResponse', StateMgt.GetResponse(EftReq."Entry No."));
                    EftReq."Result Description" := CopyStr(StateMgt.GetResponse(EftReq."Entry No."), 1, 50);
                    EftReq.Successful := False;
                    EftReq."POS Description" := CopyStr('EFT Error: ' + StateMgt.GetResponse(EftReq."Entry No."), 1, 100);
                    EftReq."External Result Known" := False;
                    EftInterface.EftIntegrationResponse(EftReq);
                    DoSyncEft(EftReq, 'lookup');
                    Response.Add('done', True);
                    Response.Add('mainStatus', 'Error');
                    Response.Add('success', false);
                    StateMgt.ClearState();
                end;
        end;

        if (Context.HasProperty('EftAbortRef')) then begin
            if (StateMgt.GetEftReqStatus(Context.GetString('EftAbortRef')) = "NPR EFT Planet PAX Status"::ResponseReceived) then begin
                LogCU.Log(LogLvl::Verbose, EftReq, 'AbortRequest', StateMgt.GetRequest(Context.GetString('EftAbortRef')));
                LogCU.Log(LogLvl::Verbose, EftReq, 'AbortResponse', StateMgt.GetResponse(Context.GetString('EftAbortRef')));
                if (not ResponseHandler.HandleAbortResponse(StateMgt.GetResponse(Context.GetString('EftAbortRef')), AbortResult)) then begin
                    LogCU.Log(LogLvl::Error, EftReq, 'AbortHandleFailure', GetLastErrorText());
                end;
                if (AbortResult = "NPR EFT Planet PAX Status"::Success) then begin
                    POSSession.GetPOSBackgroundTaskAPI(POSBackgroundTaskAPI);
                    POSBackgroundTaskAPI.CancelBackgroundTask(Context.GetInteger('EftTrxTaskId'));
                end;
            end;
        end;
        exit(Response);
    end;

    local procedure NeedSignature(var EFTTransactionRequest: Record "NPR EFT Transaction Request"): Boolean
    var
        OriginalEFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        if not EFTTransactionRequest.Successful then
            exit(false);
        if not (EftTransactionRequest."Signature Type" = EftTransactionRequest."Signature Type"::"On Receipt") then
            exit(false);

        case true of
            EftTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]:
                ;
            EftTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::LOOK_UP]:
                begin
                    OriginalEFTTransactionRequest.Get(EFTTransactionRequest."Processed Entry No.");
                    if not (OriginalEFTTransactionRequest."Processing Type" in [EFTTransactionRequest."Processing Type"::PAYMENT, EFTTransactionRequest."Processing Type"::REFUND]) then
                        exit(false);
                end;
            else
                exit(false);
        end;
        exit(true);
    end;

    local procedure SignaturePrompt(var Context: Codeunit "NPR POS JSON Helper"): JsonObject
    var
        Response: JsonObject;
        SIGNATURE_APPROVAL: Label 'Customer must sign the receipt. Please confirm that signature is valid';
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
    begin
        EFTTransactionRequest.Get(Context.GetInteger('EFTEntryNo'));
        if Confirm(SIGNATURE_APPROVAL) then begin
            Response.Add('success', true);
        end else begin
            DoSyncEft(EFTTransactionRequest, 'void');
            Response.Add('success', false);
        end;
        exit(Response);
    end;

    local procedure DoSyncEft(EFTTransactionRequest: Record "NPR EFT Transaction Request"; EftType: Text)
    var
        EFTSetup: Record "NPR EFT Setup";
        SyncEFTTransactionRequest: Record "NPR EFT Transaction Request";
        EFTFrameworkMgt: Codeunit "NPR EFT Framework Mgt.";
        EFTTransactionMgt: Codeunit "NPR EFT Transaction Mgt.";
        POSSession: Codeunit "NPR POS Session";
        POSSale: Codeunit "NPR POS Sale";
        POSSaleRecord: Record "NPR POS Sale";
        Request: JsonObject;
        Mechanism: Enum "NPR EFT Request Mechanism";
        Workflow: Text;
        EntryNo: Integer;
    begin
        if ((EftType <> 'void') and (EftType <> 'lookup')) then
            Error('Programming Error: Can only use void and lookup EFT requests for DoSyncEft');
        EFTSetup.FindSetup(EFTTransactionRequest."Register No.", EFTTransactionRequest."Original POS Payment Type Code");
        POSSession.GetSale(POSSale);
        POSSale.GetCurrentSale(POSSaleRecord);
        if (EftType = 'void') then
            EntryNo := EFTTransactionMgt.PrepareVoid(EFTSetup, POSSaleRecord, EFTTransactionRequest."Entry No.", false, Request, Mechanism, Workflow)
        else
            EntryNo := EFTTransactionMgt.PrepareLookup(EFTSetup, POSSaleRecord, EFTTransactionRequest."Entry No.", Request, Mechanism, Workflow);
        SyncEFTTransactionRequest.Get(EntryNo);
        Commit();
        EFTFrameworkMgt.SendSynchronousRequest(SyncEFTTransactionRequest);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionEFTPlanetPAX.js###
'let main=async({workflow:a,context:e,captions:t,popup:d})=>{e.EFTEntryNo=e.request.EFTEntryNo;let n="",i="",l="";switch(e.request.EFTReqType.toLowerCase()){case"payment":n=t.TitlePayment,i=t.InitStatusPayment,l=e.request.formattedAmount,e.TaskType="Payment";break;case"refund":n=t.TitleRefund,i=t.InitStatusRefund,l=e.request.formattedAmount,e.TaskType="Refund";break;default:throw new Error("Unsupported EFT Request ''"+e.request.EFTReqType.toLowerCase()+"''")}let s=await d.simplePayment({title:n,initialStatus:i,showStatus:!0,amount:l,onAbort:async()=>{s.updateStatus(t.statusAborting),await a.respond("abortRequest")}}),m=new Promise((y,p)=>{let o=async()=>{try{let r=await a.respond("pollRequest");if(r.done){y(r);return}}catch(r){await a.respond("abortRequest"),p(r);return}setTimeout(o,1e3)};setTimeout(o,1e3)}),u=null;try{await a.respond("startRequest"),s.updateStatus(t.activeStatus),s.enableAbort(!0),u=await m,u.needSignature&&await a.respond("promptSignature")}finally{s&&s.close()}return{success:u.success,tryEndSale:u.success}};'
        );
    end;
}
