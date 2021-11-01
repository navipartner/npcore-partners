codeunit 6014589 "NPR Replication API" implements "NPR Nc Import List IUpdate"
{

    Access = Public;

    var
        APIIntegrationLbl: Label 'Replication API Integration - %1', Comment = '%1=API Version';
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
        JQImportType: Record "NPR Nc Import Type";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        NcImportListProcessing: Codeunit "NPR Nc Import List Processing";
        EndPointIDFilter: Text;
    begin
        JQParamStrMgt.Parse(JobQueueEntry."Parameter String");
        if not JQParamStrMgt.ContainsParam(NcImportListProcessing.ParamImportType()) then
            exit;
        if not NcImportListProcessing.FilterImportType(JQParamStrMgt.GetParamValueAsText(NcImportListProcessing.ParamImportType()), JQImportType) then
            exit;
        JQImportType.Code := ImportType.Code;
        if not JQImportType.Find() then
            exit;
        EndPointIDFilter := JQParamStrMgt.GetParamValueAsText(DummyServiceEndPoint.TableName());

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
        if EndPointID <> '' then
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
        if ServiceEndPoint.FindSet() then
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
            if not IsHandledSendWebRequest then
                SendWebRequest(ServiceSetup, ServiceEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI);

            if FoundErrorInResponse(Response, StatusCode) then begin
                ErrLog.InsertLog(ServiceEndPoint."Service Code", ServiceEndPoint."EndPoint ID", Method, URI, Response);
                Exit;
            end else begin
                if not SkipImportEntryCreationForNoDataResponse(ServiceEndPoint, Response) then begin
                    InsertImportEntry(ImportEntry, ImportType.Code, BatchId, Response, ServiceEndPoint);
                    Commit();
                end;
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

    local procedure SkipImportEntryCreationForNoDataResponse(ServiceEndPoint: Record "NPR Replication Endpoint"; Response: Codeunit "Temp Blob"): Boolean
    var
        EndPoint: Interface "NPR Replication IEndpoint Meth";
    begin
        if not ServiceEndPoint."Skip Import Entry No Data Resp" then
            exit(false);

        EndPoint := ServiceEndPoint."Endpoint Method";
        Exit(NOT EndPoint.CheckResponseContainsData(Response));
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
        ImportType."Keep Import Entries for" := 7 * 24 * 60 * 60 * 1000; // 7 days
        ImportType.Insert(true);
    end;

    procedure ScheduleJobQueueEntry(ServiceSetup: Record "NPR Replication Service Setup")
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        JQParamStrMgt: Codeunit "NPR Job Queue Param. Str. Mgt.";
        NcImportListProcessing: Codeunit "NPR Nc Import List Processing";
        ParamNameAndValueLbl: Label '%1=%2', locked = true;
    begin
        JobQueueEntry.SetRange("Object Type to Run", JobQueueEntry."Object Type to Run"::Codeunit);
        JobQueueEntry.SetRange("Object ID to Run", Codeunit::"NPR Nc Import List Processing");
        JobQueueEntry.SetRange("Record ID to Process", ServiceSetup.RecordId());
        if JobQueueEntry.FindFirst() then
            exit;

        clear(JobQueueEntry);
        if ServiceSetup.JobQueueStartTime > 0T then
            JobQueueEntry."Starting Time" := ServiceSetup.JobQueueStartTime
        else
            JobQueueEntry."Starting Time" := 070000T;
        if ServiceSetup.JobQueueEndTime > 0T then
            JobQueueEntry."Ending Time" := ServiceSetup.JobQueueEndTime
        else
            JobQueueEntry."Ending Time" := 230000T;
        if ServiceSetup.JobQueueMinutesBetweenRun > 0 then
            JobQueueEntry."No. of Minutes between Runs" := ServiceSetup.JobQueueMinutesBetweenRun
        else
            JobQueueEntry."No. of Minutes between Runs" := 10;

        Clear(JQParamStrMgt);
        JQParamStrMgt.AddToParamDict(StrSubstNo(ParamNameAndValueLbl, NcImportListProcessing.ParamImportType(), ServiceSetup."API Version"));
        if ServiceSetup.JobQueueProcessImportList then
            JQParamStrMgt.AddToParamDict(NcImportListProcessing.ParamProcessImport());

        CreateJobQueueCategory(JobQueueCategory);
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Nc Import List Processing",
            JQParamStrMgt.GetParamListAsCSString(),
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
        if not JobQueueEntry.IsEmpty then
            JobQueueEntry.DeleteAll(true);
    end;

    procedure DeleteJobQueueCategory()
    var
        JobQueueCategory: Record "Job Queue Category";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        JobQueueEntry.SetRange("Job Queue Category Code", ReplicationJobQueueCategoryCode);
        if not JobQueueEntry.IsEmpty then
            exit;

        if JobQueueCategory.Get(ReplicationJobQueueCategoryCode) then
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

    procedure VerifyServiceURL(ServiceURL: Text) NewServiceURL: Text;
    var
        WebRequestHelper: codeunit "Web Request Helper";
    begin
        if ServiceURL = '' then
            exit;
        WebRequestHelper.IsValidUri(ServiceURL);
        NewServiceURL := ServiceURL.TrimEnd('/');
    end;

    procedure UpdateReplicationCounter(JTokenEntity: JsonToken; ReplicationEndPoint: Record "NPR Replication Endpoint")
    var
        RepCounter: BigInteger;
    begin
        if not JTokenEntity.IsObject() then
            exit;

        if SelectJsonToken(JTokenEntity.AsObject(), '$.replicationCounter') = '' then
            Error(ReplicationCounterCannotBeEmptyErr);

        if Evaluate(RepCounter, SelectJsonToken(JTokenEntity.AsObject(), '$.replicationCounter')) then begin
            if RepCounter > ReplicationEndPoint."Replication Counter" then
                UpdateSQLTimestampEndpoint(ReplicationEndPoint, RepCounter);
            System.ClearLastError();
        end else
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
        if not JObject.SelectToken(Path, JToken) then
            Error(MissingFieldInJsonErr, Path);

        if JToken.AsValue().IsNull() then
            exit('');

        exit(JToken.AsValue().AsText());
    end;

    procedure SelectJsonToken(JObject: JsonObject; Path: text; var TokenValue: text): Boolean
    var
        JToken: JsonToken;
    begin
        // selects value from JsonObject
        if not JObject.SelectToken(Path, JToken) then
            Exit(false);

        if JToken.IsObject() OR Jtoken.IsArray() then
            exit(true); //is found, but we cannot read the text value

        if JToken.AsValue().IsNull() then
            Exit(true);

        TokenValue := JToken.AsValue().AsText();
        Exit(true);
    end;

    procedure SelectJsonToken(JObject: JsonObject; Path: text; SkipMissingFieldError: Boolean): Text
    var
        JToken: JsonToken;
    begin
        // selects value from JsonObject
        if not JObject.SelectToken(Path, JToken) then begin
            if SkipMissingFieldError then
                Exit('')
            else
                Error(MissingFieldInJsonErr, Path);
        end;

        if JToken.AsValue().IsNull() then
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

        if StatusCode in [400 .. 499] then
            exit(true); // client errors

        if StatusCode in [500 .. 599] then
            exit(true); // server errors

        Response.CreateInStream(InStr);
        InStr.ReadText(Json);
        if not JObject.ReadFrom(Json) then
            exit(true);

        foreach key1 in JObject.Keys do begin
            if (LowerCase(key1) = 'error') or (LowerCase(key1) = 'exceptionmessage') then
                exit(true);
        end;
    end;

    local procedure GetODataMaxPageSize(ReplicationEndpoint: Record "NPR Replication Endpoint"): integer
    begin
        if ReplicationEndPoint."odata.maxpagesize" > 0 then
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
        if NextLinkURI = '' then begin
            URI := ReplicationSetup."Service URL" + ReplicationEndPoint.Path;
            RepCounter := ReplicationEndPoint."Replication Counter";
            //%1 = company ID, %2 = sqlTimestamp
            URI := StrSubstNo(URI, ReplicationSetup.GetCompanyId(), Format(RepCounter));
            if not URI.Contains('$orderby=replicationCounter') then
                URI += '&$orderby=replicationCounter';
            ReplicationSetup.AddTenantToURL(URI);
        end else begin
            URI := NextLinkURI;
            NextLinkURI := '';
        end;
    end;

    procedure GetBCAPIResponse(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; URI: Text; var NextLinkURI: Text)
    begin
        // method to get main api response
        GetBCAPIResponse(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, Method, URI, NextLinkURI, false);
    end;

    procedure GetBCAPIResponseImage(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; URI: Text)
    var
        DummyMethod: Code[10];
        DummyNextLinkURL: Text;
    begin
        // method to get api response for image url
        GetBCAPIResponse(ReplicationSetup, ReplicationEndPoint, Client, Response, StatusCode, DummyMethod, URI, DummyNextLinkURL, true);
    end;

    procedure GetBCAPIResponse(ReplicationSetup: Record "NPR Replication Service Setup"; ReplicationEndPoint: Record "NPR Replication Endpoint"; var Client: HttpClient; var Response: Codeunit "Temp Blob"; var StatusCode: Integer; var Method: code[10]; URI: Text; var NextLinkURI: Text; ImportImageRequest: Boolean)
    var
        [NonDebuggable]
        Headers: HttpHeaders;
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
        OutStr: OutStream;
        ResponseStream: InStream;
        iAuth: Interface "NPR API IAuthorization";
        ErrorTxt: Text;
        JTokenMainObject: JsonToken;
        AuthParamsBuff: Record "NPR Auth. Param. Buffer";
        WebServiceAuthHelper: Codeunit "NPR Web Service Auth. Helper";
    begin
        iAuth := ReplicationSetup.AuthType;
        Method := 'GET';

        RequestMessage.Method := Method;

        RequestMessage.SetRequestUri(URI);
        RequestMessage.GetHeaders(Headers);

        case ReplicationSetup.AuthType of
            ReplicationSetup.AuthType::Basic:
                WebServiceAuthHelper.GetBasicAuthorizationParamsBuff(ReplicationSetup.UserName, ReplicationSetup."API Password Key", AuthParamsBuff);
            ReplicationSetup.AuthType::OAuth2:
                WebServiceAuthHelper.GetOpenAuthorizationParamsBuff(ReplicationSetup."OAuth2 Setup Code", AuthParamsBuff);
        end;

        iAuth.SetAuthorizationValue(Headers, AuthParamsBuff);
        if not ImportImageRequest then
            Headers.Add('Prefer', 'odata.maxpagesize=' + Format(GetODataMaxPageSize(ReplicationEndPoint)));

        if not IsSuccessfulRequest(Client.Send(RequestMessage, ResponseMessage), ResponseMessage, ErrorTxt, StatusCode) then begin
            CreateInternalErrorResponse('internal_bc_error', ErrorTxt, Response);
            exit;
        end;

        ResponseMessage.Content.ReadAs(ResponseStream);
        Clear(Response);
        Response.CreateOutStream(OutStr);
        CopyStream(OutStr, ResponseStream);
        if JTokenMainObject.ReadFrom(ResponseStream) then
            NextLinkURI := SelectJsonToken(JTokenMainObject.AsObject(), '$.[''@odata.nextLink'']', true); // get NextLink if there is a next page                                                                                                
    end;

    procedure GetImageHash(var TempBlob: Codeunit "Temp Blob"): Text
    var
        Base64Convert: Codeunit "Base64 Convert";
        Crypto: Codeunit "Cryptography Management";
        IStr: InStream;
    begin
        if not TempBlob.HasValue() then
            exit('');

        TempBlob.CreateInStream(IStr);
        Exit(Crypto.GenerateHash(Base64Convert.ToBase64(IStr), 2));
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
        GenericDateFormula: DateFormula;
        GenericDateFormula2: DateFormula;
    begin
        FRef := RecRef.Field(FieldNo);

        case lowercase(Format(FRef.Type)) OF
            'code', 'text':
                begin
                    if Format(FRef.Value) <> SourceTxt then begin
                        FRef.Value(SourceTxt);
                        ValueChanged := true;
                    end;
                end;
            'boolean':
                begin
                    GenericBool := FRef.Value;
                    if evaluate(GenericBool2, SourceTxt) then
                        if GenericBool <> GenericBool2 then begin
                            FRef.Value(GenericBool2);
                            ValueChanged := true;
                        end;
                end;
            'date':
                begin
                    GenericDate := FRef.Value;
                    if evaluate(GenericDate2, SourceTxt, 9) then
                        If GenericDate <> GenericDate2 then begin
                            FRef.Value(GenericDate2);
                            ValueChanged := true;
                        end;
                end;
            'datetime':
                begin
                    GenericDT := FRef.Value;
                    if evaluate(GenericDT2, SourceTxt, 9) then
                        If GenericDT <> GenericDT2 then begin
                            FRef.Value(GenericDT2);
                            ValueChanged := true;
                        end;
                end;
            'time':
                begin
                    GenericTime := FRef.Value;
                    if evaluate(GenericTime2, SourceTxt, 9) then
                        If GenericTime <> GenericTime2 then begin
                            FRef.Value(GenericTime2);
                            ValueChanged := true;
                        end;
                end;
            'dateformula':
                begin
                    GenericDateFormula := FRef.Value;
                    if evaluate(GenericDateFormula2, SourceTxt, 9) then
                        If GenericDateFormula <> GenericDateFormula2 then begin
                            FRef.Value(GenericDateFormula2);
                            ValueChanged := true;
                        end;
                end;
            'decimal':
                begin
                    GenericDec := FRef.Value;
                    if evaluate(GenericDec2, SourceTxt) then
                        If GenericDec <> GenericDec2 then begin
                            FRef.Value(GenericDec2);
                            ValueChanged := true;
                        end;
                end;
            'integer':
                begin
                    GenericInt := FRef.Value;
                    if evaluate(GenericInt2, SourceTxt) then
                        If GenericInt <> GenericInt2 then begin
                            FRef.Value(GenericInt2);
                            ValueChanged := true;
                        end;
                end;
            'enum', 'option':
                begin
                    if format(FRef) <> lowercase(SourceTxt) then
                        if Evaluate(FRef, SourceTxt) then
                            ValueChanged := true;
                end;
        end; // end case

        if ValueChanged then
            if WithValidation then
                FRef.Validate();

    end;

    procedure GetJTokenMainObjectFromContent(Content: Codeunit "Temp Blob"; var JToken: JsonToken): Boolean
    var
        InStr: InStream;
        JsonTxt: Text;
    begin
        Content.CreateInStream(InStr);
        Instr.ReadText(JsonTxt);
        if not JToken.ReadFrom(JsonTxt) then
            Exit(false);

        exit(true);
    end;

    procedure GetJsonArrayFromJsonToken(var JToken: JsonToken; JPath: Text; var JArray: JsonArray): Boolean
    var
        JTokenResult: JsonToken;
    begin
        if not JToken.SelectToken(JPath, JTokenResult) then
            exit(false);

        JArray := JTokenResult.AsArray();

        exit(true);
    end;

    procedure CheckEntityReplicationCounter(JToken: JsonToken; ReplicationEndPoint: Record "NPR Replication Endpoint"): Boolean
    var
        ReplicationCounterOfEntity: BigInteger;
    begin
        if Evaluate(ReplicationCounterOfEntity, SelectJsonToken(JToken.AsObject(), '$.replicationCounter')) then;
        Exit(NOT (ReplicationCounterOfEntity < ReplicationEndPoint."Replication Counter")); // means that we try to manually process an older version of the record which would overwrite latest changes.
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeSendWebRequest(var Response: Codeunit "Temp Blob"; var NextLinkURI: Text; var IsHandled: Boolean)
    begin
    end;
}
