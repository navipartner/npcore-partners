codeunit 6150878 "NPR EFT Planet PAX Trx" implements "NPR POS Background Task"
{
    Access = Internal;

    var
        LogCU: Codeunit "NPR EFT Planet PAX Logger";
        LogLvl: Enum "NPR EFT Planet Pax Log Lvl";

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EftEntry: Text;
        Request: Text;
        Response: Text;
        EftEntryNo: Integer;
        EftReq: Record "NPR EFT Transaction Request";
        Config: Record "NPR EFT Planet PAX Config";
        Protocol3cXml: Codeunit "NPR 3cXml Protocol";
        NoEftLbl: Label 'A background task was called without an EFT reference.';
        NoConfigLbl: Label 'No Planet Pax Configuration was found for this POS Unit.';
    begin
        if (not Parameters.Get('EFTEntryNo', EftEntry) or
            not Evaluate(EftEntryNo, EftEntry) or
            not EftReq.Get(EftEntryNo)) then
            Error(NoEftLbl);
        if (not Config.Get(EftReq."Register No.")) then
            Error(NoConfigLbl);
        Request := Protocol3cXml.PreparePlanetPaxEftRequest(EftReq);
        Result.Add('3cXmlRequest', Request);
        Protocol3cXml.SendRequest(Config."Url Endpoint", Request, Response);
        Result.Add('3cXmlResponse', Response);
    end;

    procedure BackgroundTaskSuccessContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; Results: Dictionary of [Text, Text]);
    var
        state: Codeunit "NPR EFT Planet Pax State";
        EftEntry: Text;
        EftEntryNo: Integer;
    begin
        Parameters.Get('EFTEntryNo', EftEntry);
        Evaluate(EftEntryNo, EftEntry);
        LogCU.Log(LogLvl::Verbose, EftEntryNo, 'SuccessAbortBgTask', 'TaskId: ' + Format(TaskId));
        state.AddEftReqResponse(EftEntryNo, Results.Get('3cXmlResponse'));
        state.AddEftReqRequest(EftEntryNo, Results.Get('3cXmlRequest'));
        state.SetEftReqStatus(EftEntryNo, "NPR EFT Planet PAX Status"::ResponseReceived);
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        state: Codeunit "NPR EFT Planet Pax State";
        EftEntry: Text;
        EftEntryNo: Integer;
    begin
        Parameters.Get('EFTEntryNo', EftEntry);
        Evaluate(EftEntryNo, EftEntry);
        LogCU.Log(LogLvl::Error, EftEntryNo, 'ErrorAbortBgTask', 'TaskId: ' + Format(TaskId) + ' Error: ' + ErrorCode + ' ' + ErrorText + ' ' + ErrorCallStack);
        state.AddEftReqResponse(EftEntryNo, ErrorText);
        state.SetEftReqStatus(EftEntryNo, "NPR EFT Planet PAX Status"::Error);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        state: Codeunit "NPR EFT Planet Pax State";
        EftEntry: Text;
        EftEntryNo: Integer;
    begin
        Parameters.Get('EFTEntryNo', EftEntry);
        Evaluate(EftEntryNo, EftEntry);
        LogCU.Log(LogLvl::Verbose, EftEntryNo, 'CancelledAbortBgTask', 'TaskId: ' + Format(TaskId));
        if (state.GetEftReqStatus(EftEntryNo) = "NPR EFT Planet PAX Status"::AbortRequested) then begin
            state.AddEftReqResponse(EftEntryNo, 'Aborted');
            state.SetEftReqStatus(EftEntryNo, "NPR EFT Planet PAX Status"::Aborted);
        end else begin
            state.AddEftReqResponse(EftEntryNo, 'Task timed out');
            state.SetEftReqStatus(EftEntryNo, "NPR EFT Planet PAX Status"::Cancelled);
        end;
    end;
}