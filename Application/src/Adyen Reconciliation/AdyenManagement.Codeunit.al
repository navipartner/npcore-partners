codeunit 6184796 "NPR Adyen Management"
{
    Access = Internal;

    #region Merchant Accounts API
    internal procedure UpdateMerchantList(PageNumber: Integer) Updated: Boolean
    var
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        MerchantAccount: Record "NPR Adyen Merchant Account";
        GetMerchantsEndpoint: Label '/merchants', Locked = true;
        RequestURL: Text;
        ResponseText: Text;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        PagesTotal: Integer;
        MerchantsArray: JsonArray;
        MerchantObject: JsonObject;
        i: Integer;
    begin
        if not InitiateAdyenManagement() then
            exit;

        HttpClient.DefaultRequestHeaders().Add('x-api-key', _AdyenSetup."Management API Key");
        RequestURL := GetManagementAPIURL(_AdyenSetup."Environment Type") + GetMerchantsEndpoint + '?pageSize=100';
        if PageNumber > 0 then
            RequestURL += '&pageNumber=' + Format(PageNumber)
        else
            MerchantAccount.DeleteAll();
        HttpClient.Get(RequestURL, HttpResponseMessage);
        if (HttpResponseMessage.IsSuccessStatusCode()) then begin
            HttpResponseMessage.Content().ReadAs(ResponseText);
            JsonToken.ReadFrom(ResponseText);
            if not JsonToken.IsObject() then
                exit;
            JsonObject := JsonToken.AsObject();
            if not JsonObject.Get('pagesTotal', JsonToken) then
                exit;
            PagesTotal := JsonToken.AsValue().AsInteger();
            if not JsonObject.Get('data', JsonToken) then
                exit;
            if not JsonToken.IsArray() then
                exit;
            MerchantsArray := JsonToken.AsArray();
            if MerchantsArray.Count() > 0 then begin
                foreach JsonToken in MerchantsArray do begin
                    if JsonToken.IsObject() then begin
                        MerchantObject := JsonToken.AsObject();
                        if MerchantObject.Get('id', JsonToken) then begin
                            MerchantAccount.Init();
                            MerchantAccount."Company ID" := _AdyenSetup."Company ID";
                            MerchantAccount.Name := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(MerchantAccount.Name));
                            MerchantAccount.Insert();
                            Updated := true;
                        end;
                    end;
                end;
                if (PagesTotal > 1) and (PageNumber = 0) then
                    for i := 2 to PagesTotal do begin
                        UpdateMerchantList(i);
                    end;
            end;
        end;
    end;
    #endregion

    #region Webhooks
    internal procedure CreateWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup"): Boolean
    var
        CreateWebhookEndpoint: Label '/merchants/%1/webhooks', Locked = true;
        AFWebServiceURL: Label 'https://nppaywebhook.azurewebsites.net/api/NPPayCloud', Locked = true;
        RequestText: Text;
        ResponseText: Text;
        RequestUrl: Text;
        JsonToken: JsonToken;
        ResponseObject: JsonObject;
    begin
        InitiateAdyenManagement();

        WebhookSetup.TestField("Web Service URL");
        WebhookSetup.TestField("Merchant Account");
        if WebhookSetup."Web Service Security" = WebhookSetup."Web Service Security"::"Basic authentication" then begin
            WebhookSetup.TestField("Web Service User");
            WebhookSetup.TestField("Web Service Password");
        end;

        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(CreateWebhookEndpoint, WebhookSetup."Merchant Account");

        RequestText := CreateWebhookHttpRequestObject(WebhookSetup);
        ResponseText := CreateAdyenHttpRequest(RequestText, RequestUrl, Enum::"Http Request Type"::POST);
        JsonToken.ReadFrom(ResponseText);
        ResponseObject := JsonToken.AsObject();
        if not ResponseObject.Get('id', JsonToken) then
            exit;
        WebhookSetup.ID := CopyStr(JsonToken.AsValue().AsCode(), 1, MaxStrLen(WebhookSetup.ID));
        if ResponseObject.Get('description', JsonToken) then
            WebhookSetup.Description := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup.Description));
        WebhookSetup.Modify(false);
        if (WebhookSetup."Web Service URL" <> '') and (WebhookSetup."Web Service URL".Contains(AFWebServiceURL)) then
            SuggestAFWebServiceURL(WebhookSetup);
        exit(true);
    end;

    internal procedure ModifyWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup") Success: Boolean
    var
        RequestUrl: Text;
        ChangeWebhookEndpoint: Label '/merchants/%1/webhooks/%2', Locked = true;
        NoResponseLbl: Label 'Internal Server Error: No Valid Response.';
        RequestObject: JsonObject;
        AdditionalSettingsObject: JsonObject;
        ResponseText: Text;
        ResponseObject: JsonObject;
        JsonToken: JsonToken;
        RequestText: Text;
        EventCode: Record "NPR Adyen Webhook Event Code";
        EventCodesArray: JsonArray;
    begin
        InitiateAdyenManagement();

        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(ChangeWebhookEndpoint, WebhookSetup."Merchant Account", WebhookSetup.ID);

        RequestObject.Add('active', WebhookSetup.Active);
        RequestObject.Add('url', WebhookSetup."Web Service URL");
        if WebhookSetup.Description <> '' then
            RequestObject.Add('description', WebhookSetup.Description);
        RequestObject.Add('username', WebhookSetup."Web Service User");
        RequestObject.Add('password', WebhookSetup."Web Service Password");

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
        ResponseText := CreateAdyenHttpRequest(RequestText, RequestUrl, Enum::"Http Request Type"::PATCH);

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
        DeleteWebhookEndpoint: Label '/merchants/%1/webhooks/%2', Locked = true;
        SuccessDeleteLbl: Label 'Successfully deleted Webhook %1 from NP Pay.';
        AlreadyDeletedLbl: Label 'Webhook with ID %1 had already been deleted.';
    begin
        InitiateAdyenManagement();
        WebhookSetup.TestField(ID);

        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(DeleteWebhookEndpoint, WebhookSetup."Merchant Account", WebhookSetup.ID);
        if CreateAdyenHttpRequest('', RequestUrl, Enum::"Http Request Type"::DELETE) = '' then
            Message(SuccessDeleteLbl, WebhookSetup.ID)
        else
            Message(AlreadyDeletedLbl, WebhookSetup.ID);
    end;

    internal procedure RefreshWebhook(var WebhookSetup: Record "NPR Adyen Webhook Setup"): Boolean
    var
        GetWebhookEndpoint: Label '/merchants/%1/webhooks/%2', Locked = true;
        WebhookDoesNotExist: Label 'Webhook with ID %1 does not exist anymore.';
        RequestUrl: Text;
        ResponseText: Text;
        JsonToken: JsonToken;
        ResponseObject: JsonObject;
    begin
        InitiateAdyenManagement();

        WebhookSetup.TestField(ID);
        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(GetWebhookEndpoint, WebhookSetup."Merchant Account", WebhookSetup.ID);

        ResponseText := CreateAdyenHttpRequest('', RequestUrl, Enum::"Http Request Type"::GET);
        JsonToken.ReadFrom(ResponseText);
        ResponseObject := JsonToken.AsObject();
        if ResponseObject.Get('id', JsonToken) then begin
            if (JsonToken.AsValue().AsText() = WebhookSetup.ID) then
                exit(CompareWebhookConfigurations(WebhookSetup, ResponseObject));
        end else
            Message(WebhookDoesNotExist, WebhookSetup.ID);
    end;

    internal procedure CompareWebhookConfigurations(var WebhookSetup: Record "NPR Adyen Webhook Setup"; WebhookObject: JsonObject) Updated: Boolean
    var
        JsonToken: JsonToken;
    begin
        if WebhookObject.Get('url', JsonToken) then
            if JsonToken.AsValue().AsText() <> WebhookSetup."Web Service URL" then begin
                WebhookSetup."Web Service URL" := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup."Web Service URL"));
                WebhookSetup.Modify(false);
                Updated := true;
            end;
        if WebhookObject.Get('description', JsonToken) then
            if JsonToken.AsValue().AsText() <> WebhookSetup.Description then begin
                WebhookSetup.Description := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup.Description));
                WebhookSetup.Modify(false);
                Updated := true;
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
                WebhookSetup."Web Service User" := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup."Web Service User"));
                WebhookSetup.Modify(false);
                Updated := true;
            end;
    end;

    internal procedure ImportWebhooks(pageNumber: Integer; MerchantAccount: Text[80])
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        WebhookType: Enum "NPR Adyen Webhook Type";
        GetAllWebhooksEndpoint: Label '/merchants/%1/webhooks', Locked = true;
        RequestUrl: Text;
        ResponseText: Text;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        PagesTotal: Integer;
        WebhooksArray: JsonArray;
        WebhookObject: JsonObject;
        EventCodeArray: JsonArray;
        EventCodeToken: JsonToken;
        i: Integer;
    begin
        InitiateAdyenManagement();

        RequestUrl := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(GetAllWebhooksEndpoint, MerchantAccount) + '?pageSize=100';
        if pageNumber > 0 then
            RequestURL += '&pageNumber=' + Format(pageNumber);

        ResponseText := CreateAdyenHttpRequest('', RequestUrl, Enum::"Http Request Type"::GET);

        JsonToken.ReadFrom(ResponseText);
        JsonObject := JsonToken.AsObject();
        if JsonObject.Get('pagesTotal', JsonToken) then
            pagesTotal := JsonToken.AsValue().AsInteger()
        else
            Error(ResponseText);

        if not JsonObject.Get('data', JsonToken) then
            Error(ResponseText);

        if not JsonToken.IsArray() then
            exit;

        WebhooksArray := JsonToken.AsArray();
        if WebhooksArray.Count() > 0 then begin
            foreach JsonToken in WebhooksArray do begin
                if JsonToken.IsObject() then begin
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
                            if WebhookObject.Get('description', JsonToken) then
                                WebhookSetup.Description := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup.Description));
                            if WebhookObject.Get('username', JsonToken) then
                                if JsonToken.AsValue().AsText() <> '' then begin
                                    WebhookSetup."Web Service Security" := WebhookSetup."Web Service Security"::"Basic authentication";
                                    WebhookSetup."Web Service User" := CopyStr(JsonToken.AsValue().AsText(), 1, MaxStrLen(WebhookSetup."Web Service User"));
                                end;
                            WebhookObject.Get('active', JsonToken);
                            WebhookSetup.Active := JsonToken.AsValue().AsBoolean();
                            WebhookSetup."Merchant Account" := MerchantAccount;
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
                        end;
                    end;
                end;
            end;
            if (pagesTotal > 1) and (pageNumber = 0) then
                for i := 2 to pagesTotal do begin
                    ImportWebhooks(i, MerchantAccount);
                end;
        end;
    end;

    internal procedure GetImportedWebhooksAmount(): Integer
    begin
        exit(_ImportedWebhooks);
    end;

    local procedure CreateWebhookHttpRequestObject(WebhookSetup: Record "NPR Adyen Webhook Setup") RequestText: Text;
    var
        RequestObject: JsonObject;
        AdditionalSettingsObject: JsonObject;
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

    internal procedure CreateAutoRescheduleAdyenJob(CodeunitID: Integer; JobDescription: Text; NoOfMinutesBetweenRuns: Integer; AutoRescheduleDelaySec: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
    begin
        JobQueueMgt.SetJobTimeout(4, 0);  // 4 hours
        if AutoRescheduleDelaySec > 0 then
            JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, AutoRescheduleDelaySec, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
                JobQueueEntry."Object Type to Run"::Codeunit,
                CodeunitID,
                '',
                JobDescription,
                CreateDateTime(Today(), 070000T),
                NoOfMinutesBetweenRuns,
                '',
                JobQueueEntry)
            then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure CreateAutoRescheduleAdyenJob(CodeunitID: Integer; JobDescription: Text; AutoRescheduleDelaySec: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
    begin
        NotBeforeDateTime := CreateDateTime(Today, 070000T);
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueMgt.SetJobTimeout(4, 0);  // 4 hours
        if AutoRescheduleDelaySec > 0 then
            JobQueueMgt.SetAutoRescheduleAndNotifyOnError(true, AutoRescheduleDelaySec, '');
        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            CodeunitID,
            '',
            JobDescription,
            NotBeforeDateTime,
            DT2Time(NotBeforeDateTime),
            080000T,
            NextRunDateFormula,
            '',
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshAutoAdyenJob()
    var
        ProccessPostPaymentLine: Label 'Process Posting Payment Lines for posted documents.';
        AdyenManagement: Codeunit "NPR Adyen Management";
        AdyenSetup: Record "NPR Adyen Setup";
        MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
    begin
        if not AdyenSetup.Get() then
            exit;
        if not AdyenSetup."Enable Pay by Link" then
            exit;
        if not MagentoPaymentGateway.Get(AdyenSetup."Pay By Link Gateaway Code") then
            exit;
        if MagentoPaymentGateway."Integration Type" <> MagentoPaymentGateway."Integration Type"::Adyen then
            exit;
        if AdyenSetup."PayByLink Enable Auto Posting" then
            AdyenManagement.CreateAutoRescheduleAdyenJob(Codeunit::"NPR Adyen Post Payment Lines", ProccessPostPaymentLine, 1, 600) //Reschedule to run again in 10 minutes on error
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure RefreshProcessPayByLinkJob()
    var
        ProcessPayByLinkWebhook: Label 'Process Pay by Link Webhook Requests';
        AdyenManagement: Codeunit "NPR Adyen Management";
        MagentoPaymentGateway: Record "NPR Magento Payment Gateway";
        AdyenSetup: Record "NPR Adyen Setup";

    begin
        if not AdyenSetup.Get() then
            exit;
        if not AdyenSetup."Enable Pay by Link" then
            exit;
        if not MagentoPaymentGateway.Get(AdyenSetup."Pay By Link Gateaway Code") then
            exit;
        if MagentoPaymentGateway."Integration Type" <> MagentoPaymentGateway."Integration Type"::Adyen then
            exit;
        AdyenManagement.CreateAutoRescheduleAdyenJob(Codeunit::"NPR Adyen PayByLink Status JQ", ProcessPayByLinkWebhook, 1, 600) //Reschedule to run again in 10 minutes on error
    end;

    internal procedure CancelAdyenJob(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CodeunitID) then
            JobQueueEntry.Cancel();
    end;

    internal procedure SetOnHoldJob(CodeunitID: Integer)
    var
        JobQueueEntry: Record "Job Queue Entry";
    begin
        if JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, CodeunitID) then
            JobQueueEntry.SetStatus(JobQueueEntry.Status::"On Hold");
    end;

    local procedure ValidateWebhookReference(json: Text): Boolean
    var
        MerchantAccount: Record "NPR Adyen Merchant Account";
        ResponseText: Text;
        JsonObject: JsonObject;
        RequestObject: JsonObject;
        RequestToken: JsonToken;
        JsonToken: JsonToken;
        JsonWebhookToken: JsonToken;
        RequestURL: Text;
        GetWebhooksEndpoint: Label '/merchants/%1/webhooks', Locked = true;
    begin
        if not InitiateAdyenManagement() then
            exit;

        UpdateMerchantList(0);

        if MerchantAccount.FindSet() then
            repeat
                RequestURL := GetManagementAPIURL(_AdyenSetup."Environment Type") + StrSubstNo(GetWebhooksEndpoint, MerchantAccount.Name);
                ResponseText := CreateAdyenHttpRequest('', RequestURL, Enum::"Http Request Type"::GET);

                if ResponseText = '' then
                    exit;

                JsonObject.ReadFrom(ResponseText);
                if not JsonObject.Get('data', JsonToken) then
                    exit;

                RequestObject.ReadFrom(json);
                if not RequestObject.Get('WebhookReference', RequestToken) then
                    exit;

                foreach JsonWebhookToken in JsonToken.AsArray() do begin
                    if JsonWebhookToken.AsObject().Get('id', JsonWebhookToken) then
                        if JsonWebhookToken.AsValue().AsCode() = RequestToken.AsValue().AsCode() then
                            exit(true);
                end;
            until MerchantAccount.Next() = 0;
    end;

    internal procedure InitWebhookSetup(var WebhookSetup: Record "NPR Adyen Webhook Setup"; WebhookEventsFilter: Text; MerchantAccount: Text[80]; AdyenWebhookType: Enum "NPR Adyen Webhook Type")
    begin
        WebhookSetup.Init();
        WebhookSetup."Primary Key" := 0;
        WebhookSetup."Merchant Account" := MerchantAccount;
        WebhookSetup.Type := AdyenWebhookType;
        WebhookSetup."Include Events Filter" := CopyStr(WebhookEventsFilter, 1, MaxStrLen(WebhookSetup."Include Events Filter"));
        WebhookSetup.Active := true;
        WebhookSetup.Insert();
        SuggestAFWebServiceURL(WebhookSetup);
    end;

    [NonDebuggable]
    internal procedure SuggestAFWebServiceURL(var Rec: Record "NPR Adyen Webhook Setup")
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        AzureKeyVaultMgt: Codeunit "NPR Azure Key Vault Mgt.";
        WebhookBaseurl: Label 'https://nppaywebhook.azurewebsites.net/api', Locked = true;
        KeyLbl: Label 'NPPayAFCode', Locked = True;
        OnPremLbl: Label 'NP Pay BC Integration is supported only on Cloud environment.\Current environment - ''OnPrem''.';
        TypeHelper: Codeunit "Type Helper";
        CompanyName: Text;
    begin
        if EnvironmentInformation.IsOnPrem() then
            Error(OnPremLbl);

        CompanyName := CompanyName();
        TypeHelper.UrlEncode(CompanyName);
        Rec."Web Service URL" := (StrSubstNo('%1/NPPayCloud/%2/%3/%4?code=%5&CompanyName=%6',
        WebhookBaseurl,
        AzureADTenant.GetAadTenantId(),
        EnvironmentInformation.GetEnvironmentName(),
        Rec.ID,
        AzureKeyVaultMgt.GetAzureKeyVaultSecret(KeyLbl),
        CompanyName));
        Rec.Modify(Rec.ID <> '');
    end;
    #endregion

    #region Initiate
    [TryFunction]
    local procedure InitiateAdyenManagement()
    begin
        _AdyenSetup.GetRecordOnce();
        _AdyenSetup.TestField("Management API Key");
        _AdyenSetup.TestField("Company ID");
    end;

    internal procedure CreateSaaSSetup()
    var
        AADApplicationMgt: Codeunit "NPR AAD Application Mgt.";
        ClientId: Guid;
        PermissionSets: List of [Code[20]];
        ErrorTxt: Text;
        ClientIdLbl: Label '{eb29ef3d-edea-44b1-b5f7-4bd4eb360c29}', Locked = true;
    begin
        //Register Azure AD Adyent Application and Try Grant Permissions
        Evaluate(ClientId, ClientIdLbl);
        PermissionSets.Add('NPR Adyen Webhook');
        AADApplicationMgt.RegisterAzureADApplication(ClientId, 'Adyen Webhook', PermissionSets);
        if not AADApplicationMgt.TryGrantConsentToApp(ClientId, 'common', ErrorTxt) then
            Error(ErrorTxt);
    end;
    #endregion

    #region Helper
    local procedure CreateAdyenHttpRequest(RequestText: Text; RequestUrl: Text; Method: Enum "Http Request Type"): Text
    var
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ResponseText: Text;
    begin
        if _AdyenSetup."Management API Key" = '' then
            exit;
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

    internal procedure ChangeColorLine(ReconciliationLine: Record "NPR Adyen Recon. Line"): Text[50]
    begin
        case ReconciliationLine.Status of
            ReconciliationLine.Status::"Failed to Match", ReconciliationLine.Status::"Failed to Post":
                exit('Unfavorable');
            else
                exit('Standard');
        end;
    end;

    internal procedure CreateGeneralLog(LogType: Enum "NPR Adyen Webhook Log Type"; Success: Boolean; Description: Text; RequestEntryNo: Integer)
    var
        Log: Record "NPR Adyen Webhook Log";
    begin
        Log.Init();
        Log."Entry No." := 0;
        Log."Webhook Request Entry No." := RequestEntryNo;
        Log.Type := LogType;
        Log."Creation Date" := CurrentDateTime();
        Log.Success := Success;
        Log.Description := CopyStr(Description, 1, MaxStrLen(Log.Description));
        Log.Insert();
    end;

    internal procedure CreateReconciliationLog(LogType: Enum "NPR Adyen Rec. Log Type"; Success: Boolean; Description: Text; RequestID: Integer)
    var
        Log: Record "NPR Adyen Reconciliation Log";
    begin
        Log.Init();
        Log.ID := 0;
        Log."Webhook Request ID" := RequestID;
        Log.Type := LogType;
        Log."Creation Date" := CurrentDateTime();
        Log.Success := Success;
        Log.Description := CopyStr(Description, 1, MaxStrLen(Log.Description));
        Log.Insert();
    end;

    internal procedure OpenReconciliationLogs(WebhookRequest: Record "NPR AF Rec. Webhook Request")
    var
        Logs: Record "NPR Adyen Reconciliation Log";
    begin
        Logs.Reset();
        Logs.SetRange("Webhook Request ID", WebhookRequest.ID);
        Logs.SetFilter("Creation Date", '>=%1', CreateDateTime(Today(), 0T));
        if not Logs.IsEmpty() then
            Page.Run(Page::"NPR Adyen Reconciliation Logs", Logs);
    end;

    internal procedure TestApiKey(ManagementAPIKey: Text[2048]; EnvironmentType: Enum "NPR Adyen Environment Type")
    var
        RequestURL: Text;
        GetCompaniesEndpoint: Label '/companies', Locked = true;
        HttpClient: HttpClient;
        HttpContent: HttpContent;
        HttpHeaders: HttpHeaders;
        HttpRequestMessage: HttpRequestMessage;
        HttpResponseMessage: HttpResponseMessage;
        ManagementKeyIsNotValidLbl: Label 'Management API key is not valid. Please update the Management API key.';
    begin
        RequestURL := GetManagementAPIURL(EnvironmentType) + GetCompaniesEndpoint;

        Clear(HttpRequestMessage);
        HttpContent.GetHeaders(HttpHeaders);
        HttpHeaders.Clear();
        HttpHeaders.Add('Content-Type', 'text/json; charset="utf-8"');
        HttpHeaders.Add('x-api-key', ManagementAPIKey);

        HttpRequestMessage.Content := HttpContent;
        HttpRequestMessage.SetRequestUri(RequestUrl);
        HttpRequestMessage.Method := 'GET';

        HttpClient.Send(HttpRequestMessage, HttpResponseMessage);

        if not HttpResponseMessage.IsSuccessStatusCode() then
            Error(ManagementKeyIsNotValidLbl);
    end;
    #endregion

    #region Reconciliation
    internal procedure DeleteReconciliationLines(DocumentNo: Code[20])
    var
        ReconciliationLine: Record "NPR Adyen Recon. Line";
    begin
        ReconciliationLine.Reset();
        ReconciliationLine.SetRange("Document No.", DocumentNo);
        if not ReconciliationLine.IsEmpty() then
            ReconciliationLine.DeleteAll(true);
    end;

    internal procedure CreateGLEntryReconciliationLineRelation(GLEntryNo: Integer; DocumentNo: Code[20]; LineNo: Integer; AmountType: Enum "NPR Adyen Recon. Amount Type"; Amount: Decimal; PostingDate: Date; PostingNo: Code[20])
    var
        ReconLineRelation: Record "NPR Adyen Recons.Line Relation";
    begin
        ReconLineRelation.Init();
        ReconLineRelation."Entry No." := 0;
        ReconLineRelation."GL Entry No." := GLEntryNo;
        ReconLineRelation."Document No." := DocumentNo;
        ReconLineRelation."Document Line No." := LineNo;
        ReconLineRelation."Amount Type" := AmountType;
        ReconLineRelation.Amount := Amount;
        ReconLineRelation."Posting Date" := PostingDate;
        ReconLineRelation."Posting Document No." := PostingNo;
        ReconLineRelation.Insert();
    end;

    internal procedure SetReconciledEFTMagentoUpgrade()
    var
        ConfirmLabel01: Label 'This will mark all payment entries created before the ''Reconciliation Integration Starting Date'' (%1) as ''Reconciled''. These entries will not be included in any future NP Pay Reconciliation Matching.\Please note that running this function can take a considerable amount of time.\\Are you sure you want to continue?';
        UpdatingEFTLbl: Label 'Updating EFT Transaction Request entries...\\Updating #1 Entry out of #2.';
        UpdatingMagentoLbl: Label 'Updating Magento Payment Line entries...\\Updating #1 Entry out of #2.';
        EFTUpdateDoneLbl: Label 'Successfully updated %1 EFT Transaction Requests.';
        EFTUpdateNullLbl: Label 'No EFT Transaction Requests were updated.';
        EmptyStartingDateLbl: Label 'Please specify the Reconciliation Integration Starting Date first.';
        MagentoUpdateDoneLbl: Label 'Successfully updated %1 Magento Payment Lines.';
        MagentoUpdateNullLbl: Label 'No Magento Payment Lines were updated.';
        AdyenSetup: Record "NPR Adyen Setup";
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
        if not AdyenSetup.Get() then
            exit;
        if AdyenSetup."Recon. Integr. Starting Date" = 0DT then
            Error(EmptyStartingDateLbl);
        if not Confirm(ConfirmLabel01, false, Format(AdyenSetup."Recon. Integr. Starting Date")) then
            exit;

        Clear(ProcessedEntries);
        EFTTransactionRequest.SetFilter(Finished, '<%1', AdyenSetup."Recon. Integr. Starting Date");
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
        MagentoPaymentLine.SetFilter("Date Captured", '<%1', DT2Date(AdyenSetup."Recon. Integr. Starting Date"));
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
                    Scheme[28] := 'Creation Date (AMS)';
                    SchemeColumnNumber := 28;
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

    internal procedure DefineReportType(ReportName: Text) ReportType: Enum "NPR Adyen Report Type"
    begin
        if ReportName.Contains('settlement') then begin
            if ReportName.Contains('external') then
                exit(ReportType::"External Settlement detail (C)")
            else
                exit(ReportType::"Settlement details");
        end else
            exit(ReportType::Undefined);
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
        LocalFileLbl: Label 'Local File Upload', Locked = true;
        TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        NewDocumentsList: JsonArray;
        JsonToken: JsonToken;
        NewDocumentsFilter: Text;
    begin
        Clear(WebhookRequest);
        WebhookRequest.Init();
        WebhookRequest.ID := 0;
        WebhookRequest."Report Download URL" := LocalFileLbl;

        if UploadIntoStream('Import Report', '', 'Microsoft Excel Worksheet (*.xlsx)|*.xlsx', FileName, InStr) then begin
            WebhookRequest.Validate("PSP Reference", FileName);
            WebhookRequest.Validate("Report Name", FileName);
            WebhookRequest."Report Data".CreateOutStream(OutStr, TextEncoding::UTF8);
            if (not CopyStream(OutStr, InStr)) then
                Error(FileNotUploaded);
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
                            foreach JsonToken in NewDocumentsList do begin
                                NewDocumentsFilter += JsonToken.AsValue().AsCode() + '|';
                            end;
                            ReconciliationHeader.SetFilter("Document No.", DelChr(NewDocumentsFilter, '>', '|'));
                            if ReconciliationHeader.FindSet(false) then begin
                                if NewDocumentsList.Count() > 1 then
                                    Page.Run(Page::"NPR Adyen Reconciliation List", ReconciliationHeader)
                                else
                                    Page.Run(Page::"NPR Adyen Reconciliation", ReconciliationHeader);
                            end;

                        end else begin
                            OpenReconciliationLogs(WebhookRequest);
                        end;
                    end;
                WebhookRequest."Report Type"::Undefined:
                    Error(UndefinedReportSchemeError);
            end;
        end else begin
            OpenReconciliationLogs(WebhookRequest);
        end;
    end;

    internal procedure CreateDocumentFromWebhookRequest(var WebhookRequest: Record "NPR AF Rec. Webhook Request")
    var
        ReconciliationHeader: Record "NPR Adyen Reconciliation Hdr";
        RequestIsEmptyError01: Label 'Webhook Request No. %1 has no Report Download URL. Try another one.';
        DocumentExistConfirmation: Label 'Such document already exists. Open?';
        MultipleDocumentExist: Label 'Such documents already exist. Open?';
        UndefinedReportSchemeError: Label 'Report Scheme is undefined.';
        TransactionMatching: Codeunit "NPR Adyen Trans. Matching";
        NewDocumentsList: JsonArray;
        JsonToken: JsonToken;
        NewDocumentsFilter: Text;
    begin
        if (WebhookRequest."Report Download URL" = '') then
            Error(RequestIsEmptyError01, Format(WebhookRequest.ID));

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
            if TransactionMatching.ValidateReportScheme(WebhookRequest) then begin
                case WebhookRequest."Report Type" of
                    WebhookRequest."Report Type"::"Settlement details",
                    WebhookRequest."Report Type"::"External Settlement detail (C)":
                        begin
                            NewDocumentsList := TransactionMatching.CreateSettlementDocuments(WebhookRequest, false, '');
                            if NewDocumentsList.Count() > 0 then begin
                                foreach JsonToken in NewDocumentsList do
                                    NewDocumentsFilter += JsonToken.AsValue().AsCode() + '|';
                                ReconciliationHeader.SetFilter("Document No.", DelChr(NewDocumentsFilter, '>', '|'));
                                if ReconciliationHeader.FindSet(false) then begin
                                    if NewDocumentsList.Count() > 1 then
                                        Page.Run(Page::"NPR Adyen Reconciliation List", ReconciliationHeader)
                                    else
                                        Page.Run(Page::"NPR Adyen Reconciliation", ReconciliationHeader);
                                end;

                            end else begin
                                OpenReconciliationLogs(WebhookRequest);
                            end;
                        end;
                    WebhookRequest."Report Type"::Undefined:
                        Error(UndefinedReportSchemeError);
                end;
            end else begin
                OpenReconciliationLogs(WebhookRequest);
            end;
        end;
    end;

    internal procedure EmulateWebhookRequest(ReportName: Text[100]; MerchantAccount: Text[80]; Live: Boolean; var WebhookRequest: Record "NPR AF Rec. Webhook Request")
    var
        ReportDownloadURL: Label 'https://ca-%2.adyen.com/reports/download/MerchantAccount/%1/', Locked = true;
        ReportDownloadURLString: Text;
        ErrorText01: Label 'Could not download the report - %1 %2';
        TestURL: Label 'test', Locked = true;
        LiveURL: Label 'live', Locked = true;
        HttpClient: HttpClient;
        HttpResponseMessage: HttpResponseMessage;
        HttpContent: HttpContent;
        InStr: InStream;
        OutStr: OutStream;
    begin
        InitiateAdyenManagement();

        HttpClient.DefaultRequestHeaders().Add('x-api-key', _AdyenSetup."Download Report API Key");
        if Live then
            ReportDownloadURLString := StrSubstNo(ReportDownloadURL, MerchantAccount, LiveURL)
        else
            ReportDownloadURLString := StrSubstNo(ReportDownloadURL, MerchantAccount, TestURL);

        HttpClient.Get(ReportDownloadURLString + ReportName, HttpResponseMessage);
        if (HttpResponseMessage.IsSuccessStatusCode) then begin
            WebhookRequest.Init();
            WebhookRequest.ID := 0;
            WebhookRequest."Report Download URL" := ReportDownloadURLString + ReportName;
            WebhookRequest.Validate("Report Name", ReportName);
            WebhookRequest."Report Data".CreateInStream(InStr, TextEncoding::UTF8);
            HttpContent := HttpResponseMessage.Content();
            HttpContent.ReadAs(InStr);
            WebhookRequest."Report Data".CreateOutStream(OutStr);
            CopyStream(OutStr, InStr);

            WebhookRequest.Insert();
            exit;
        end;

        Error(ErrorText01, Format(HttpResponseMessage.HttpStatusCode()), HttpResponseMessage.ReasonPhrase());
    end;
    #endregion

    #region General Web Service
    internal procedure ImportWebhook(json: Text): Boolean
    var
        AdyenWebhook: Record "NPR Adyen Webhook";
        JsonRequest: JsonObject;
        LogType: Enum "NPR Adyen Webhook Log Type";
        SuccessfullyReceivedAndLoggedLbl: Label 'Web Service has successfully received and logged a Webhook Request.';
        ErrorLbl: Label 'Web Service could not successfully log a Webhook Request because of some issue: %1.';
        ReferenceValidationErrorLbl: Label 'Could not validate Webhook Reference.';
    begin
        if not ValidateWebhookReference(json) then begin
            CreateGeneralLog(LogType::Error, false, StrSubstNo(ErrorLbl, ReferenceValidationErrorLbl), AdyenWebhook."Entry No.");
            exit(false);
        end;

        AdyenWebhook.Init();
        AdyenWebhook."Entry No." := 0;
        JsonRequest.ReadFrom(json);
        if (not RecordWebhookData(JsonRequest, AdyenWebhook)) then begin
            AdyenWebhook.Success := false;
        end;
        // TODO ValidateHMAC
        // TODO Retention Policy
        AdyenWebhook.Insert();

        if AdyenWebhook.Success then begin
            CreateGeneralLog(LogType::Register, true, SuccessfullyReceivedAndLoggedLbl, AdyenWebhook."Entry No.");
        end else
            CreateGeneralLog(LogType::Error, false, StrSubstNo(ErrorLbl, GetLastErrorText()), AdyenWebhook."Entry No.");

        exit(AdyenWebhook.Success);
    end;

    internal procedure ManualMatchingAllowed(RecLine: Record "NPR Adyen Recon. Line"): Boolean
    begin
        case RecLine.Status of
            RecLine.Status::"Failed to Match":
                exit(true);
            RecLine.Status::Matched,
            RecLine.Status::"Failed to Post":
                exit(RecLine."Matched Manually");
        end;
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
        PaymentLinkId: Code[20];
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
        PaymentLinkId := GetPaymentLinkID(JsonContent);

        AdyenWebhook."Webhook Data".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(Token.AsValue().AsText());
        AdyenWebhook.Live := Live;
        AdyenWebhook."Event Code" := Enum::"NPR Adyen Webhook Event Code".FromInteger(EventCodeEnum.Ordinals.Get(EventCodeEnum.Names.IndexOf(EventCode)));
        AdyenWebhook."Event Date" := EventDate;
        AdyenWebhook."Merchant Account Name" := MerchantAccountName;
        If PaymentLinkId <> '' then
            AdyenWebhook."PSP Reference" := PaymentLinkId
        else
            AdyenWebhook."PSP Reference" := PSPReference;
        AdyenWebhook.Success := true;
        AdyenWebhook."Webhook Reference" := WebhookReference;
        GetAdyenWebhookReqType(AdyenWebhook, PaymentLinkId, PSPReference)
    end;

    local procedure GetAdyenWebhookReqType(var AdyenWebhook: Record "NPR Adyen Webhook"; PaymentLinkId: Code[20]; PSPReference: Text[100])
    var
        SettlementDetailsLbl: Label 'settlement_details', Locked = true;
        SettlementExtDetailsLbl: Label 'external_settlement_details', Locked = true;
    begin
        case AdyenWebhook."Event Code" of
            AdyenWebhook."Event Code"::REPORT_AVAILABLE:
                begin
                    if (StrPos(PSPReference, SettlementDetailsLbl) > 0) or (StrPos(PSPReference, SettlementExtDetailsLbl) > 0) then
                        AdyenWebhook."Webhook Type" := AdyenWebhook."Webhook Type"::Reconciliation;
                end;
            AdyenWebhook."Event Code"::AUTHORISATION:
                begin
                    If PaymentLinkId <> '' then begin
                        AdyenWebhook."Webhook Type" := AdyenWebhook."Webhook Type"::"Pay by Link";
                        AdyenWebhook."PSP Reference" := PaymentLinkId;
                    end;
                end;
        end;
    end;

    local procedure GetPaymentLinkID(JsonContent: JsonObject) PaymentLinkId: Code[20]
    var
        ContentToken: JsonToken;
        JsonValueToken: JsonToken;
    begin
        if JsonContent.Get('additionalData', ContentToken) then
            if ContentToken.AsObject().Get('paymentLinkId', JsonValueToken) then
                PaymentLinkId := CopyStr(JsonValueToken.AsValue().AsText(), 1, MaxStrLen(PaymentLinkId));
    end;
    #endregion

    var
        _AdyenSetup: Record "NPR Adyen Setup";
        _ImportedWebhooks: Integer;
}
