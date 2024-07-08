codeunit 6014443 "NPR LogMessage Stopwatch"
{
    var
        _ActiveSession: Record "Active Session";
        _LogDict: Dictionary of [Text, Text];
        _Msg: Text;
        _StartDT: DateTime;
        _FinishDT: DateTime;
        _Started: Boolean;

        _ErrorTxt: Text;

    procedure LogStart(Company: Text; ObjectName: Text; ProcedureName: Text)
    var
        StartEventIdTok: Label 'NPR000_START', Locked = true;
        MsgTok: Label 'Object: %1, Procedure: %2 in Company:%3, Tenant: %4, ServiceName: %5, Server: %6';
    begin
        _ErrorTxt := '';
        _StartDT := CurrentDateTime();

        // this will not be found if eg. Install of app was triggered via web client and session was closed
        if not _ActiveSession.Get(Database.ServiceInstanceId(), Database.SessionId()) then
            Clear(_ActiveSession);

        _Msg := StrSubstNo(MsgTok, ObjectName, ProcedureName, Company, Database.TenantId(), _ActiveSession."Server Instance Name", _ActiveSession."Server Computer Name");

        Clear(_LogDict);

        _LogDict.Add('NPR_Server', _ActiveSession."Server Computer Name");
        _LogDict.Add('NPR_Instance', _ActiveSession."Server Instance Name");
        _LogDict.Add('NPR_TenantId', Database.TenantId());
        _LogDict.Add('NPR_CompanyName', Company); // company could be diffferent from CompanyName() result in this codeunit
        _LogDict.Add('NPR_ObjectName', ObjectName); // there allready is ObjectName being logged automaticaly but it picks up this codeunit
        _LogDict.Add('NPR_ProcedureName', ProcedureName);
        _LogDict.Add('NPR_Start', Format(_StartDT, 0, 9));

        Session.LogMessage(StartEventIdTok, 'Start: ' + _Msg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, _LogDict);

        _Started := true;
    end;

    procedure LogFinish()
    var
        FinishEventIdTok: Label 'NPR000_FINISH', Locked = true;
        FinishWithoutStartErr: Label 'LogFinish() called without LogStart().';
    begin
        if not _Started then begin
            _ErrorTxt := '';
            Clear(_LogDict);
            _Msg := FinishWithoutStartErr;
        end else begin
            _FinishDT := CurrentDateTime();
            _LogDict.Add('NPR_Finish', Format(_FinishDT, 0, 9));
            _LogDict.Add('NPR_Duration', Format(_FinishDT - _StartDT, 0, 9));

            if _ErrorTxt <> '' then
                _LogDict.Add('NPR_Error', _ErrorTxt);
        end;

        Session.LogMessage(FinishEventIdTok, 'Stop: ' + _Msg, Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::All, _LogDict);

        _Started := false;
    end;

    procedure SetError(ErrorTxt: Text)
    begin
        _ErrorTxt := ErrorTxt;
    end;

}
