codeunit 6184796 "NPR Adyen Management"
{
    Access = Internal;

    internal procedure UpdateMerchantList(PageNumber: Integer) Updated: Boolean
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        MerchantAccount: Record "NPR Adyen Merchant Account";
        GetMerchantsEndpoint: Label '/companies/%1/merchants', Locked = true;
        RequestURL: Text;
        ResponseText: Text;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        PagesTotal: Integer;
        MerchantsArray: JsonArray;
        MerchantObject: JsonObject;
        i: Integer;
    begin
        InitiateAdyenManagement();

        HttpClient.DefaultRequestHeaders().Add('x-api-key', _AdyenSetup."Management API Key");
        RequestURL := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(GetMerchantsEndpoint, _AdyenSetup."Company ID") + '?pageSize=100';
        if PageNumber > 0 then
            RequestURL += '&pageNumber=' + Format(PageNumber);

        HttpClient.Get(RequestURL, HttpResponseMessage);
        if (HttpResponseMessage.IsSuccessStatusCode()) then begin
            HttpResponseMessage.Content().ReadAs(ResponseText);
            JsonToken.ReadFrom(ResponseText);
            JsonObject := JsonToken.AsObject();
            JsonObject.Get('pagesTotal', JsonToken);
            PagesTotal := JsonToken.AsValue().AsInteger();
            JsonObject.Get('data', JsonToken);
            MerchantsArray := JsonToken.AsArray();
            if MerchantsArray.Count() > 0 then begin
                for i := 0 to MerchantsArray.Count() - 1 do begin
                    MerchantsArray.Get(i, JsonToken);
                    MerchantObject := JsonToken.AsObject();
                    if MerchantObject.Get('id', JsonToken) then begin
                        MerchantAccount.Init();
                        MerchantAccount."Company ID" := _AdyenSetup."Company ID";
                        MerchantAccount.Name := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(MerchantAccount.Name));
                        MerchantAccount.Insert();
                        Updated := true;
                    end;
                end;
                if (PagesTotal > 1) and (PageNumber = 0) then
                    for i := 2 to PagesTotal do begin
                        UpdateMerchantList(i);
                    end;
            end;
        end;
    end;

    internal procedure CreateWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup"): Boolean
    var
        CreateWebhookEndpoint: Label '/companies/%1/webhooks', Locked = true;
        RequestText: Text;
        ResponseText: Text;
        RequestUrl: Text;
        JsonToken: JsonToken;
        ResponseObject: JsonObject;
    begin
        InitiateAdyenManagement();

        WebhookSetup.TestField("Web Service URL");
        if WebhookSetup."Web Service Security" = WebhookSetup."Web Service Security"::"Basic authentication" then begin
            WebhookSetup.TestField("Web Service User");
            WebhookSetup.TestField("Web Service Password");
        end;

        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(CreateWebhookEndpoint, _AdyenSetup."Company ID");

        RequestText := CreateWebhookHttpRequestObject(WebhookSetup);
        ResponseText := CreateWebhookHttpRequest(RequestText, RequestUrl, Enum::"Http Request Type"::POST);
        JsonToken.ReadFrom(ResponseText);
        ResponseObject := JsonToken.AsObject();
        if ResponseObject.Get('id', JsonToken) then begin
            WebhookSetup.ID := CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(WebhookSetup.ID));
            WebhookSetup.Modify(false);
            if (WebhookSetup."Web Service URL" <> '') and (WebhookSetup."Web Service URL".Contains('https://adyenreconciliation.azurewebsites.net/api')) then
                SuggestAFWebServiceURL(WebhookSetup);
            exit(true);
        end;
    end;

    internal procedure RefreshWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup"): Boolean
    var
        GetWebhookEndpoint: Label '/companies/%1/webhooks/%2', Locked = true;
        WebhookDoesNotExist: Label 'Webhook with ID %1 does not exist anymore.';
        RequestUrl: Text;
        ResponseText: Text;
        JsonToken: JsonToken;
        ResponseObject: JsonObject;
    begin
        InitiateAdyenManagement();

        WebhookSetup.TestField(ID);
        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(GetWebhookEndpoint, _AdyenSetup."Company ID", WebhookSetup.ID);

        ResponseText := CreateWebhookHttpRequest('', RequestUrl, Enum::"Http Request Type"::GET);
        JsonToken.ReadFrom(ResponseText);
        ResponseObject := JsonToken.AsObject();
        if ResponseObject.Get('id', JsonToken) then begin
            if (JsonToken.AsValue().AsText() = WebhookSetup.ID) then
                exit(CompareWebhookConfigurations(WebhookSetup, ResponseObject));
        end else
            Error(WebhookDoesNotExist, WebhookSetup.ID);
    end;

    internal procedure CompareWebhookConfigurations(var WebhookSetup: Record "NPR Adyen Webhook Setup"; WebhookObject: JsonObject) Updated: Boolean
    var
        JsonToken: JsonToken;
        MerchantToken: JsonToken;
        MerchantFilterUpdated: Boolean;
    begin
        if WebhookObject.Get('url', JsonToken) then
            if JsonToken.AsValue().AsText() <> WebhookSetup."Web Service URL" then begin
                WebhookSetup."Web Service URL" := CopyStr(JsonToken.AsValue().AsText(), 1, 2048);
                WebhookSetup.Modify(false);
                Updated := true;
            end;
        if WebhookObject.Get('description', JsonToken) then
            if JsonToken.AsValue().AsText() <> WebhookSetup.Description then begin
                WebhookSetup.Description := CopyStr(JsonToken.AsValue().AsText(), 1, 150);
                WebhookSetup.Modify(false);
                Updated := true;
            end;
        if WebhookObject.Get('filterMerchantAccountType', JsonToken) then
            if JsonToken.AsValue().AsText() <> WebhookSetup."Merchant Accounts Filter Type".Names().Get(WebhookSetup."Merchant Accounts Filter Type".Ordinals().IndexOf(WebhookSetup."Merchant Accounts Filter Type".AsInteger())) then begin
                WebhookSetup."Merchant Accounts Filter Type" := Enum::"NPR Adyen Merchant Filter Type".FromInteger(WebhookSetup."Merchant Accounts Filter Type".Ordinals().Get(WebhookSetup."Merchant Accounts Filter Type".Names().IndexOf(JsonToken.AsValue().AsText())));
                WebhookSetup.Modify(false);
                Updated := true;
            end;
        if WebhookObject.Get('filterMerchantAccounts', JsonToken) then
            if JsonToken.IsArray() then begin
                MerchantFilterUpdated := false;
                foreach MerchantToken in JsonToken.AsArray() do begin
                    if not WebhookSetup."Merchant Accounts Filter".Contains(MerchantToken.AsValue().AsText()) then begin
                        if not MerchantFilterUpdated then
                            WebhookSetup."Merchant Accounts Filter" := '';
                        WebhookSetup."Merchant Accounts Filter" += CopyStr(MerchantToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup."Merchant Accounts Filter")) + '|';
                        MerchantFilterUpdated := true;
                    end;
                end;
                if (MerchantFilterUpdated and WebhookSetup."Merchant Accounts Filter".Contains('|')) then begin
                    WebhookSetup."Merchant Accounts Filter" := DelChr(WebhookSetup."Merchant Accounts Filter", '>', '|');
                    WebhookSetup.Modify(false);
                    Updated := true;
                end;
            end;
        if WebhookObject.Get('active', JsonToken) then
            if JsonToken.AsValue().AsBoolean() <> WebhookSetup.Active then begin
                WebhookSetup.Active := JsonToken.AsValue().AsBoolean();
                WebhookSetup.Modify(false);
                Updated := true;
            end;
        if WebhookObject.Get('username', JsonToken) then
            if JsonToken.AsValue().AsText() <> WebhookSetup."Web Service User" then begin
                if WebhookSetup."Web Service User" = '' then
                    WebhookSetup."Web Service Security" := WebhookSetup."Web Service Security"::"Basic authentication";
                WebhookSetup."Web Service User" := CopyStr(JsonToken.AsValue().AsText(), 1, 256);
                WebhookSetup.Modify(false);
                Updated := true;
            end;
    end;

    internal procedure CreateDocumentFromWebhookRequest(var WebhookRequest: Record "NPR AF Rec. Webhook Request")
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        ReportOutStream: OutStream;
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        RequestIsEmptyError01: Label 'Webhook Request No. %1 has no Report Download URL. Try another one.';
        DocumentExistConfirmation: Label 'Such document already exists. Open?';
        MultipleDocumentExist: Label 'Such documents already exist. Open?';
        UndefinedReportSchemeError: Label 'Report Scheme is undefined.';
        SchemeNotImplemented: Label 'Current Report Scheme is not yet implemented. Contact your Administrator.';
        HttpErrorLabel: Label '%1 - %2';
        TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
