codeunit 6014589 "NPR Replication API" implements "NPR Nc Import List IUpdate"
{

    Access = Public;

    var
        APIIntegrationLbl: Label 'Replication API Integration - %1', Comment = '%1=API Version';
        ProcessImportListLbl: Label 'process_import_list', Locked = true;
        ImportTypeParameterLbl: Label 'import_type', locked = true;
        ImportTypeDescriptionLbl: Label 'Replication integration. Run all enabled services';

        ReplicationSetupErr: Label 'Replication Setup is missing or it is disabled';

        ServiceEndPointErr: Label 'There are no Endpoints enabled for this Replication Setup';

        WebAPIErrorTxtG: Label 'Something went wrong:\\Error Status Code: %1;\\Description: %2';

        ReplicationJobQueueCategoryCode: Label 'REP', locked = true;

        ReplicationCounterEvaluateErr: Label 'Cannot evaluate Replication Counter value %1 into a BigInteger.';
        ReplicationCounterCannotBeEmptyErr: Label 'Replication Counter cannot be empty.';

        MissingFieldInJsonErr: Label 'Field %1 is missing. Please contact support.';

    procedure Update(TaskLine: Record "NPR Task Line"; ImportType: Record "NPR Nc Import Type")
    begin
        SendWebRequests(ImportType, '');
    end;

    procedure Update(JobQueueEntry: Record "Job Queue Entry"; ImportType: Record "NPR Nc Import Type")
    var
        DummyServiceEndPoint: Record "NPR Replication Endpoint";
        ImportListProcessing: Codeunit "NPR Nc Import List Processing";
        EndPointIDFilter: Text;
    begin
        if not ImportListProcessing.HasParameter(JobQueueEntry, ImportTypeParameterLbl) then
            exit;
        if ImportType.Code <> ImportListProcessing.GetParameterValue(JobQueueEntry, ImportTypeParameterLbl) then
            exit;
        if ImportListProcessing.HasParameter(JobQueueEntry, DummyServiceEndPoint.TableName()) then
            EndPointIDFilter := ImportListProcessing.GetParameterValue(JobQueueEntry, DummyServiceEndPoint.TableName());

        SendWebRequests(ImportType, EndPointIDFilter);
    end;

    procedure ShowSetup(ImportType: Record "NPR Nc Import Type")
    var
        ServiceSetup: Record "NPR Replication Service Setup";
    begin
        ServiceSetup.Setrange("API Version", ImportType.Code);
        Page.Run(0, ServiceSetup);
    end;

    procedure ShowErrorLog(ImportType: Record "NPR Nc Import Type")
    begin
        ShowErrorLogEntries(ImportType.Code, '');
    end;

    procedure ShowErrorLogEntries(ServiceCode: Code[20]; EndPointID: Text)
    var
        ErrorLog: Record "NPR Replication Error Log";
    begin
        ErrorLog.SetFilter("API Version", ServiceCode);
        IF EndPointID <> '' THEN
            ErrorLog.SetFilter("EndPoint ID", EndPointID);
        Page.Run(0, ErrorLog);
    end;

    local procedure SendWebRequests(ImportType: Record "NPR Nc Import Type"; EndPointIDFilter: Text)
    var
        ServiceSetup: Record "NPR Replication Service Setup";
        ErrLog: Record "NPR Replication Error Log";
        ServiceEndPoint: Record "NPR Replication Endpoint";
        Client: HttpClient; // reuse HttpClient for all requests for better performance and to avoid potential errors
    begin
        ServiceSetup."API Version" := ImportType.Code;
        if (not ServiceSetup.Find()) or (not ServiceSetup.Enabled) then begin
            ErrLog.InsertLog(ServiceSetup."API Version", ServiceSetup."Service URL", ReplicationSetupErr);
            exit;
        end;

        ServiceEndPoint.Setcurrentkey("Service Code", Enabled, "Sequence Order");
        ServiceEndPoint.SetRange("Service Code", ServiceSetup."API Version");
        ServiceEndPoint.SetRange(Enabled, true);
        if EndPointIDFilter <> '' then
            ServiceEndPoint.SetFilter("EndPoint ID", EndPointIDFilter);
        if ServiceEndPoint.IsEmpty() then begin
            ErrLog.InsertLog(ServiceSetup."API Version", ServiceSetup."Service URL", ServiceEndPointErr);
            exit;
        end;
        IF ServiceEndPoint.FindSet() then
            repeat
                CreateImportEntry(ServiceSetup, ServiceEndPoint, Client, ImportType, '');
            until ServiceEndPoint.Next() = 0;
    end;

    local procedure CreateImportEntry(ServiceSetup: Record "NPR Replication Service Setup"; ServiceEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; ImportType: Record "NPR Nc Import Type"; NextLinkURI: Text)
    var
        ImportEntry: Record "NPR Nc Import Entry";
        ErrLog: Record "NPR Replication Error Log";
        Response: Codeunit "Temp Blob";
        StatusCode: integer;
        Method: Code[10];
        URI: Text;
        BatchId: GUID;
        IsHandledSendWebRequest: Boolean;
    begin
        BatchId := CreateGuid();
        repeat
            OnBeforeSendWebRequest(Response, NextLinkURI, IsHandledSendWebRequest);
            IF not IsHandledSendWebRequest then
                SendWebRequest(ServiceSetup, ServiceEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);

            if FoundErrorInResponse(Response, StatusCode) then begin
                ErrLog.InsertLog(ServiceEndPoint."Service Code", ServiceEndPoint."EndPoint ID", Method, URI, Response);
                Exit;
            end else begin
                InsertImportEntry(ImportEntry, ImportType.Code, BatchId, Response, ServiceEndPoint);
                Commit();
            end;
        until NextLinkURI = ''; // for handling pagination
    end;

    procedure SendWebRequest(ServiceSetup: Record "NPR Replication Service Setup"; ServiceEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: integer; var Method: Code[10]; var URI: text; var NextLinkURI: Text)
    var
        EndPoint: Interface "NPR Replication IEndpoint Meth";
    begin
        EndPoint := ServiceEndPoint."EndPoint Method";
        EndPoint.SendRequest(ServiceSetup, ServiceEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
    end;

    local procedure InsertImportEntry(var ImportEntry: Record "NPR Nc Import Entry"; ImportTypeCode: Code[20]; BatchId: GUID; Response: Codeunit "Temp Blob"; ServiceEndPoint: Record "NPR Replication Endpoint")
    var
        EndPoint: Interface "NPR Replication IEndpoint Meth";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
    begin
        clear(ImportEntry);
        ImportEntry."Entry No." := 0;
        ImportEntry."Import Type" := ImportTypeCode;
        ImportEntry."Batch Id" := BatchId;
        if Response.HasValue() then begin
            EndPoint := ServiceEndPoint."Endpoint Method";

            ImportEntry."Document Name" := EndPoint.GetDefaultFileName(ServiceEndPoint) + '.' + 'json';
            ImportEntry."Document ID" := Format(ServiceEndPoint.RecordId());
            DataTypeManagement.GetRecordRef(ImportEntry, RecRef);
            Response.ToRecordRef(RecRef, ImportEntry.FieldNo("Document Source"));
            RecRef.SetTable(ImportEntry);
        end;
        ImportEntry.Insert(true);
    end;

    procedure RegisterNcImportType(ImportTypeCode: Code[20])
    var
        ImportType: Record "NPR Nc Import Type";
    begin
        if ImportTypeCode = '' then
            exit;
        ImportType.Code := ImportTypeCode;
        if ImportType.Find() then
            exit;
        ImportType.Init();
        ImportType.Description := Copystr(ImportTypeDescriptionLbl, 1, MaxStrLen(ImportType.Description));
        ImportType."Import List Update Handler" := ImportType."Import List Update Handler"::ReplicationAPI;
        ImportType."Import Codeunit ID" := Codeunit::"NPR Replication Import Entry";
        ImportType.Insert(true);
    end;

    procedure ScheduleJobQueueEntry(ServiceSetup: Record "NPR Replication Service Setup")
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        ParamWithProcessImportList: Label '%1=%2,%3';
        ParamWithoutProcessImportList: Label '%1=%2';
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Nc Import List Processing");
        JobQueueEntry.SetRange("Record ID to Process", ServiceSetup.RecordId());
        if JobQueueEntry.FindFirst() then
            exit;

        clear(JobQueueEntry);
        IF ServiceSetup.JobQueueStartTime > 0T then
            JobQueueEntry."Starting Time" := ServiceSetup.JobQueueStartTime
        else
            JobQueueEntry."Starting Time" := 070000T;
        IF ServiceSetup.JobQueueEndTime > 0T then
            JobQueueEntry."Ending Time" := ServiceSetup.JobQueueEndTime
        else
            JobQueueEntry."Ending Time" := 230000T;
        IF ServiceSetup.JobQueueMinutesBetweenRun > 0 THEN
            JobQueueEntry."No. of Minutes between Runs" := ServiceSetup.JobQueueMinutesBetweenRun
        else
            JobQueueEntry."No. of Minutes between Runs" := 10;
        IF ServiceSetup.JobQueueProcessImportList THEN
            JobQueueEntry."Parameter String" := StrSubstNo(ParamWithProcessImportList, ImportTypeParameterLbl, ServiceSetup."API Version", ProcessImportListLbl)
        else
            JobQueueEntry."Parameter String" := StrSubstNo(ParamWithoutProcessImportList, ImportTypeParameterLbl, ServiceSetup."API Version");

        CreateJobQueueCategory(JobQueueCategory);
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Nc Import List Processing",
            JobQueueEntry."Parameter String",
            CopyStr(Strsubstno(APIIntegrationLbl, ServiceSetup."API Version"), 1, MaxStrLen(JobQueueEntry.Description)),
            CurrentDateTime(),
            JobQueueEntry."Starting Time",
            JobQueueEntry."Ending Time",
            JobQueueEntry."No. of Minutes between Runs",
            JobQueueCategory.Code,
            ServiceSetup.RecordId(),
            JobQueueEntry)
        then begin
            if not ServiceSetup.Enabled then
                JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold")
            else
                JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
        end;
    end;

    local procedure CreateJobQueueCategory(var JobQueueCategory: Record "Job Queue Category")
    begin
        JobQueueCategory.Code := ReplicationJobQueueCategoryCode;
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

    procedure DeleteJobQueueEntries(ServiceSetup: Record "NPR Replication Service Setup")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Nc Import List Processing");
        JobQueueEntry.SetRange("Record ID to Process", ServiceSetup.RecordId());
        IF NOT JobQueueEntry.IsEmpty then
            JobQueueEntry.DeleteAll(true);
    end;

    procedure DeleteJobQueueCategory()
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Job Queue Category Code", ReplicationJobQueueCategoryCode);
        IF NOT JobQueueEntry.IsEmpty then
            exit;

        IF JobQueueCategory.Get(ReplicationJobQueueCategoryCode) then
            JobQueueCategory.Delete(true);
    end;

    procedure ShowJobQueueEntries(ServiceSetup: Record "NPR Replication Service Setup")
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.Setrange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", CODEUNIT::"NPR Nc Import List Processing");
        JobQueueEntry.SetRange("Job Queue Category Code", ReplicationJobQueueCategoryCode);
        JobQueueEntry.SetFilter("Parameter String", '%1', '@*' + ServiceSetup."API Version" + '*');
        Page.Run(0, JobQueueEntry);
    end;

    procedure VerifyServiceURL(var ServiceURL: Text)
    var
        WebRequestHelper: codeunit "Web Request Helper";
    begin
        if ServiceURL = '' then
            exit;
        WebRequestHelper.IsValidUri(ServiceURL);
        ServiceURL := ServiceURL.TrimEnd('/');
    end;

    procedure UpdateReplicationCounter(JTokenEntity: JsonToken; ReplicationEndPoint: Record "NPR Replication Endpoint")
    var
        RepCounter: BigInteger;
    begin
        IF Not JTokenEntity.IsObject() then
            exit;

        IF SelectJsonToken(JTokenEntity.AsObject(), '$.replicationCounter') = '' then
            Error(ReplicationCounterCannotBeEmptyErr);

        IF Evaluate(RepCounter, SelectJsonToken(JTokenEntity.AsObject(), '$.replicationCounter')) THEN BEGIN
            IF RepCounter > ReplicationEndPoint."Replication Counter" then
                UpdateSQLTimestampEndpoint(ReplicationEndPoint, RepCounter);
            System.ClearLastError();
        END Else
            Error(ReplicationCounterEvaluateErr, SelectJsonToken(JTokenEntity.AsObject(), '$.replicationCounter'));
    end;

    procedure UpdateSQLTimestampEndpoint(var Endpoint: Record "NPR Replication Endpoint"; pRepCounter: BigInteger)
    begin
        Endpoint."Replication Counter" := pRepCounter;
        Endpoint.Modify();
    end;

    procedure SelectJsonToken(JObject: JsonObject; Path: text): Text
    var
        JToken: JsonToken;
    begin
        // selects value from JsonObject
        IF not JObject.SelectToken(Path, JToken) then
            Error(MissingFieldInJsonErr, Path);

        IF JToken.AsValue().IsNull() then
            exit('');

        exit(JToken.AsValue().AsText());
    end;

    procedure SelectJsonToken(JObject: JsonObject; Path: text; SkipMissingFieldError: Boolean): Text
    var
        JToken: JsonToken;
    begin
        // selects value from JsonObject
        IF not JObject.SelectToken(Path, JToken) then begin
            IF SkipMissingFieldError Then
                Exit('')
            Else
                Error(MissingFieldInJsonErr, Path);
        end;

        IF JToken.AsValue().IsNull() then
            exit('');

        exit(JToken.AsValue().AsText());
    end;

    procedure IsSuccessfulRequest(TransportOK: Boolean; Response: HttpResponseMessage; var ErrorTxt: Text; var StatusCode: Integer): Boolean
    begin
        StatusCode := Response.HttpStatusCode();
        if TransportOK and Response.IsSuccessStatusCode() then
            exit(true);

        ErrorTxt := StrSubstNo(WebAPIErrorTxtG, Response.HttpStatusCode, Response.ReasonPhrase);
        exit(false);
    end;

    procedure CreateInternalErrorResponse(ErrorCode: Text; ErrorDescription: Text; var Result: Codeunit "Temp Blob")
    var
        JObject: JsonObject;
        Json: Text;
        OutStr: OutStream;
    begin
        JObject.Add('error', ErrorCode);
        JObject.Add('error_description', ErrorDescription);
        JObject.WriteTo(Json);
        Result.CreateOutStream(OutStr);
        OutStr.WriteText(Json);
    end;

    procedure FoundErrorInResponse(var Response: Codeunit "Temp Blob"; StatusCode: Integer): Boolean;
    var
        JObject: JsonObject;
        InStr: InStream;
        Json: Text;
        key1: text;
    begin
        if StatusCode = 200 then
            exit; // successful responses

        IF StatusCode in [400 .. 499] then
            exit(true); // client errors

        IF StatusCode in [500 .. 599] then
            exit(true); // server errors

        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit(true);

        foreach key1 in JObject.Keys do begin
            IF (LowerCase(key1) = 'error') or (LowerCase(key1) = 'exceptionmessage') then
                exit(true);
        end;
    end;

    local procedure GetODataMaxPageSize(ReplicationEndpoint: Record "NPR Replication Endpoint"): integer
    begin
        IF ReplicationEndPoint."odata.maxpagesize" > 0 then
            exit(ReplicationEndPoint."odata.maxpagesize");
        exit(10000); //default value. Server default is 20000, but for big responses it fails...
    end;

    procedure RunSpecificEndpointImportManually(Endpoint: Record "NPR Replication Endpoint"; NextLinkURI: Text)
    var
        Setup: Record "NPR Replication Service Setup";
        ErrLog: Record "NPR Replication Error Log";
        iEndpointMeth: Interface "NPR Replication IEndpoint Meth";
        Response: Codeunit "Temp Blob";
        StatusCode: integer;
        Method: Code[10];
        URI: Text;
        ImportErr: Label 'An error occured. Please check error log.';
        ImportMsg: Label 'Import done.';
        Client: HttpClient;
    begin
        Setup.get(Endpoint."Service Code");
        Setup.TestField(Enabled);
        Endpoint.TestField(Enabled);
        SendWebRequest(Setup, EndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);
        if FoundErrorInResponse(Response, StatusCode) then begin
            ErrLog.InsertLog(EndPoint."Service Code", EndPoint."EndPoint ID", Method, URI, Response);
            Commit();
            Error(ImportErr)
        end else begin
            iEndpointMeth.ProcessImportedContent(Response, Endpoint);
            Message(ImportMsg);
        end;

        If NextLinkURI <> '' then
            RunSpecificEndpointImportManually(Endpoint, NextLinkURI);
    end;

    procedure CreateURI(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var NextLinkURI: Text) URI: Text
    var
        RepCounter: BigInteger;
    begin
        IF NextLinkURI = '' then begin
            URI := ReplicationSetup."Service URL" + ReplicationEndPoint.Path;
            RepCounter := ReplicationEndPoint."Replication Counter";
            //%1 = company ID, %2 = sqlTimestamp
            URI := StrSubstNo(URI, ReplicationSetup.GetCompanyId(), Format(RepCounter));
            IF NOT URI.Contains('$orderby=replicationCounter') then
                URI += '&$orderby=replicationCounter';
            ReplicationSetup.AddTenantToURL(URI);
        end else begin
            URI := NextLinkURI;
            NextLinkURI := '';
        end;
    end;

    procedure GetBCAPIResponse(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; URI: Text; var NextLinkURI: Text)
    var
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        OutStr: OutStream;
        ResponseText: Text;
        iAuth: Interface "NPR Replication API IAuthorization";
        ErrorTxt: Text;
        JTokenMainObject: JsonToken;
    begin
        iAuth := ReplicationSetup.AuthType;
        Method := 'GET';

        RequestMessage.Method := Method;

        RequestMessage.SetRequestUri(URI);
        RequestMessage.GetHeaders(Headers);
        Headers.Add('Authorization', iAuth.GetAuthorizationValue(ReplicationSetup));
        Headers.Add('Prefer', 'odata.maxpagesize=' + Format(GetODataMaxPageSize(ReplicationEndPoint)));

        IF not IsSuccessfulRequest(Client.Send(RequestMessage, ResponseMessage), ResponseMessage, ErrorTxt, StatusCode) then begin
            CreateInternalErrorResponse('internal_bc_error', ErrorTxt, Response);
            exit;
        end;

        ResponseMessage.Content.ReadAs(ResponseText);
        IF JTokenMainObject.ReadFrom(ResponseText) then
            NextLinkURI := SelectJsonToken(JTokenMainObject.AsObject(), '$.[''@odata.nextLink'']', true); // get NextLink if there is a next page
        Clear(Response);
        Response.CreateOutStream(OutStr);
        OutStr.WriteText(ResponseText);
    end;

    procedure CheckFieldValue(RecRef: RecordRef; FieldNo: integer; SourceTxt: Text; WithValidation: Boolean) ValueChanged: Boolean
    var
        FRef: FieldRef;
        GenericBool: Boolean;
        GenericBool2: Boolean;
        GenericDec: Decimal;
        GenericDec2: Decimal;
        GenericInt: Decimal;
        GenericInt2: Decimal;
        GenericDate: Date;
        GenericDate2: Date;
        GenericDT: DateTime;
        GenericDT2: DateTime;
        GenericTime: Time;
        GenericTime2: Time;
    begin
        FRef := RecRef.Field(FieldNo);

        case lowercase(Format(FRef.Type)) OF
            'code', 'text':
                begin
                    IF Format(FRef.Value) <> SourceTxt then begin
                        FRef.Value(SourceTxt);
                        ValueChanged := true;
                    end;
                end;
            'boolean':
                begin
                    GenericBool := FRef.Value;
                    IF evaluate(GenericBool2, SourceTxt) then
                        IF GenericBool <> GenericBool2 then begin
                            FRef.Value(GenericBool2);
                            ValueChanged := true;
                        end;
                end;
            'date':
                begin
                    GenericDate := FRef.Value;
                    IF evaluate(GenericDate2, SourceTxt, 9) then
                        If GenericDate <> GenericDate2 then begin
                            FRef.Value(GenericDate2);
                            ValueChanged := true;
                        end;
                end;
            'datetime':
                begin
                    GenericDT := FRef.Value;
                    IF evaluate(GenericDT2, SourceTxt, 9) then
                        If GenericDT <> GenericDT2 then begin
                            FRef.Value(GenericDT2);
                            ValueChanged := true;
                        end;
                end;
            'time':
                begin
                    GenericTime := FRef.Value;
                    IF evaluate(GenericTime2, SourceTxt, 9) then
                        If GenericTime <> GenericTime2 then begin
                            FRef.Value(GenericTime2);
                            ValueChanged := true;
                        end;
                end;
            'decimal':
                begin
                    GenericDec := FRef.Value;
                    IF evaluate(GenericDec2, SourceTxt) then
                        If GenericDec <> GenericDec2 then begin
                            FRef.Value(GenericDec2);
                            ValueChanged := true;
                        end;
                end;
            'integer':
                begin
                    GenericInt := FRef.Value;
                    IF evaluate(GenericInt2, SourceTxt) then
                        If GenericInt <> GenericInt2 then begin
                            FRef.Value(GenericInt2);
                            ValueChanged := true;
                        end;
                end;
            'enum', 'option':
                begin
                    IF format(FRef) <> lowercase(SourceTxt) then
                        IF Evaluate(FRef, SourceTxt) then
                            ValueChanged := true;
                end;
        end; // end case

        IF ValueChanged then
            IF WithValidation then
                FRef.Validate();

    end;

    procedure GetJTokenMainObjectFromContent(Content: Codeunit "Temp Blob"; var JToken: JsonToken): Boolean
    var
        InStr: InStream;
        JsonTxt: Text;
    begin
        Content.CreateInStream(InStr);
        Instr.ReadText(JsonTxt);
        IF Not JToken.ReadFrom(JsonTxt) then
            Exit(false);

        exit(true);
    end;

    procedure GetJsonArrayFromJsonToken(var JToken: JsonToken; JPath: Text; var JArray: JsonArray): Boolean
    var
        JTokenResult: JsonToken;
    begin
        IF not JToken.SelectToken(JPath, JTokenResult) then
            exit(false);

        JArray := JTokenResult.AsArray();

        exit(true);
    end;

    procedure CheckEntityReplicationCounter(JToken: JsonToken; ReplicationEndPoint: Record "NPR Replication Endpoint"): Boolean
    var
        ReplicationCounterOfEntity: BigInteger;
    begin
        IF Evaluate(ReplicationCounterOfEntity, SelectJsonToken(JToken.AsObject(), '$.replicationCounter')) then;
        Exit(NOT (ReplicationCounterOfEntity < ReplicationEndPoint."Replication Counter")); // means that we try to manually process an older version of the record which would overwrite latest changes.
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendWebRequest(var Response: Codeunit "Temp Blob"; var NextLinkURI: Text; var IsHandled: Boolean)
    begin
    end;
}
