codeunit 6184635 "NPR EFT Planet PAX Abort" implements "NPR POS Background Task"
{
    Access = Internal;

    procedure ExecuteBackgroundTask(TaskId: Integer; Parameters: Dictionary of [Text, Text]; var Result: Dictionary of [Text, Text]);
    var
        EftEntry: Text;
        Request: Text;
        Response: Text;
        EftEntryNo: Integer;
        AbortCount: Integer;
        EftReq: Record "NPR EFT Transaction Request";
        Config: Record "NPR EFT Planet PAX Config";
        PlanetPaxReq: Codeunit "NPR EFT Planet PAX Req.";
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
        Evaluate(AbortCount, Parameters.Get('AbortCount'));
        Request := PlanetPaxReq.CancelRequest(Config, EftReq."Entry No.", AbortCount);
        Result.Add('3cXmlRequest', Request);
        Protocol3cXml.SendRequest(Config."Url Endpoint", Request, Response);
        Result.Add('3cXmlResponse', Response);
    end;

    procedure BackgroundTaskSuccessContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; Results: Dictionary of [Text, Text]);
    var
        state: Codeunit "NPR EFT Planet Pax State";
        EftAbortRef: Text;
    begin
        Parameters.Get('EftAbortRef', EftAbortRef);
        state.AddEftReqResponse(EftAbortRef, Results.Get('3cXmlResponse'));
        state.AddEftReqRequest(EftAbortRef, Results.Get('3cXmlRequest'));
        state.SetEftReqStatus(EftAbortRef, "NPR EFT Planet PAX Status"::ResponseReceived);
    end;

    procedure BackgroundTaskErrorContinuation(TaskId: Integer; Parameters: Dictionary of [Text, Text]; ErrorCode: Text; ErrorText: Text; ErrorCallStack: Text);
    var
        state: Codeunit "NPR EFT Planet Pax State";
        EftAbortRef: Text;
    begin
        Parameters.Get('EftAbortRef', EftAbortRef);
        state.AddEftReqResponse(EftAbortRef, ErrorText);
        state.SetEftReqStatus(EftAbortRef, "NPR EFT Planet PAX Status"::Error);
    end;

    procedure BackgroundTaskCancelled(TaskId: Integer; Parameters: Dictionary of [Text, Text]);
    var
        state: Codeunit "NPR EFT Planet Pax State";
        EftAbortRef: Text;
    begin
        Parameters.Get('EftAbortRef', EftAbortRef);
        state.AddEftReqResponse(EftAbortRef, 'Timed out');
        state.SetEftReqStatus(EftAbortRef, "NPR EFT Planet PAX Status"::Cancelled);
    end;
}