#IF NOT BC17
        NewDocumentsList: List of [Code[20]];
#ELSE
        NewDocumentsList: JsonArray;
        JsonToken: JsonToken;
#ENDIF
        NewDocumentsFilter: Text;
        i: Integer;
    begin
        if (WebhookRequest."Report Download URL" = '') then
            Error(RequestIsEmptyError01, WebhookRequest.ID)
        else begin
            ReconciliationHeader.Reset();
            ReconciliationHeader.SetRange("Webhook Request ID", WebhookRequest.ID);
            if ReconciliationHeader.FindSet(false) then begin
                if ReconciliationHeader.Count() > 1 then begin
                    if Confirm(MultipleDocumentExist) then
                        Page.Run(Page::"NPR Adyen Reconciliation List", ReconciliationHeader);
                end else begin
                    if Confirm(DocumentExistConfirmation) then
                        Page.Run(Page::"NPR Adyen Reconciliation", ReconciliationHeader);
                end;
            end else begin
                Clear(WebhookRequest."Report Data");
                _AdyenSetup.Get();
                HttpClient.DefaultRequestHeaders.Add('x-api-key', _AdyenSetup."Download Report API Key");
                HttpClient.Get(WebhookRequest."Report Download URL", HttpResponseMessage);
                if (HttpResponseMessage.IsSuccessStatusCode()) then begin
                    HttpResponseMessage.Content().ReadAs(ResponseText);
                    WebhookRequest."Report Data".CreateOutStream(ReportOutStream, TextEncoding::UTF8);
                    ReportOutStream.WriteText(ResponseText);
                    WebhookRequest.Validate("Report Data");
                    WebhookRequest.Modify();
                end else
                    Error(HttpErrorLabel, Format(HttpResponseMessage.HttpStatusCode()), HttpResponseMessage.ReasonPhrase());
                if TransactionMatching.ValidateReportScheme(WebhookRequest) then begin
                    case WebhookRequest."Report Type" of
                        WebhookRequest."Report Type"::"Settlement details":
                            begin
                                NewDocumentsList := TransactionMatching.CreateSettlementDocuments(WebhookRequest, false, '');
                                if NewDocumentsList.Count() > 0 then begin
                                    for i := 1 to NewDocumentsList.Count() do begin
#IF NOT BC17
                                        NewDocumentsFilter += NewDocumentsList.Get(i) + '|';
#ELSE
                                    NewDocumentsList.Get(i, JsonToken);
                                    NewDocumentsFilter += JsonToken.AsValue().AsCode() + '|';
#ENDIF
                                    end;
                                    ReconciliationHeader.SetFilter("Document No.", DelChr(NewDocumentsFilter, '>', '|'));
                                    if ReconciliationHeader.FindSet(false) then begin
                                        if NewDocumentsList.Count() > 1 then
                                            Page.Run(Page::"NPR Adyen Reconciliation List", ReconciliationHeader)
                                        else
                                            Page.Run(Page::"NPR Adyen Reconciliation", ReconciliationHeader);
                                    end;

                                end else begin
                                    OpenLogs(WebhookRequest);
                                end;
                            end;
                        WebhookRequest."Report Type"::"External Settlement detail (C)":
                            begin
                                Error(SchemeNotImplemented);
                            end;
                        WebhookRequest."Report Type"::Undefined:
                            Error(UndefinedReportSchemeError);
                    end;
                end else begin
                    OpenLogs(WebhookRequest);
                end;
            end;
        end;
    end;

    internal procedure CreateDocumentFromFile(): Boolean
    var
        FileName: Text;
        InStr: InStream;
        OutStr: OutStream;
        WebhookRequest: Record "NPR AF Rec. Webhook Request";
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        UndefinedReportSchemeError: Label 'Report Scheme is undefined.';
        FileNotUploaded: Label 'The file was not uploaded.';
        TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
#IF NOT BC17
        NewDocumentsList: List of [Code[20]];
#ELSE
        NewDocumentsList: JsonArray;
        JsonToken: JsonToken;
#ENDIF
        NewDocumentsFilter: Text;
        i: Integer;
    begin
        Clear(WebhookRequest);
        WebhookRequest.Init();
        WebhookRequest.ID := 0;
        WebhookRequest."Creation Date" := CurrentDateTime();
        WebhookRequest."Report Download URL" := 'Local File Upload';

        if UploadIntoStream('Import Report', '', 'Microsoft Excel Comma Separated Values File (*.CSV)|*.CSV', FileName, InStr) then begin
            WebhookRequest.Validate("PSP Reference", FileName);
            WebhookRequest.Validate("Report Name", FileName);
            WebhookRequest."Report Data".CreateOutStream(OutStr);
            if (not CopyStream(OutStr, InStr)) then Error(FileNotUploaded);
            WebhookRequest.Insert();
        end else
            Error(FileNotUploaded);

        if TransactionMatching.ValidateReportScheme(WebhookRequest) then begin
            case WebhookRequest."Report Type" of
                WebhookRequest."Report Type"::"Settlement details",
                WebhookRequest."Report Type"::"External Settlement detail (C)":
                    begin
                        NewDocumentsList := TransactionMatching.CreateSettlementDocuments(WebhookRequest, false, '');
                        if NewDocumentsList.Count() > 0 then begin
                            for i := 1 to NewDocumentsList.Count() do begin
