codeunit 6014641 "NPR BTF Service API"
{
    var
        SampleLbl: Label 'Sample.%1', Comment = '%1=File Extension';
        SendReqToLiveEnvQst: Label 'Do you want to send request on live environment?';
        ResponseContentNotFoundMsg: Label 'Response content not found. Instead, check out Response Note to see error details.';

    procedure VerifyServiceURL(var ServiceURL: Text)
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
    begin
        if ServiceURL = '' then
            exit;
        HttpWebRequestMgt.CheckUrl(ServiceURL);
        RemoveLastSlashFromPath(ServiceURL, 8);
    end;

    procedure RemoveLastSlashFromPath(var Path: Text; StartLength: Integer)
    begin
        if Path = '' then
            exit;

        while (StrLen(Path) > StartLength) and (Path[StrLen(Path)] = '/') do
            Path := CopyStr(Path, 1, StrLen(Path) - 1);
    end;

    procedure SendRequestAndDownloadResult(ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        ServiceSetup: Record "NPR BTF Service Setup";
        Response: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        EndPoint: Interface "NPR BTF IEndPoint";
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        ServiceEndPoint.TestField(Enabled);
        EndPoint := ServiceEndPoint."EndPoint Method";
        ServiceSetup.get(ServiceEndPoint."Service Code");
        ServiceSetup.TestField(Enabled);
        if ServiceSetup.Environment = ServiceSetup.Environment::production then
            if not Confirm(SendReqToLiveEnvQst, false) then
                exit;
        EndPoint.SendRequest(ServiceSetup, ServiceEndPoint, Response);
        FormatResponse := ServiceEndPoint.Accept;
        FileMgt.BLOBExport(Response, strsubstno(SampleLbl, FormatResponse.GetFileExtension()), true);
    end;

    procedure SendWebRequest(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob")
    var
        EndPoint: Interface "NPR BTF IEndPoint";
    begin
        EndPoint := ServiceEndPoint."EndPoint Method";
        EndPoint.SendRequest(ServiceSetup, ServiceEndPoint, Response);
    end;

    [TryFunction]
    procedure CheckServiceSetup(Setup: Record "NPR BTF Service Setup")
    begin
        Setup.TestField(Username);
        Setup.testfield(Password);
        Setup.TestField("Service URL");
        Setup.TestField("Subscription-Key");
        if Setup.Environment = Setup.Environment::Production then
            Setup.testfield(Portal);
    end;

    [TryFunction]
    procedure CheckServiceEndPoint(EndPoint: Record "NPR BTF Service EndPoint")
    begin
        EndPoint.TestField(Path);
    end;

    [NonDebuggable]
    procedure GetBase64Authorization(Setup: Record "NPR BTF Service Setup"): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        Base64Auth: Text;
    begin
        Base64Auth := StrSubstNo('%1:%2', Setup.Username, Setup.Password);
        exit(StrSubstNo('Basic %1', Base64Convert.ToBase64(Base64Auth)));
    end;

    [NonDebuggable]
    procedure GetTokenFromResponse(ServiceEndPoint: Record "NPR BTF Service EndPoint"; Response: Codeunit "Temp Blob"): Text
    var
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        FormatResponse := ServiceEndPoint.Accept;
        exit(FormatResponse.GetToken(Response));
    end;

    [NonDebuggable]
    procedure IsTokenAvailable(ServiceEndPoint: Record "NPR BTF Service EndPoint"; Response: Codeunit "Temp Blob"): Boolean
    var
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        FormatResponse := ServiceEndPoint.Accept;
        exit(FormatResponse.FoundToken(Response));
    end;

    procedure LogEndPointError(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; Response: Codeunit "Temp Blob"; CurrUserId: Code[50]; ErrorNote: Text; InitiatiedFromRecID: RecordID)
    var
        ErrorLog: Record "NPR BTF EndPoint Error Log";
    begin
        ErrorLog.InitRec(CurrUserId, InitiatiedFromRecID);
        ErrorLog.CopyFromServiceSetup(ServiceSetup);
        ErrorLog.CopyFromServiceEndPoint(ServiceEndPoint);
        ErrorLog.SetResponse(Response, ServiceEndPoint, ErrorNote);
        ErrorLog.Insert(true);
    end;

    procedure ShowErrorLogEntries(ServiceSetupCode: Code[20])
    var
        ErrorLog: Record "NPR BTF EndPoint Error Log";
    begin
        ErrorLog.SetRange("Service Code", ServiceSetupCode);
        Page.Run(0, ErrorLog);
    end;

    procedure ShowErrorLogEntries(ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        ErrorLog: Record "NPR BTF EndPoint Error Log";
    begin
        ErrorLog.SetRange("Service Code", ServiceEndPoint."Service Code");
        ErrorLog.SetRange("EndPoint ID", ServiceEndPoint."EndPoint ID");
        Page.Run(0, ErrorLog);
    end;

    procedure DownloadErrorLogResponse(ErrorLog: Record "NPR BTF EndPoint Error Log")
    var
        ResponseBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        OutStr: OutStream;
    begin
        if not ErrorLog.Response.HasValue() then begin
            Message(ResponseContentNotFoundMsg);
            exit;
        end;
        ResponseBlob.CreateOutStream(OutStr);
        ErrorLog.Response.ExportStream(OutStr);
        FileMgt.BLOBExport(ResponseBlob, ErrorLog."Response File Name", true);
    end;

    procedure ShowWhoInitiateWebReqSending(ErrorLog: Record "NPR BTF EndPoint Error Log")
    var
        PageManagement: Codeunit "Page Management";
        RecRef: RecordRef;
    begin
        if not RecRef.Get(ErrorLog."Initiatied From Rec. ID") then begin
            Message(ResponseContentNotFoundMsg, Format(ErrorLog."Initiatied From Rec. ID"));
            exit;
        end;
        PageManagement.PageRun(RecRef);
    end;

    procedure GetSelectionFilterForServiceEndPoints(var ServiceEndPoint: Record "NPR BTF Service EndPoint"): Text
    var
        SelectionFilterMgt: Codeunit SelectionFilterManagement;
        RecRef: RecordRef;
    begin
        RecRef.GetTable(ServiceEndPoint);
        exit(SelectionFilterMgt.GetSelectionFilter(RecRef, ServiceEndPoint.FieldNo("EndPoint ID")));
    end;
}