codeunit 6184796 "NPR Adyen Management"
{
    Access = Internal;

    procedure UpdateMerchantList(PageNumber: Integer) Updated: Boolean
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        MerchantAccount: Record "NPR Adyen Merchant Account";
        GetMerchantsEndpoint: Label '/companies/%1/merchants';
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

        HttpClient.DefaultRequestHeaders().Add('x-api-key', AdyenSetup."Management API Key");
        RequestURL := AdyenSetup."Management Base URL" + StrSubstNo(GetMerchantsEndpoint, AdyenSetup."Company ID") + '?pageSize=100';
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
                        MerchantAccount."Company ID" := AdyenSetup."Company ID";
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

    procedure CreateWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup"): Boolean
    var
        CreateWebhookEndpoint: Label '/companies/%1/webhooks';
        RequestText: Text;
        RequestUrl: Text;
    begin
        InitiateAdyenManagement();

        WebhookSetup.TestField("Web Service URL");
        if WebhookSetup."Web Service Security" = WebhookSetup."Web Service Security"::"Basic authentication" then begin
            WebhookSetup.TestField("Web Service User");
            WebhookSetup.TestField("Web Service Password");
        end;

        RequestUrl := AdyenSetup."Management Base URL" + StrSubstNo(CreateWebhookEndpoint, AdyenSetup."Company ID");

        RequestText := CreateWebhookHttpRequestObject(WebhookSetup);

        exit(CreateWebhookHttpRequest(WebhookSetup, RequestText, RequestUrl));
    end;

    procedure CreateDocumentFromWebhookRequest(var WebhookRequest: Record "NPR AF Rec. Webhook Request")
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        ReportOutStream: OutStream;
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        RequestIsEmptyError01: Label 'Webhook Request No. %1 has no Report Download URL! Try another one!';
        DocumentExistConfirmation: Label 'Such document already exists! Open?';
        MultipleDocumentExist: Label 'Such documents already exist! Open?';
        UndefinedReportSchemeError: Label 'Report Scheme is undefined!';
        SchemeNotImplemented: Label 'Current Report Scheme is not yet implemented! Contact your Administrator!';
        HttpErrorLabel: Label 'Error: %1 - %2';
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
                AdyenSetup.Get();
                HttpClient.DefaultRequestHeaders.Add('x-api-key', AdyenSetup."Download Report API Key");
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

    procedure CreateDocumentFromFile(): Boolean
    var
        FileName: Text;
        InStr: InStream;
        OutStr: OutStream;
        WebhookRequest: Record "NPR AF Rec. Webhook Request";
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        UndefinedReportSchemeError: Label 'Report Scheme is undefined!';
        FileNotUploaded: Label 'Error: The file was not uploaded.';
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
        // Create Webhook Request from File
        Clear(WebhookRequest);
        WebhookRequest.Init();
        WebhookRequest.ID := 0;
        WebhookRequest."Creation Date" := CurrentDateTime();
        WebhookRequest."Status Code" := 200;
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

    procedure OpenLogs(WebhookRequest: Record "NPR AF Rec. Webhook Request")
    var
        Logs: Record "NPR Adyen Reconciliation Log";
    begin
        Logs.Reset();
        Logs.SetRange("Webhook Request ID", WebhookRequest.ID);
        Logs.SetFilter("Creation Date", '>=%1', CreateDateTime(Today(), 0T));
        if not Logs.IsEmpty() then
            Page.Run(Page::"NPR Adyen Reconciliation Logs", Logs);
    end;

    procedure ModifyWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup") Success: Boolean
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        RequestUrl: Text;
        ChangeWebhookEndpoint: Label '/companies/%1/webhooks/%2';
        RequestObject: JsonObject;
        ResponseText: Text;
        ResponseObject: JsonObject;
        JsonToken: JsonToken;
        RequestText: Text;
        MerchantAccount: Record "NPR Adyen Merchant Account";
        MerchantsArray: JsonArray;
    begin
        InitiateAdyenManagement();

        RequestUrl := AdyenSetup."Management Base URL" + StrSubstNo(ChangeWebhookEndpoint, AdyenSetup."Company ID", WebhookSetup.ID);

        RequestObject.Add('active', WebhookSetup.Active);
        RequestObject.Add('url', WebhookSetup."Web Service URL");
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

        RequestObject.WriteTo(RequestText);

        Clear(HttpRequestMessage);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'text/json; charset="utf-8"');
        HttpHeaders.Add('x-api-key', AdyenSetup."Management API Key");
        HttpContent.WriteFrom(RequestText);
        HttpRequestMessage.SetRequestUri(RequestUrl);
        HttpRequestMessage.Content := HttpContent;
        HttpRequestMessage.Method := 'PATCH';

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(ResponseText);
        if HttpResponseMessage.IsSuccessStatusCode() then begin
            JsonToken.ReadFrom(ResponseText);
            ResponseObject := JsonToken.AsObject();
            ResponseObject.Get('active', JsonToken);
            WebhookSetup.Active := JsonToken.AsValue().AsBoolean();
            WebhookSetup.Modify();
            Success := true;
        end;
    end;

    procedure DeleteWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup")
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        HttpRequestMessage: HttpRequestMessage;
        HttpHeaders: HttpHeaders;
        RequestUrl: Text;
        DeleteWebhookEndpoint: Label '/companies/%1/webhooks/%2';
        ResponseText: Text;
    begin
        InitiateAdyenManagement();
        WebhookSetup.TestField(ID);

        RequestUrl := AdyenSetup."Management Base URL" + StrSubstNo(DeleteWebhookEndpoint, AdyenSetup."Company ID", WebhookSetup.ID);
        Clear(HttpRequestMessage);
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('x-api-key', AdyenSetup."Management API Key");
        HttpRequestMessage.SetRequestUri(RequestUrl);
        HttpRequestMessage.Method := 'DELETE';
        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(ResponseText);
        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(ResponseText);
    end;

    procedure ImportWebhooks(pageNumber: Integer) Updated: Boolean
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        WebhookType: Enum "NPR Adyen Webhook Type";
        MerchantFilterType: Enum "NPR Adyen Merchant Filter Type";
        GetAllWebhooksEndpoint: Label '/companies/%1/webhooks';
        HttpErrorLabel: Label 'Error: %1 - %2';
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
        i: Integer;
        y: Integer;
    begin
        InitiateAdyenManagement();

        RequestUrl := AdyenSetup."Management Base URL" + StrSubstNo(GetAllWebhooksEndpoint, AdyenSetup."Company ID") + '?pageSize=100';
        if pageNumber > 0 then
            RequestURL += '&pageNumber=' + Format(pageNumber);

        Clear(HttpRequestMessage);
        HttpRequestMessage.GetHeaders(HttpHeaders);
        HttpHeaders.Add('x-api-key', AdyenSetup."Management API Key");
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
                                for y := 0 to MerchantArray.Count - 1 do begin
                                    MerchantArray.Get(y, MerchantToken);
                                    WebhookSetup."Merchant Accounts Filter" += CopyStr(MerchantToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup."Merchant Accounts Filter")) + '|';
                                end;
                                if WebhookSetup."Merchant Accounts Filter".Contains('|') then
                                    WebhookSetup."Merchant Accounts Filter" := DelChr(WebhookSetup."Merchant Accounts Filter", '>', '|');
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

    procedure GetImportedWebhooksAmount(): Integer
    begin
        exit(_ImportedWebhooks);
    end;

    procedure CreateLog(LogTypeLocal: Enum "NPR Adyen Rec. Log Type"; Success: Boolean; Description: Text; RequestID: Integer)
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

    procedure GetPspReference(data: Text): Text
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

    procedure DefineReportType(PSPReference: Text) ReportType: Enum "NPR Adyen Report Type"
    begin
        if PSPReference.Contains('external_settlement_detail_report') then
            exit(ReportType::"External Settlement detail (C)");
        if PSPReference.Contains('settlement_detail_report') then
            exit(ReportType::"Settlement details");

        exit(ReportType::Undefined);
    end;

    procedure DefineReportScheme(ReportType: Enum "NPR Adyen Report Type"; var Scheme: array[50] of Text[35]; var SchemeColumnNumber: Integer)
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

    procedure ChangeColorLine(ReconciliationLine: Record "NPR Adyen Reconciliation Line"): Text[50]
    begin
        if ReconciliationLine.Status in [ReconciliationLine.Status::Posted, ReconciliationLine.Status::"Not to be Posted"] then
            exit('favorable')
        else
            exit('Unfavorable');
    end;

    procedure ChangeColorDocument(ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr"): Text[50]
    begin
        if ReconciliationHeader.Posted then
            exit('favorable')
        else
            exit('Unfavorable');
    end;

    procedure SimulateWebhookRequest(ReportName: Text[100])
    var
        RequestContent: Label '{"live":"false","notificationItems":[{"NotificationRequestItem":{"amount":{"currency":"EUR","value":0},"eventCode":"REPORT_AVAILABLE","eventDate":"2024-03-28T13:10:26+01:00","merchantAccountCode":"NavipartnerAfPPOS","merchantReference":"","pspReference":"%2","reason":"%1","success":"true"}}]}';
        ReportDownloadURL: Label 'https://ca-test.adyen.com/reports/download/MerchantAccount/NavipartnerAfPPOS/';
        ErrorText01: Label 'Could not download the report - %1 %2';
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
        ReportOutStream: OutStream;
        RequestOutStream: OutStream;
        WebhookRequest: Record "NPR AF Rec. Webhook Request";
    begin
        AdyenSetup.Get();
        HttpClient.DefaultRequestHeaders().Add('x-api-key', AdyenSetup."Download Report API Key");
        HttpClient.Get(ReportDownloadURL + ReportName, HttpResponseMessage);
        if (HttpResponseMessage.IsSuccessStatusCode) then begin
            HttpResponseMessage.Content.ReadAs(ResponseText);

            WebhookRequest.Init();
            WebhookRequest.ID := 0;
            WebhookRequest."Creation Date" := CurrentDateTime();
            WebhookRequest."Status Code" := HttpResponseMessage.HttpStatusCode();
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

    local procedure InitiateAdyenManagement()
    begin
        AdyenSetup.Get();
        AdyenSetup.TestField("Management Base URL");
        AdyenSetup.TestField("Management API Key");
        AdyenSetup.TestField("Company ID");
    end;

    local procedure CreateWebhookHttpRequestObject(WebhookSetup: Record "NPR Adyen Webhook Setup") RequestText: Text;
    var
        RequestObject: JsonObject;
        MerchantsArray: JsonArray;
        MerchantAccount: Record "NPR Adyen Merchant Account";
    begin
        RequestObject.Add('type', Format(WebhookSetup.Type));
        RequestObject.Add('url', WebhookSetup."Web Service URL");
        RequestObject.Add('username', WebhookSetup."Web Service User");
        RequestObject.Add('password', WebhookSetup."Web Service Password");
        RequestObject.Add('active', false);
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
        RequestObject.WriteTo(RequestText);
    end;

    local procedure CreateWebhookHttpRequest(var WebhookSetup: Record "NPR Adyen Webhook Setup"; RequestText: Text; RequestUrl: Text): Boolean
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        JsonToken: JsonToken;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseObject: JsonObject;
        ResponseText: Text;
    begin
        Clear(HttpRequestMessage);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'text/json; charset="utf-8"');
        HttpHeaders.Add('x-api-key', AdyenSetup."Management API Key");
        HttpContent.WriteFrom(RequestText);
        HttpRequestMessage.SetRequestUri(RequestUrl);
        HttpRequestMessage.Content := HttpContent;
        HttpRequestMessage.Method := 'POST';

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);
        HttpResponseMessage.Content().ReadAs(ResponseText);

        if HttpResponseMessage.IsSuccessStatusCode() then begin
            JsonToken.ReadFrom(ResponseText);
            ResponseObject := JsonToken.AsObject();
            ResponseObject.Get('id', JsonToken);
            WebhookSetup.ID := CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(WebhookSetup.ID));
            if WebhookSetup.ID <> '' then begin
                WebhookSetup.Modify();
                exit(true);
            end;
        end;
        exit(false);
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

    local procedure SecretDisplayName(): Text
    var
        SecretDisplayNameLbl: Label 'NaviPartner Adyen Reconciliation integration - %1', Comment = '%1 = today''s date', Locked = true;
    begin
        exit(StrSubstNo(SecretDisplayNameLbl, Format(Today(), 0, 9)));
    end;

    #endregion

    var
        AdyenSetup: Record "NPR Adyen Setup";
        _ImportedWebhooks: Integer;
}