#IF NOT BC17
                                NewDocumentsFilter += NewDocumentsList.Get(i) + '|';
#ELSE
                            NewDocumentsList.Get(i, JsonToken);
                            NewDocumentsFilter += JsonToken.AsValue().AsCode() + '|';
#ENDIF
                            end;
                            ReconciliationHeader.SetFilter("Document No.", DelChr(NewDocumentsFilter, '>', '|'));
                            if ReconciliationHeader.FindSet(false) then begin
                                if NewDocumentsList.Count() > 1 then
                                    Page.Run(Page::"NPR Adyen Reconciliation List", ReconciliationHeader)
                                else
                                    Page.Run(Page::"NPR Adyen Reconciliation", ReconciliationHeader);
                            end;

                        end else begin
                            OpenLogs(WebhookRequest);
                        end;
                    end;
                WebhookRequest."Report Type"::Undefined:
                    Error(UndefinedReportSchemeError);
            end;
        end else begin
            OpenLogs(WebhookRequest);
        end;
    end;

    internal procedure OpenLogs(WebhookRequest: Record "NPR AF Rec. Webhook Request")
    var
        Logs: Record "NPR Adyen Reconciliation Log";
    begin
        Logs.Reset();
        Logs.SetRange("Webhook Request ID", WebhookRequest.ID);
        Logs.SetFilter("Creation Date", '>=%1', CreateDateTime(Today(), 0T));
        if not Logs.IsEmpty() then
            Page.Run(Page::"NPR Adyen Reconciliation Logs", Logs);
    end;

    internal procedure ModifyWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup") Success: Boolean
    var
        RequestUrl: Text;
        ChangeWebhookEndpoint: Label '/companies/%1/webhooks/%2', Locked = true;
        NoResponseLbl: Label 'Internal Server Error: No Valid Response.';
        RequestObject: JsonObject;
        AdditionalSettingsObject: JsonObject;
        ResponseText: Text;
        ResponseObject: JsonObject;
        JsonToken: JsonToken;
        RequestText: Text;
        MerchantAccount: Record "NPR Adyen Merchant Account";
        EventCode: Record "NPR Adyen Webhook Event Code";
        MerchantsArray: JsonArray;
        EventCodesArray: JsonArray;
    begin
        InitiateAdyenManagement();

        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(ChangeWebhookEndpoint, _AdyenSetup."Company ID", WebhookSetup.ID);

        RequestObject.Add('active', WebhookSetup.Active);
        RequestObject.Add('url', WebhookSetup."Web Service URL");
        if WebhookSetup.Description <> '' then
            RequestObject.Add('description', WebhookSetup.Description);
        RequestObject.Add('username', WebhookSetup."Web Service User");
        RequestObject.Add('password', WebhookSetup."Web Service Password");
        RequestObject.Add('filterMerchantAccountType', Format(WebhookSetup."Merchant Accounts Filter Type"));
        if WebhookSetup."Merchant Accounts Filter Type" <> WebhookSetup."Merchant Accounts Filter Type"::allAccounts then begin
            MerchantAccount.Reset();
            if WebhookSetup."Merchant Accounts Filter" <> '' then
                MerchantAccount.SetFilter(Name, WebhookSetup."Merchant Accounts Filter");
            if MerchantAccount.FindSet(false) then begin
                repeat
                    MerchantsArray.Add(MerchantAccount.Name);
                until MerchantAccount.Next() = 0;
            end;
            RequestObject.Add('filterMerchantAccounts', MerchantsArray);
        end;
        if (WebhookSetup.Type = WebhookSetup.Type::standard) and (WebhookSetup."Include Events Filter" <> '') then begin
            EventCode.Reset();
            EventCode.SetFilter("Event Code", WebhookSetup."Include Events Filter");
            if EventCode.FindSet(false) then begin
                repeat
                    EventCodesArray.Add(EventCode."Event Code");
                until EventCode.Next() = 0;
                AdditionalSettingsObject.Add('includeEventCodes', EventCodesArray);
                RequestObject.Add('additionalSettings', AdditionalSettingsObject);
            end;
        end;

        RequestObject.WriteTo(RequestText);
        ResponseText := CreateWebhookHttpRequest(RequestText, RequestUrl, Enum::"Http Request Type"::PATCH);

        JsonToken.ReadFrom(ResponseText);
        ResponseObject := JsonToken.AsObject();
        if ResponseObject.Get('id', JsonToken) then
            Success := true
        else begin
            if ResponseObject.Get('title', JsonToken) then begin
                if ResponseObject.Get('invalidFields', JsonToken) then begin
                    JsonToken.AsArray().Get(0, JsonToken);
                    if JsonToken.AsObject().Get('message', JsonToken) then
                        Error(JsonToken.AsValue().AsText())
                    else begin
                        ResponseObject.Get('title', JsonToken);
                        Error(JsonToken.AsValue().AsText());
                    end;
                end else
                    Error(JsonToken.AsValue().AsText())
            end else
                Error(NoResponseLbl);
        end;
    end;

    internal procedure DeleteWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup")
    var
        RequestUrl: Text;
        DeleteWebhookEndpoint: Label '/companies/%1/webhooks/%2', Locked = true;
        SuccessDeleteLbl: Label 'Successfully deleted Webhook %1 from Adyen.';
        AlreadyDeletedLbl: Label 'Webhook with ID %1 had already been deleted.';
    begin
        InitiateAdyenManagement();
        WebhookSetup.TestField(ID);

        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(DeleteWebhookEndpoint, _AdyenSetup."Company ID", WebhookSetup.ID);
        if CreateWebhookHttpRequest('', RequestUrl, Enum::"Http Request Type"::DELETE) = '' then
            Message(SuccessDeleteLbl, WebhookSetup.ID)
        else
            Message(AlreadyDeletedLbl, WebhookSetup.ID);
    end;

    internal procedure ImportWebhooks(pageNumber: Integer) Updated: Boolean
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        WebhookType: Enum "NPR Adyen Webhook Type";
        MerchantFilterType: Enum "NPR Adyen Merchant Filter Type";
        GetAllWebhooksEndpoint: Label '/companies/%1/webhooks', Locked = true;
        HttpErrorLabel: Label '%1 - %2';
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
        HttpHeaders: HttpHeaders;
        RequestUrl: Text;
        ResponseText: Text;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        PagesTotal: Integer;
        WebhooksArray: JsonArray;
        WebhookObject: JsonObject;
        MerchantArray: JsonArray;
        MerchantToken: JsonToken;
        EventCodeArray: JsonArray;
        EventCodeToken: JsonToken;
        i: Integer;
    begin
        InitiateAdyenManagement();

        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(GetAllWebhooksEndpoint, _AdyenSetup."Company ID") + '?pageSize=100';
        if pageNumber > 0 then
            RequestURL += '&pageNumber=' + Format(pageNumber);

        Clear(HttpRequestMessage);
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('x-api-key', _AdyenSetup."Management API Key");
        HttpRequestMessage.SetRequestUri(RequestUrl);
        HttpRequestMessage.Method := 'GET';
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(ResponseText);
        if HttpResponseMessage.IsSuccessStatusCode() then begin
            JsonToken.ReadFrom(ResponseText);
            JsonObject := JsonToken.AsObject();
            JsonObject.Get('pagesTotal', JsonToken);
            pagesTotal := JsonToken.AsValue().AsInteger();
            if not JsonObject.Get('data', JsonToken) then
                exit(false);
            WebhooksArray := JsonToken.AsArray();
            if WebhooksArray.Count() > 0 then begin
                for i := 0 to WebhooksArray.Count() - 1 do begin
                    WebhooksArray.Get(i, JsonToken);
                    WebhookObject := JsonToken.AsObject();
                    if WebhookObject.Get('id', JsonToken) then begin
                        WebhookSetup.Reset();
                        WebhookSetup.SetRange(ID, JsonToken.AsValue().AsCode());
                        if WebhookSetup.IsEmpty() then begin
                            WebhookSetup.Init();
                            WebhookSetup."Primary Key" := 0;
                            WebhookSetup.ID := CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(WebhookSetup.ID));
                            WebhookObject.Get('type', JsonToken);
                            WebhookSetup.Type := Enum::"NPR Adyen Webhook Type".FromInteger(WebhookType.Ordinals().Get(WebhookType.Names().IndexOf(JsonToken.AsValue().AsText())));
                            WebhookObject.Get('url', JsonToken);
                            WebhookSetup."Web Service URL" := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup."Web Service URL"));
                            WebhookObject.Get('description', JsonToken);
                            WebhookSetup.Description := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup.Description));
                            WebhookObject.Get('username', JsonToken);
                            if JsonToken.AsValue().AsText() <> '' then begin
                                WebhookSetup."Web Service Security" := WebhookSetup."Web Service Security"::"Basic authentication";
                                WebhookSetup."Web Service User" := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup."Web Service User"));
                            end;
                            WebhookObject.Get('active', JsonToken);
                            WebhookSetup.Active := JsonToken.AsValue().AsBoolean();
                            WebhookObject.Get('filterMerchantAccountType', JsonToken);
                            WebhookSetup."Merchant Accounts Filter Type" := Enum::"NPR Adyen Merchant Filter Type".FromInteger(MerchantFilterType.Ordinals().Get(MerchantFilterType.Names().IndexOf(JsonToken.AsValue().AsText())));
                            if WebhookObject.Get('filterMerchantAccounts', JsonToken) then begin
                                MerchantArray := JsonToken.AsArray();
                                foreach MerchantToken in MerchantArray do
                                    WebhookSetup."Merchant Accounts Filter" += CopyStr(MerchantToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup."Merchant Accounts Filter")) + '|';
                                if WebhookSetup."Merchant Accounts Filter".Contains('|') then
                                    WebhookSetup."Merchant Accounts Filter" := DelChr(WebhookSetup."Merchant Accounts Filter", '>', '|');
                            end;
                            if WebhookSetup.Type = WebhookSetup.Type::standard then begin
                                if WebhookObject.Get('additionalSettings', JsonToken) then begin
                                    if JsonToken.AsObject().Get('includeEventCodes', JsonToken) then begin
                                        if JsonToken.IsArray() then begin
                                            EventCodeArray := JsonToken.AsArray();
                                            foreach EventCodeToken in EventCodeArray do
                                                WebhookSetup."Include Events Filter" += CopyStr(EventCodeToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup."Include Events Filter")) + '|';
                                            if WebhookSetup."Include Events Filter".Contains('|') then
                                                WebhookSetup."Include Events Filter" := DelChr(WebhookSetup."Include Events Filter", '>', '|');
                                        end;
                                    end;
                                end;
                            end;
                            WebhookSetup.Insert();
                            _ImportedWebhooks += 1;
                            Commit();
                            Updated := true;
                        end;
                    end;
                end;
                if (pagesTotal > 1) and (pageNumber = 0) then
                    for i := 2 to pagesTotal do begin
                        ImportWebhooks(i);
                    end;
            end;
        end else
            Error(HttpErrorLabel, Format(HttpResponseMessage.HttpStatusCode()), ResponseText);
    end;

    internal procedure GetImportedWebhooksAmount(): Integer
    begin
        exit(_ImportedWebhooks);
    end;

    internal procedure CreateLog(LogTypeLocal: Enum "NPR Adyen Rec. Log Type"; Success: Boolean; Description: Text; RequestID: Integer)
    var
        Log: Record "NPR Adyen Reconciliation Log";
    begin
        Log.Init();
        Log.ID := 0;
        Log."Webhook Request ID" := RequestID;
        Log.Type := LogTypeLocal;
        Log."Creation Date" := CurrentDateTime();
        Log.Success := Success;
        Log.Description := CopyStr(Description, 1, MaxStrLen(Log.Description));
        Log.Insert();
    end;

    internal procedure GetPspReference(data: Text): Text
    var
        JsonToken: JsonToken;
        JsonObject: JsonObject;
    begin
        if JsonObject.ReadFrom(data) then begin
            if JsonObject.Get('notificationItems', JsonToken) then begin
                JsonToken.AsArray().Get(0, JsonToken);
                JsonToken.AsObject().Get('NotificationRequestItem', JsonToken);
                if (JsonToken.AsObject().Get('pspReference', JsonToken)) then
                    exit(JsonToken.AsValue().AsText());
            end;
        end;
    end;

    internal procedure DefineReportType(PSPReference: Text) ReportType: Enum "NPR Adyen Report Type"
    begin
        if PSPReference.Contains('external_settlement_detail_report') then
            exit(ReportType::"External Settlement detail (C)");
        if PSPReference.Contains('settlement_detail_report') then
            exit(ReportType::"Settlement details");

        exit(ReportType::Undefined);
    end;

    internal procedure DefineReportScheme(ReportType: Enum "NPR Adyen Report Type"; var Scheme: array[50] of Text[35]; var SchemeColumnNumber: Integer)
    begin
        case ReportType of
            ReportType::"Settlement details":
                begin
                    Scheme[1] := 'Company Account';
                    Scheme[2] := 'Merchant Account';
                    Scheme[3] := 'Psp Reference';
                    Scheme[4] := 'Merchant Reference';
                    Scheme[5] := 'Payment Method';
                    Scheme[6] := 'Creation Date';
                    Scheme[7] := 'TimeZone';
                    Scheme[8] := 'Type';
                    Scheme[9] := 'Modification Reference';
                    Scheme[10] := 'Gross Currency';
                    Scheme[11] := 'Gross Debit (GC)';
                    Scheme[12] := 'Gross Credit (GC)';
                    Scheme[13] := 'Exchange Rate';
                    Scheme[14] := 'Net Currency';
                    Scheme[15] := 'Net Debit (NC)';
                    Scheme[16] := 'Net Credit (NC)';
                    Scheme[17] := 'Commission (NC)';
                    Scheme[18] := 'Markup (NC)';
                    Scheme[19] := 'Payment Method Variant';
                    Scheme[20] := 'Modification Merchant Reference';
                    Scheme[21] := 'Batch Number';
                    Scheme[22] := 'DCC Markup (NC)';
                    Scheme[23] := 'Surcharge Amount';
                    Scheme[24] := 'Merchant Order Reference';
                    Scheme[25] := 'Scheme Fees (NC)';
                    Scheme[26] := 'Interchange (NC)';
                    Scheme[27] := 'Payment Fees (NC)';
                    SchemeColumnNumber := 27;
                end;
            ReportType::"External Settlement detail (C)":
                begin
                    Scheme[1] := 'Company Account';
                    Scheme[2] := 'Merchant Account';
                    Scheme[3] := 'Psp Reference';
                    Scheme[4] := 'Merchant Reference';
                    Scheme[5] := 'Payment Method';
                    Scheme[6] := 'Creation Date';
                    Scheme[7] := 'TimeZone';
                    Scheme[8] := 'Type';
                    Scheme[9] := 'Modification Reference';
                    Scheme[10] := 'Gross Currency';
                    Scheme[11] := 'Gross Debit (GC)';
                    Scheme[12] := 'Gross Credit (GC)';
                    Scheme[13] := 'Exchange Rate';
                    Scheme[14] := 'Net Currency';
                    Scheme[15] := 'Net Debit (NC)';
                    Scheme[16] := 'Net Credit (NC)';
                    Scheme[17] := 'Commission (NC)';
                    Scheme[18] := 'Markup (NC)';
                    Scheme[19] := 'Payment Method Variant';
                    Scheme[20] := 'Modification Merchant Reference';
                    Scheme[21] := 'Merchant Order Reference';
                    Scheme[22] := 'Scheme Fees (NC)';
                    Scheme[23] := 'Interchange (NC)';
                    SchemeColumnNumber := 23;
                end;
        end;
    end;

    internal procedure ChangeColorLine(ReconciliationLine: Record "NPR Adyen Recon. Line"): Text[50]
    begin
        if ReconciliationLine.Status in [ReconciliationLine.Status::Posted, ReconciliationLine.Status::"Not to be Posted"] then
            exit('favorable')
        else
            exit('Unfavorable');
    end;

    internal procedure ChangeColorDocument(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Text[50]
    begin
        if ReconciliationHeader.Posted then
            exit('favorable')
        else
            exit('Unfavorable');
    end;

    internal procedure EmulateWebhookRequest(ReportName: Text[100])
    var
        RequestContent: Label '{"live":"false","notificationItems":[{"NotificationRequestItem":{"amount":{"currency":"EUR","value":0},"eventCode":"REPORT_AVAILABLE","eventDate":"2024-03-28T13:10:26+01:00","merchantAccountCode":"NavipartnerAfPPOS","merchantReference":"","pspReference":"%2","reason":"%1","success":"true"}}]}', Locked = true;
        ReportDownloadURL: Label 'https://ca-test.adyen.com/reports/download/MerchantAccount/NavipartnerAfPPOS/', Locked = true;
        ErrorText01: Label 'Could not download the report - %1 %2';
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        ReportOutStream: OutStream;
        RequestOutStream: OutStream;
        WebhookRequest: Record "NPR AF Rec. Webhook Request";
    begin
        _AdyenSetup.Get();
        HttpClient.DefaultRequestHeaders().Add('x-api-key', _AdyenSetup."Download Report API Key");
        HttpClient.Get(ReportDownloadURL + ReportName, HttpResponseMessage);
        if (HttpResponseMessage.IsSuccessStatusCode) then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);

            WebhookRequest.Init();
            WebhookRequest.ID := 0;
            WebhookRequest."Creation Date" := CurrentDateTime();
            WebhookRequest."Report Download URL" := ReportDownloadURL + ReportName;
            WebhookRequest."Report Name" := ReportName;
            WebhookRequest."Report Data".CreateOutStream(ReportOutStream, TextEncoding::UTF8);
            ReportOutStream.WriteText(ResponseText);
            WebhookRequest.Validate("Report Data");
            WebhookRequest."Request Data".CreateOutStream(RequestOutStream, TextEncoding::UTF8);
            RequestOutStream.WriteText(StrSubstNo(RequestContent, ReportDownloadURL + ReportName, ReportName));
            WebhookRequest.Insert();
            WebhookRequest.Validate("Request Data");
            WebhookRequest.Modify();
            exit;
        end;

        Error(ErrorText01, HttpResponseMessage.HttpStatusCode(), HttpResponseMessage.ReasonPhrase());
    end;

    internal procedure SetReconciledEFTMagentoUpgrade()
    var
        ConfirmLabel01: Label 'This action will set status ''Reconciled'' to ''True'' for all EFT Transaction Request and Magento Payment Line Entries that were created before ''Reconciliation Integration Starting Date'' (%1).\Are you sure to continue?';
        ConfirmLabel02: Label 'Warning.\\This will lock both EFT Transaction Requests and Magento Payment Lines.\Don''t close this window until the process is done.';
        UpdatingEFTLbl: Label 'Updating EFT Transaction Request entries...\\Updating #1 Entry out of #2.';
        UpdatingMagentoLbl: Label 'Updating Magento Payment Line entries...\\Updating #1 Entry out of #2.';
        EFTUpdateDoneLbl: Label 'Successfully updated %1 EFT Transaction Requests.';
        EFTUpdateNullLbl: Label 'No EFT Transaction Requests were updated.';
        MagentoUpdateDoneLbl: Label 'Successfully updated %1 Magento Payment Lines.';
        MagentoUpdateNullLbl: Label 'No Magento Payment Lines were updated.';
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        PaymentGateway: Record "NPR Magento Payment Gateway";
        AdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integrat.";
        AdyenLocalIntegration: Codeunit "NPR EFT Adyen Local Integrat.";
        EFTEntries: Integer;
        MagentoEntries: Integer;
        ProcessedEntries: Integer;
        Window: Dialog;
        FilterPGCodes: Text;
    begin
        if not _AdyenSetup.Get() then
            exit;
        if _AdyenSetup."Recon. Integr. Starting Date" = 0DT then
            exit;
        if not Confirm(ConfirmLabel01, false, Format(_AdyenSetup."Recon. Integr. Starting Date")) then
            exit;
        if not Confirm(ConfirmLabel02) then
            exit;

        Clear(ProcessedEntries);
        EFTTransactionRequest.SetFilter(Finished, '<%1', _AdyenSetup."Recon. Integr. Starting Date");
        EFTTransactionRequest.SetRange(Reconciled, false);
        EFTTransactionRequest.SetRange("Financial Impact", true);
        EFTTransactionRequest.SetFilter("Integration Type", '%1|%2', AdyenCloudIntegration.IntegrationType(), AdyenLocalIntegration.IntegrationType());
        if EFTTransactionRequest.FindSet(true) then begin
            EFTEntries := EFTTransactionRequest.Count();
            Window.Open(UpdatingEFTLbl);
            Window.Update(1, EFTEntries);
            repeat
                EFTTransactionRequest.Reconciled := true;
                EFTTransactionRequest."Reconciliation Date" := Today;
                EFTTransactionRequest.Modify();
                ProcessedEntries += 1;
                Window.Update(2, ProcessedEntries);
            until EFTTransactionRequest.Next() = 0;
            Window.Close();
        end;

        if ProcessedEntries > 0 then
            Message(EFTUpdateDoneLbl, ProcessedEntries)
        else
            Message(EFTUpdateNullLbl);

        Clear(ProcessedEntries);
        MagentoPaymentLine.SetFilter("Date Captured", '<%1', DT2Date(_AdyenSetup."Recon. Integr. Starting Date"));
        MagentoPaymentLine.SetRange(Reconciled, false);

        PaymentGateway.Reset();
        PaymentGateway.SetRange("Integration Type", Enum::"NPR PG Integrations"::Adyen);
        if PaymentGateway.FindSet() then begin
            repeat
                FilterPGCodes += PaymentGateway.Code + '|';
            until PaymentGateway.Next() = 0;
            if StrLen(FilterPGCodes) > 0 then
                FilterPGCodes := FilterPGCodes.TrimEnd('|');

            MagentoPaymentLine.SetFilter("Payment Gateway Code", FilterPGCodes);
            if MagentoPaymentLine.FindSet(true) then begin
                MagentoEntries := MagentoPaymentLine.Count();
                Window.Open(UpdatingMagentoLbl);
                Window.Update(1, MagentoEntries);
                repeat
                    MagentoPaymentLine.Reconciled := true;
                    MagentoPaymentLine."Reconciliation Date" := Today;
                    MagentoPaymentLine.Modify();
                    ProcessedEntries += 1;
                    Window.Update(2, ProcessedEntries);
                until MagentoPaymentLine.Next() = 0;
                Window.Close();
            end;
        end;

        if ProcessedEntries > 0 then
            Message(MagentoUpdateDoneLbl, ProcessedEntries)
        else
            Message(MagentoUpdateNullLbl);
    end;

    internal procedure GetManagementAPIURL(EnvironmentType: Enum "NPR Adyen Environment Type"): Text[2048]
    var
        TestURL: Label 'https://management-test.adyen.com/v3', Locked = true;
        LiveURL: Label 'https://management-live.adyen.com/v3', Locked = true;
    begin
        case EnvironmentType of
            EnvironmentType::Test:
                exit(TestURL);
            EnvironmentType::Live:
                exit(LiveURL);
        end;
    end;

    local procedure InitiateAdyenManagement()
    begin
        _AdyenSetup.Get();
        _AdyenSetup.TestField("Management API Key");
        _AdyenSetup.TestField("Company ID");
    end;

    local procedure CreateWebhookHttpRequestObject(WebhookSetup: Record "NPR Adyen Webhook Setup") RequestText: Text;
    var
        RequestObject: JsonObject;
        AdditionalSettingsObject: JsonObject;
        MerchantsArray: JsonArray;
        MerchantAccount: Record "NPR Adyen Merchant Account";
        EventCode: Record "NPR Adyen Webhook Event Code";
        EventCodesArray: JsonArray;
    begin
        RequestObject.Add('type', Format(WebhookSetup.Type));
        RequestObject.Add('url', WebhookSetup."Web Service URL");
        RequestObject.Add('username', WebhookSetup."Web Service User");
        RequestObject.Add('password', WebhookSetup."Web Service Password");
        if WebhookSetup.Description <> '' then
            RequestObject.Add('description', WebhookSetup.Description);
        RequestObject.Add('active', WebhookSetup.Active);
        RequestObject.Add('communicationFormat', 'json');
        RequestObject.Add('acceptsExpiredCertificate', false);
        RequestObject.Add('acceptsSelfSignedCertificate', true);
        RequestObject.Add('acceptsUntrustedRootCertificate', true);
        RequestObject.Add('populateSoapActionHeader', false);
        RequestObject.Add('filterMerchantAccountType', Format(WebhookSetup."Merchant Accounts Filter Type"));
        if WebhookSetup."Merchant Accounts Filter Type" <> WebhookSetup."Merchant Accounts Filter Type"::allAccounts then begin
            MerchantAccount.Reset();
            if WebhookSetup."Merchant Accounts Filter" <> '' then
                MerchantAccount.SetFilter(Name, WebhookSetup."Merchant Accounts Filter");
            if MerchantAccount.FindSet(false) then begin
                repeat
                    MerchantsArray.Add(MerchantAccount.Name);
                until MerchantAccount.Next() = 0;
            end;
            RequestObject.Add('filterMerchantAccounts', MerchantsArray);
        end;
        if (WebhookSetup.Type = WebhookSetup.Type::standard) and (WebhookSetup."Include Events Filter" <> '') then begin
            EventCode.Reset();
            EventCode.SetFilter("Event Code", WebhookSetup."Include Events Filter");
            if EventCode.FindSet(false) then begin
                repeat
                    EventCodesArray.Add(EventCode."Event Code");
                until EventCode.Next() = 0;
                AdditionalSettingsObject.Add('includeEventCodes', EventCodesArray);
                RequestObject.Add('additionalSettings', AdditionalSettingsObject);
            end;
        end;
        RequestObject.WriteTo(RequestText);
    end;

    local procedure CreateWebhookHttpRequest(RequestText: Text; RequestUrl: Text; Method: Enum "Http Request Type"): Text
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
    begin
        Clear(HttpRequestMessage);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'text/json; charset="utf-8"');
        HttpHeaders.Add('x-api-key', _AdyenSetup."Management API Key");

        if (RequestText <> '') and (not (Method in [Enum::"Http Request Type"::GET])) then
            HttpContent.WriteFrom(RequestText);

        HttpRequestMessage.Content := HttpContent;
        HttpRequestMessage.SetRequestUri(RequestUrl);
        HttpRequestMessage.Method := Method.Names().Get(Method.Ordinals().IndexOf(Method.AsInteger()));

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(ResponseText);

        exit(ResponseText);
    end;

    // Microsoft Entra App Registration
    #region Azure AD application
    internal procedure CreateAzureADApplication()
    var
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        PermissionSets: List of [Code[20]];
        AppDisplayNameLbl: Label 'NaviPartner Adyen Reconciliation integration', MaxLength = 50, Locked = true;
    begin
        PermissionSets.Add('D365 BUS FULL ACCESS');
