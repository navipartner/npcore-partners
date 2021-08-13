codeunit 6014641 "NPR BTF Service API"
{
    Permissions = TableData "Job Queue Entry" = rm;

    var
        SampleLbl: Label 'Sample.%1', Comment = '%1=File Extension';
        SendReqToLiveEnvQst: Label 'Do you want to send request on live environment?';
        ResponseContentNotFoundMsg: Label 'Response content not found. Instead, check out Response Note to see error details: %1.';
        EmptyContentErr: Label 'Nothing to import';
        APIIntegrationLbl: Label 'BTwentyFour API Integration - %1', Comment = '%1=API Endpoint ID';
        ProcessImportListLbl: Label 'process_import_list', Locked = true;
        ServiceEndPointsNotFoundLbl: Label '%1 not found for %2: %3 or endpoints exist but they are not enabled. Try to navigate to service endpoints through the setup by running an action "Show Setup Page"', Comment = '%1=ServiceEndPoint.TableCaption();%2=ServiceSetup.TableCaption();%3=ServiceSetup.Code';
        ImportTypeParameterLbl: Label 'import_type', locked = true;
        BearerTokenLbl: Label 'bearer %1', locked = true;
        ClassIdTok: Label 'classid=%1', Locked = true;

    procedure VerifyServiceURL(var ServiceURL: Text[250])
    var
        HttpWebRequestMgt: Codeunit "Http Web Request Mgt.";
    begin
        if ServiceURL = '' then
            exit;
        HttpWebRequestMgt.CheckUrl(ServiceURL);
        RemoveLastSlashFromPath(ServiceURL, 8);
    end;

    procedure RemoveLastSlashFromPath(var Path: Text[250]; StartLength: Integer)
    begin
        if Path = '' then
            exit;

        while (StrLen(Path) > StartLength) and (Path[StrLen(Path)] = '/') do
            Path := CopyStr(Path, 1, StrLen(Path) - 1);
    end;

    procedure ImportContentOnline(ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob"): Boolean
    var
        ServiceSetup: Record "NPR BTF Service Setup";
        FileMgt: Codeunit "File Management";
        Request: Codeunit "Temp Blob";
        EndPoint: Interface "NPR BTF IEndPoint";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        StatusCode: Integer;
    begin
        ServiceEndPoint.TestField(Enabled);
        EndPoint := ServiceEndPoint."EndPoint Method";
        ServiceSetup.get(ServiceEndPoint."Service Code");
        ServiceSetup.TestField(Enabled);
        if ServiceSetup.Environment = ServiceSetup.Environment::production then
            if not Confirm(SendReqToLiveEnvQst, false) then
                exit;
        EndPoint.SendRequest(ServiceSetup, ServiceEndPoint, Request, Response, StatusCode);
        FormatResponse := ServiceEndPoint.Accept;
        FileMgt.BLOBExport(Response, strsubstno(SampleLbl, FormatResponse.GetFileExtension()), true);
        exit(Response.HasValue());
    end;

    procedure ProcessContent(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        EndPoint: Interface "NPR BTF IEndPoint";
    begin
        ServiceEndPoint.TestField(Enabled);
        ServiceEndPoint.TestField("Next EndPoint ID");
        EndPoint := ServiceEndPoint."EndPoint Method";
        EndPoint.ProcessImportedContent(Content, ServiceEndPoint);
    end;

    procedure ProcessContentOffline(Content: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        EndPoint: Interface "NPR BTF IEndPoint";
    begin
        if not Content.HasValue() then
            Error(EmptyContentErr);
        ServiceEndPoint.TestField(Enabled);
        EndPoint := ServiceEndPoint."EndPoint Method";
        EndPoint.ProcessImportedContentOffline(Content, ServiceEndPoint);
    end;

    procedure ImportContentOffline(ServiceEndPoint: Record "NPR BTF Service EndPoint"; var Response: Codeunit "Temp Blob")
    var
        FileMgt: Codeunit "File Management";
        FormatResponse: Interface "NPR BTF IFormatResponse";
    begin
        ServiceEndPoint.TestField(Enabled);
        ServiceEndPoint.TestField("Next EndPoint ID");
        FormatResponse := ServiceEndPoint.Accept;
        FileMgt.BLOBImport(Response, strsubstno(SampleLbl, FormatResponse.GetFileExtension()));
    end;

    procedure SendWebRequest(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint"; Request: Codeunit "Temp Blob"; var Response: Codeunit "Temp Blob"; var StatusCode: Integer)
    var
        EndPoint: Interface "NPR BTF IEndPoint";
    begin
        EndPoint := ServiceEndPoint."EndPoint Method";
        EndPoint.SendRequest(ServiceSetup, ServiceEndPoint, Request, Response, StatusCode);
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
        BasicLbl: Label 'Basic %1', locked = true;
        Pct2Lbl: Label '%1:%2', locked = true;
    begin
        Base64Auth := StrSubstNo(Pct2Lbl, Setup.Username, Setup.Password);
        exit(StrSubstNo(BasicLbl, Base64Convert.ToBase64(Base64Auth)));
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

    procedure ShowErrorLogEntries(ServiceCode: Code[20]; EndPointID: Text)
    var
        ErrorLog: Record "NPR BTF EndPoint Error Log";
    begin
        ErrorLog.SetFilter("Service Code", ServiceCode);
        ErrorLog.SetFilter("EndPoint ID", EndPointID);
        Page.Run(0, ErrorLog);
    end;

    procedure ShowEndPoints(ServiceCode: Code[20])
    var
        ServiceEndPoint: Record "NPR BTF Service Endpoint";
    begin
        ServiceEndPoint.SetFilter("Service Code", ServiceCode);
        Page.Run(0, ServiceEndPoint);
    end;

    procedure ShowEndPoint(EndPointID: Text)
    var
        ServiceEndPoint: Record "NPR BTF Service Endpoint";
    begin
        ServiceEndPoint.SetRange("EndPoint ID", EndPointID);
        ServiceEndPoint.SetRange(Enabled, true);
        Page.Run(Page::"NPR BTF Service Endpoint", ServiceEndPoint);
    end;

    procedure DownloadErrorLogResponse(ErrorLog: Record "NPR BTF EndPoint Error Log")
    var
        ResponseBlob: Codeunit "Temp Blob";
        FileMgt: Codeunit "File Management";
        OutStr: OutStream;
    begin
        if not ErrorLog.Response.HasValue() then begin
            Message(ResponseContentNotFoundMsg, Format(ErrorLog."Initiatied From Rec. ID"));
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

    procedure GetIntegrationPrefix(): Text
    begin
        exit('B24');
    end;

    procedure DeleteJobQueueCategory(JobQueueCategoryCode: Text)
    var
        JobQueueCategory: Record "Job Queue Category";
    begin
        JobQueueCategory.Setrange(Code, JobQueueCategoryCode);
        if not JobQueueCategory.IsEmpty() then
            JobQueueCategory.DeleteAll(true);
    end;

    procedure InsertImportEntry(var ImportEntry: Record "NPR Nc Import Entry"; ImportTypeCode: Code[20]; Response: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        EndPoint: Interface "NPR BTF IEndPoint";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        clear(ImportEntry);
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := ImportTypeCode;
        if Response.HasValue() then begin
            EndPoint := ServiceEndPoint."EndPoint Method";
            FormatResponse := ServiceEndPoint.Accept;
            ImportEntry."Document Name" := EndPoint.GetDefaultFileName(ServiceEndPoint) + '.' + FormatResponse.GetFileExtension();
            ImportEntry."Document ID" := Format(ServiceEndPoint.RecordId());
            DataTypeManagement.GetRecordRef(ImportEntry, RecRef);
            Response.ToRecordRef(RecRef, ImportEntry.FieldNo("Document Source"));
            RecRef.SetTable(ImportEntry);
        end;
        ImportEntry.Insert(true);
    end;

    procedure RegisterNcImportType(ImportTypeCode: Code[20]; ImportTypeDesc: Text; ImportListUpdateHandler: Enum "NPR Nc IL Update Handler")
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        if ImportTypeCode = '' then
            exit;
        ImportType.Code := ImportTypeCode;
        if ImportType.Find() then
            exit;
        ImportType.Init();
        ImportType.Description := Copystr(ImportTypeDesc, 1, MaxStrLen(ImportType.Description));
        ImportType."Import List Update Handler" := ImportListUpdateHandler;
        ImportType."Import Codeunit ID" := Codeunit::"NPR BTF Nc Import Entry";
        ImportType.Insert(true);
    end;

    procedure ScheduleJobQueueEntry(ServiceEndPoint: Record "NPR BTF Service EndPoint")
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        PlaceHolder5Lbl: Label '%1=%2,%3=%4,%5', locked = true;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Nc Import List Processing");
        JobQueueEntry.SetRange("Record ID to Process", ServiceEndPoint.RecordId());
        if JobQueueEntry.FindFirst() then
            exit;

        CreateJobQueueCategory(JobQueueCategory, ServiceEndPoint);
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            CODEUNIT::"NPR Nc Import List Processing",
            StrSubstNo(PlaceHolder5Lbl, ImportTypeParameterLbl, ServiceEndPoint."EndPoint ID", ServiceEndPoint.TableName(), ServiceEndPoint.RecordId(), ProcessImportListLbl),
            CopyStr(Strsubstno(APIIntegrationLbl, ServiceEndPoint."EndPoint ID"), 1, MaxStrLen(JobQueueEntry.Description)),
            CurrentDateTime(),
            070000T,
            230000T,
            10,
            JobQueueCategory.Code,
            ServiceEndPoint.RecordId(),
            JobQueueEntry)
        then begin
            if not ServiceEndPoint.Enabled then
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold")
            else
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
        end;
    end;

    local procedure CreateJobQueueCategory(var JobQueueCategory: Record "Job Queue Category"; ServiceEndPoint: Record "NPR BTF Service EndPoint")
    begin
        JobQueueCategory.Code := CopyStr(ServiceEndpoint."Service Code", 1, maxstrlen(JobQueueCategory.Code));
        if JobQueueCategory.Find() then
            exit;
        JobQueueCategory.Init();
        JobQueueCategory.Description := CopyStr(JobQueueCategory.Code, 1, MaxStrLen(JobQueueCategory.Description));
        JobQueueCategory.Insert();
    end;

    procedure DeleteNcImportType(ImportTypeCode: Code[20])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        ImportType.SetRange(Code, ImportTypeCode);
        if not ImportType.IsEmpty() then
            ImportType.DeleteAll();
    end;

    procedure CancelJob(ServiceEndpoint: Record "NPR BTF Service Endpoint")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Nc Import List Processing");
        if Format(ServiceEndPoint.RecordId()) <> '' then
            JobQueueEntry.SetFilter("Record ID to Process", Format(ServiceEndPoint.RecordId()));
        if not JobQueueEntry.FindFirst() then
            exit;
        JobQueueEntry.Cancel();
    end;

    procedure ShowJobQueueEntries(RecId: RecordId)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Setrange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Nc Import List Processing");
        JobQueueEntry.SetRange("Record ID to Process", RecId);
        Page.Run(0, JobQueueEntry);
    end;

    procedure ShowJobQueueEntries()
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Setrange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Nc Import List Processing");
        Page.Run(0, JobQueueEntry);
    end;

    procedure SendWebRequests(ImportType: Record "NPR Nc Import Type"; InitiateFromRecID: RecordId; EndPointIDFilter: Text)
    var
        ServiceSetup: Record "NPR BTF Service Setup";
        ImportEntry: Record "NPR Nc Import Entry";
        ServiceEndPoint: Record "NPR BTF Service EndPoint";
        Response: Codeunit "Temp Blob";
        DummyRequest: Codeunit "Temp Blob";
        DataTypeMgt: Codeunit "Data Type Management";
        FormatResponse: Interface "NPR BTF IFormatResponse";
        RecIdToProcess: RecordId;
        RecRef: RecordRef;
        StatusCode: Integer;
    begin
        if evaluate(RecIdToProcess, EndPointIDFilter) then;

        if not DataTypeMgt.GetRecordRef(RecIdToProcess, RecRef) then begin
            LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', StrSubstNo(ServiceEndPointsNotFoundLbl, ServiceEndPoint.TableCaption(), ServiceSetup.TableCaption(), ServiceSetup.Code), InitiateFromRecID);
            exit;
        end;

        RecRef.SetTable(ServiceEndPoint);
        if (not ServiceEndPoint.Find()) or (not ServiceEndPoint.Enabled) then begin
            LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', StrSubstNo(ServiceEndPointsNotFoundLbl, ServiceEndPoint.TableCaption(), ServiceSetup.TableCaption(), ServiceSetup.Code), InitiateFromRecID);
            exit;
        end;

        SendWebRequest(ServiceSetup, ServiceEndPoint, DummyRequest, Response, StatusCode);
        FormatResponse := ServiceEndPoint.Accept;
        if FormatResponse.FoundErrorInResponse(Response, StatusCode) then begin
            LogEndPointError(ServiceSetup, ServiceEndPoint, Response, '', FormatResponse.GetErrorDescription(Response), InitiateFromRecID);
        end else begin
            InsertImportEntry(ImportEntry, ImportType.Code, Response, ServiceEndPoint);
        end;
    end;

    procedure GetJobQueueParameters(JobQueueEntry: Record "Job Queue Entry"; ImportType: Record "NPR Nc Import Type"; var EndPointIDFilter: Text)
    var
        ServiceEndPoint: Record "NPR BTF Service EndPoint";
        ImportListProcessing: Codeunit "NPR Nc Import List Processing";
    begin
        if not ImportListProcessing.HasParameter(JobQueueEntry, ImportTypeParameterLbl) then
            exit;
        if ImportType.Code <> ImportListProcessing.GetParameterValue(JobQueueEntry, ImportTypeParameterLbl) then
            exit;
        if ImportListProcessing.HasParameter(JobQueueEntry, ServiceEndPoint.TableName()) then
            EndPointIDFilter := ImportListProcessing.GetParameterValue(JobQueueEntry, ServiceEndPoint.TableName());

        if EndPointIDFilter = '' then
            EndPointIDFilter := Format(JobQueueEntry."Record ID to Process");
    end;

    procedure GetBearerTokenLbl(): Text
    begin
        exit(BearerTokenLbl);
    end;

    procedure GetServiceUrlWithEndpoint(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint";
        UrlParameters: Text): Text
    begin
        exit(GetServiceUrlWithEndpoint(ServiceSetup, ServiceEndPoint, -1, UrlParameters));
    end;

    procedure GetServiceUrlWithEndpoint(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint";
        ClassId: Integer): Text
    begin
        exit(GetServiceUrlWithEndpoint(ServiceSetup, ServiceEndPoint, ClassId, ''));
    end;

    procedure GetServiceUrlWithEndpoint(ServiceSetup: Record "NPR BTF Service Setup"; ServiceEndPoint: Record "NPR BTF Service EndPoint";
        ClassId: Integer; UrlParameters: Text) ServiceUrl: Text
    var
        UrlQuery: Text;
        QueryDelimiter: Text;
    begin
        QueryDelimiter := '';
        ServiceUrl := ServiceSetup."Service URL" + ServiceEndPoint.Path;

        if (ClassId >= 0) then begin
            UrlQuery := StrSubstNo(ClassIdTok, ClassId);
            QueryDelimiter := '&';
        end;

        If (UrlParameters <> '') then begin
            UrlQuery := UrlQuery + QueryDelimiter + UrlParameters;
        end;

        if (UrlQuery <> '') then begin
            ServiceUrl := ServiceUrl + '?' + UrlQuery;
        end;

        exit(ServiceUrl);
    end;
}