#if BC17
        PermissionSets.Add('NP RETAIL');
#else
        PermissionSets.Add('NPR NP RETAIL');
#endif

        AADApplicationMgt.CreateAzureADApplicationAndSecret(AppDisplayNameLbl, SecretDisplayName(), PermissionSets);
    end;

    internal procedure CreateAzureADApplicationSecret()
    var
        AppInfo: ModuleInfo;
        AADApplication: Record "AAD Application";
        AADApplicationList: Page "AAD Application List";
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        NoAppsToManageErr: Label 'No AAD Apps with App Name like %1 to manage.';
    begin
        NavApp.GetCurrentModuleInfo(AppInfo);

        AADApplication.SetFilter("App Name", '@' + AppInfo.Name);
        if AADApplication.IsEmpty() then
            Error(NoAppsToManageErr, AppInfo.Name);

        AADApplicationList.LookupMode(true);
        AADApplicationList.SetTableView(AADApplication);
        if AADApplicationList.RunModal() <> Action::LookupOK then
            exit;

        AADApplicationList.GetRecord(AADApplication);
        AADApplicationMgt.CreateAzureADSecret(AADApplication."Client Id", SecretDisplayName());
    end;

    internal procedure RefreshWebhookEventCodes(): Boolean
    var
        EventCodes: Record "NPR Adyen Webhook Event Code";
        Ordinal: Integer;
        IndexOfOrdinal: Integer;
        EventCode: Text;
    begin
        EventCodes.DeleteAll();
        foreach Ordinal in Enum::"NPR Adyen Webhook Event Code".Ordinals() do begin
            IndexOfOrdinal := Enum::"NPR Adyen Webhook Event Code".Ordinals().IndexOf(Ordinal);
            Enum::"NPR Adyen Webhook Event Code".Names().Get(IndexOfOrdinal, EventCode);
            EventCodes.Init();
            EventCodes."Primary Key" := IndexOfOrdinal;
            EventCodes."Event Code" := CopyStr(EventCode, 1, MaxStrLen(EventCodes."Event Code"));
            EventCodes.Insert();
        end;
    end;

    internal procedure DeleteReconciliationLines(DocumentNo: Code[20])
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", DocumentNo);
        if not ReconciliationLine.IsEmpty() then
            ReconciliationLine.DeleteAll(true);
    end;

    internal procedure CreateGLEntryReconciliationLineRelation(GLEntryNo: Integer; DocumentNo: Code[20]; LineNo: Integer; AmountType: Enum "NPR Adyen Recon. Amount Type"; Amount: Decimal;
                                                                                                                                          PostingDate: Date;
                                                                                                                                          PostingDocumentNo: Code[20])
    var
        ReconLineRelation: Record "NPR Adyen Recon. Line Relation";
    begin
        ReconLineRelation.Init();
        ReconLineRelation."GL Entry No." := GLEntryNo;
        ReconLineRelation."Document No." := DocumentNo;
        ReconLineRelation."Document Line No." := LineNo;
        ReconLineRelation."Amount Type" := AmountType;
        ReconLineRelation.Amount := Amount;
        ReconLineRelation."Posting Date" := PostingDate;
        ReconLineRelation."Posting Document No." := PostingDocumentNo;
        ReconLineRelation.Insert();
    end;

    [NonDebuggable]
    internal procedure SuggestAFWebServiceURL(Rec: Record "NPR Adyen Webhook Setup")
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        WebhookBaseurl: Label 'https://adyenreconciliation.azurewebsites.net/api', Locked = true;
        KeyLbl: Label 'NPAdyenAFCode', Locked = True;
        TypeHelper: Codeunit "Type Helper";
        CompanyName: Text;
    begin
        if (not EnvironmentInformation.IsOnPrem()) then begin
            CompanyName := CompanyName();
            TypeHelper.UrlEncode(CompanyName);
            Rec."Web Service URL" := (StrSubstNo('%1/AdyenCloud/%2/%3/%4?code=%5&CompanyName=%6',
            WebhookBaseurl,
            AzureADTenant.GetAadTenantId(),
            EnvironmentInformation.GetEnvironmentName(),
            Rec.ID,
            AzureKeyVaultMgt.GetAzureKeyVaultSecret(KeyLbl),
            CompanyName));
            Rec.Modify(Rec.ID <> '');
        end;
    end;

    internal procedure CreateSaaSSetup()
    var
        AADApplication: Record "AAD Application";
    begin
        CreateAzureADAdyenApplication(AADApplication);
        TryGrantPermission(AADApplication);
    end;

    internal procedure ImportWebhook(json: Text): Boolean
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        JsonRequest: JsonObject;
        OutStr: OutStream;
        AdyenManagement: Codeunit "NPR Adyen Management";
        LogType: Enum "NPR Adyen Rec. Log Type";
        SuccessfullyReceivedAndLoggedLbl: Label 'Web Service has successfully received and logged a Webhook Request.';
        ErrorLbl: Label 'Web Service could not successfully log a Webhook Request because of some issue: %1.';
    begin
        AdyenWebhook.Init();
        AdyenWebhook."Entry No." := 0;
        AdyenWebhook."Request Data".CreateOutStream(OutStr, TextEncoding::UTF8);
        JsonRequest.ReadFrom(json);
        if (not RecordWebhookData(JsonRequest, AdyenWebhook)) then begin
            AdyenWebhook.Success := false;
            OutStr.WriteText(GetLastErrorText());
        end;
        OutStr.WriteText(json);
        // TODO ValidateHMAC
        // TODO Retention Policy
        AdyenWebhook.Insert();

        if AdyenWebhook.Success then begin
            AdyenManagement.CreateLog(LogType::"Background Session", true, SuccessfullyReceivedAndLoggedLbl, 0);
            Commit();
            ProcessEvent(AdyenWebhook);
        end else
            AdyenManagement.CreateLog(LogType::"Background Session", false, ErrorLbl, 0);

        exit(AdyenWebhook.Success);
    end;

    internal procedure CreateReconciliationJob(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        ProcessReconciliationWebhookLbl: Label 'Process Reconciliation Webhooks';
    begin
        if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit, CodeunitID,
                '', ProcessReconciliationWebhookLbl,
                CreateDateTime(Today(), 070000T), 1440,
                '', JobQueueEntry)
            then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure CancelReconciliationJob(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CodeunitID) then
            JobQueueEntry.Cancel();
    end;

    local procedure SecretDisplayName(): Text
    var
        SecretDisplayNameLbl: Label 'NaviPartner Adyen Reconciliation integration - %1', Comment = '%1 = today''s date', Locked = true;
    begin
        exit(StrSubstNo(SecretDisplayNameLbl, Format(Today(), 0, 9)));
    end;

    local procedure CreateAzureADAdyenApplication(var AADApplication: Record "AAD Application")
    var
        AADApplicationInterface: Codeunit "AAD Application Interface";
        MissingPermissionsErr: Label 'You need to have write permission to both %1 and %2. If you do not have access to manage users and Azure AD Applications, you cannot perform this action', Comment = '%1 = table caption of "AAD Application", %2 = table caption of "Access Control"';
        UserDoestNotExistErr: Label 'The user associated with the Azure AD App (%1) does not exist. System cannot assign permissions. Before the app can be used, make sure to create the user and assign appropriate permissions', Comment = '%1 = Azure AD App Client ID';
        AppInfo: ModuleInfo;
        AccessControl: Record "Access Control";
        User: Record User;
        ClientIdLbl: Label '{eb29ef3d-edea-44b1-b5f7-4bd4eb360c29}', Locked = true;
        ClientId: Guid;
    begin
        if not (AADApplication.WritePermission() and AccessControl.WritePermission()) then
            Error(MissingPermissionsErr, AADApplication.TableCaption(), AccessControl.TableCaption());

        NavApp.GetCurrentModuleInfo(AppInfo);
        Evaluate(ClientId, ClientIdLbl);
        AADApplicationInterface.CreateAADApplication(
            ClientId,
            'Adyen Webhook',
            CopyStr(AppInfo.Publisher, 1, 50),
            true
        );
        AADApplication.Get(ClientId);
        AADApplication."App ID" := AppInfo.Id;
        AADApplication."App Name" := CopyStr(AppInfo.Name, 1, MaxStrLen(AADApplication."App Name"));
        AADApplication.Modify();
        Commit();

        if (not User.Get(AADApplication."User ID")) then
            Error(UserDoestNotExistErr, AADApplication."Client Id");

        AddPermissionSet(AADApplication."User ID", 'NPR Adyen Webhook');

        Commit();
    end;

    local procedure TryGrantPermission(var AADApplication: Record "AAD Application")
    var
        OAuth2: Codeunit OAuth2;
        ErrLbl: Label 'An error occoured while granting access: %1';
        ClientIdLbl: Label 'eb29ef3d-edea-44b1-b5f7-4bd4eb360c29', Locked = true;
        ConsentUrlLbl: Label 'https://login.microsoftonline.com/common/adminconsent', Locked = true;
        ConsentSuccess: Boolean;
        PermissionError: Text;
    begin
        if (OAuth2.RequestClientCredentialsAdminPermissions(ClientIdLbl, ConsentUrlLbl, '', ConsentSuccess, PermissionError)) then begin
            if (ConsentSuccess) then begin
                AADApplication."Permission Granted" := True;
                AADApplication.Modify();
                exit;
            end;
            Error(ErrLbl, PermissionError);
        end else begin
            Error(ErrLbl, GetLastErrorText());
        end;
    end;

    local procedure AddPermissionSet(UserSecurityId: Guid; PermissionSetId: Code[20])
    var
        AccessControl: Record "Access Control";
        AggregatePermissionSet: Record "Aggregate Permission Set";
    begin
        AccessControl.SetRange("User Security ID", UserSecurityId);
        AccessControl.SetRange("Role ID", PermissionSetId);
        if (not AccessControl.IsEmpty()) then
            exit;

        AggregatePermissionSet.SetRange("Role ID", PermissionSetId);
        AggregatePermissionSet.FindFirst();

        AccessControl.Init();
        AccessControl."User Security ID" := UserSecurityId;
        AccessControl."Role ID" := PermissionSetId;
        AccessControl.Scope := AggregatePermissionSet.Scope;
        AccessControl."App ID" := AggregatePermissionSet."App ID";
        AccessControl.Insert(true);
    end;

    [TryFunction]
    local procedure RecordWebhookData(JsonRequest: JsonObject; var AdyenWebhook: Record "NPR Adyen Webhook")
    var
        Token: JsonToken;
        ContentToken: JsonToken;
        JsonContent: JsonObject;
        OutStr: OutStream;
        WebhookReference: Text[80];
        Live: Boolean;
        EventCode: Code[35];
        EventCodeEnum: Enum "NPR Adyen Webhook Event Code";
        EventDate: DateTime;
        MerchantAccountName: Text[80];
        PSPReference: Text[100];
    begin
        JsonRequest.Get('WebhookReference', Token);
        WebhookReference := CopyStr(Token.AsValue().AsText(), 1, 80);
        JsonRequest.Get('Content', Token);
        JsonContent.ReadFrom(Token.AsValue().AsText());

        JsonContent.Get('live', ContentToken);
        Live := ContentToken.AsValue().AsBoolean();
        JsonContent.Get('notificationItems', ContentToken);
        ContentToken.AsArray().Get(0, ContentToken);
        ContentToken.AsObject().Get('NotificationRequestItem', ContentToken);
        JsonContent := ContentToken.AsObject();

        JsonContent.Get('eventCode', ContentToken);
        EventCode := CopyStr(ContentToken.AsValue().AsCode(), 1, 35);
        JsonContent.Get('eventDate', ContentToken);
        EventDate := ContentToken.AsValue().AsDateTime();
        JsonContent.Get('merchantAccountCode', ContentToken);
        MerchantAccountName := CopyStr(ContentToken.AsValue().AsText(), 1, 80);
        JsonContent.Get('pspReference', ContentToken);
        PSPReference := CopyStr(ContentToken.AsValue().AsText(), 1, 100);
        JsonContent.Get('success', ContentToken);

        AdyenWebhook."Webhook Data".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(Token.AsValue().AsText());
        AdyenWebhook.Live := Live;
        AdyenWebhook."Created Date" := CurrentDateTime();
        AdyenWebhook."Event Code" := Enum::"NPR Adyen Webhook Event Code".FromInteger(EventCodeEnum.Ordinals.Get(EventCodeEnum.Names.IndexOf(EventCode)));
        AdyenWebhook."Event Date" := EventDate;
        AdyenWebhook."Merchant Account Name" := MerchantAccountName;
        AdyenWebhook."PSP Reference" := PSPReference;
        AdyenWebhook.Success := true;
        AdyenWebhook."Webhook Reference" := WebhookReference;
    end;

    local procedure ProcessEvent(AdyenWebhook: Record "NPR Adyen Webhook")
    var
        ReportReady: Codeunit "NPR Adyen Process Report Ready";
    begin
        case AdyenWebhook."Event Code" of
            "NPR Adyen Webhook Event Code"::REPORT_AVAILABLE:
                begin
                    ReportReady.ProcessReportReadyWebhook(AdyenWebhook);
                end;
            "NPR Adyen Webhook Event Code"::AUTHORISATION:
                begin
                    // TODO
                end;
        end;
    end;

    #endregion

    var
        _AdyenSetup: Record "NPR Adyen Setup";
        _ImportedWebhooks: Integer;
}
