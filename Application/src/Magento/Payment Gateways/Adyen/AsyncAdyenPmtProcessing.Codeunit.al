codeunit 6151179 "NPR Async Adyen Pmt Processing"
{
    Access = Internal;

    var
        _WebUser: Text[256];
        [NonDebuggable]
        _WebPassword: Text[2048];
        [NonDebuggable]
        _BasicAuthCollected: Boolean;
        _BCBaseURL: Text[2048];

    internal procedure EnsureCaptureWebhooks()
    var
        EventCodes: List of [Text[2048]];
    begin
        EventCodes.Add('CAPTURE');
        EventCodes.Add('CAPTURE_FAILED');
        EnsureWebhooksForEvents(EventCodes);
    end;

    local procedure EnsureWebhooksForEvents(EventCodes: List of [Text[2048]])
    var
        MerchantAccount: Record "NPR Adyen Merchant Account";
        AdyenSetup: Record "NPR Adyen Setup";
        AdyenManagement: Codeunit "NPR Adyen Management";
        ConfirmManagement: Codeunit "Confirm Management";
        CaptureMerchants: List of [Text[50]];
        MissingMerchants: Text;
        ContinueQuestion: Text;
        RefreshMerchantList: Boolean;
        ManagementApiKeyErr: Label '%1 must have a value in %2.', Comment = '%1 = Management API Key field caption, %2 = NP Pay Setup table caption';
        NoMerchantsErr: Label 'No %1 records were found. Configure %2 first.', Comment = '%1 = NP Pay Merchant Account table caption, %2 = NP Pay Setup table caption';
        MerchantListRefreshErr: Label 'Could not refresh %1 from Adyen.', Comment = '%1 = NP Pay Merchant Account table caption';
        RefreshMerchantListQst: Label 'The following merchants used by Adyen payment gateways with capture enabled are not in %1: %2. Do you want to refresh %1 from Adyen first?', Comment = '%1 = NP Pay Merchant Account table caption, %2 = merchant names separated by commas';
        MerchantsNotListedQst: Label 'The following merchants used by Adyen payment gateways with capture enabled are not in %1: %2. They are not visible to the %3 in %4, so no capture webhook can be set up for them, and their captures stay pending until they are reset. Do you want to continue?', Comment = '%1 = NP Pay Merchant Account table caption, %2 = merchant names separated by commas, %3 = Management API Key field caption, %4 = NP Pay Setup table caption';
        MerchantsNotInListQst: Label 'The following merchants used by Adyen payment gateways with capture enabled are not in %1: %2. No capture webhook is set up for them, and their captures stay pending until they are reset. Do you want to continue?', Comment = '%1 = NP Pay Merchant Account table caption, %2 = merchant names separated by commas';
        EnsuredWebhooksMsg: Label 'Webhooks have been configured for all merchants.';
    begin
        AdyenSetup.Get();
        if not AdyenSetup.HasManagementAPIKey() then
            Error(ManagementApiKeyErr, AdyenSetup.FieldCaption("Management API Key Token"), AdyenSetup.TableCaption);

        // Every question and the credential prompt come before any change at Adyen.
        // The merchant list refresh is local and stays uncommitted until the last answer, so declining rolls it back.
        CollectCaptureMerchants(CaptureMerchants);
        RefreshMerchantList := MerchantAccount.IsEmpty();
        if not RefreshMerchantList then begin
            MissingMerchants := GetMerchantsNotListed(CaptureMerchants);
            if MissingMerchants <> '' then
                RefreshMerchantList := ConfirmManagement.GetResponseOrDefault(StrSubstNo(RefreshMerchantListQst, MerchantAccount.TableCaption, MissingMerchants), false);
        end;

        // The refresh can add merchants that have no webhook yet, so credentials are collected up front.
        if RefreshMerchantList and ShouldCollectBasicAuth() then
            GetBasicAuthCredentials()
        else
            PrimeBasicAuthForEvents(EventCodes);

        if RefreshMerchantList then
            if not AdyenManagement.UpdateMerchantList(0) then
                Error(MerchantListRefreshErr, MerchantAccount.TableCaption);

        if MerchantAccount.IsEmpty() then
            Error(NoMerchantsErr, MerchantAccount.TableCaption, AdyenSetup.TableCaption);

        MissingMerchants := GetMerchantsNotListed(CaptureMerchants);
        if MissingMerchants <> '' then begin
            // Only a refresh in this call shows that Adyen does not list the merchant for this key.
            if RefreshMerchantList then
                ContinueQuestion := StrSubstNo(MerchantsNotListedQst, MerchantAccount.TableCaption, MissingMerchants, AdyenSetup.FieldCaption("Management API Key Token"), AdyenSetup.TableCaption)
            else
                ContinueQuestion := StrSubstNo(MerchantsNotInListQst, MerchantAccount.TableCaption, MissingMerchants);
            if not ConfirmManagement.GetResponseOrDefault(ContinueQuestion, false) then
                Error('');
        end;

        MerchantAccount.FindSet();
        repeat
            EnsureWebhooksOnMerchant(EventCodes, MerchantAccount.Name);
        until MerchantAccount.Next() = 0;

        Message(EnsuredWebhooksMsg);
    end;

    local procedure CollectCaptureMerchants(var CaptureMerchants: List of [Text[50]])
    var
        PaymentGateway: Record "NPR Magento Payment Gateway";
        PGAdyenSetup: Record "NPR PG Adyen Setup";
        MerchantKeys: List of [Text];
    begin
        Clear(CaptureMerchants);
        PaymentGateway.SetRange("Integration Type", Enum::"NPR PG Integrations"::Adyen);
        PaymentGateway.SetRange("Enable Capture", true);
        PaymentGateway.SetLoadFields(Code);
        if not PaymentGateway.FindSet() then
            exit;

        PGAdyenSetup.SetLoadFields("Merchant Name");
        repeat
            if PGAdyenSetup.Get(PaymentGateway.Code) then
                if PGAdyenSetup."Merchant Name" <> '' then
                    // Names differing only in case are one merchant, as in the merchant account key lookup.
                    if not MerchantKeys.Contains(UpperCase(PGAdyenSetup."Merchant Name")) then begin
                        MerchantKeys.Add(UpperCase(PGAdyenSetup."Merchant Name"));
                        CaptureMerchants.Add(PGAdyenSetup."Merchant Name");
                    end;
        until PaymentGateway.Next() = 0;
    end;

    local procedure GetMerchantsNotListed(CaptureMerchants: List of [Text[50]]) MissingMerchants: Text
    var
        MerchantAccount: Record "NPR Adyen Merchant Account";
        MerchantName: Text[50];
    begin
        MerchantAccount.SetLoadFields(Name);
        foreach MerchantName in CaptureMerchants do
            if not MerchantAccount.Get(MerchantName) then begin
                if MissingMerchants <> '' then
                    MissingMerchants += ', ';
                MissingMerchants += MerchantName;
            end;
    end;

    local procedure PrimeBasicAuthForEvents(EventCodes: List of [Text[2048]])
    var
        EventCode: Text[2048];
    begin
        if ShouldCollectBasicAuth() then
            foreach EventCode in EventCodes do
                if IsWebhookMissingForAnyMerchant(EventCode) then begin
                    GetBasicAuthCredentials();
                    exit;
                end;
    end;

    local procedure IsWebhookMissingForAnyMerchant(EventCode: Text[2048]): Boolean
    var
        MerchantAccount: Record "NPR Adyen Merchant Account";
        WebhookSetup: Record "NPR Adyen Webhook Setup";
    begin
        if not MerchantAccount.FindSet() then
            exit(true);

        repeat
            if not FindWebhookForEventOnMerchant(EventCode, MerchantAccount.Name, WebhookSetup) then
                exit(true);
        until MerchantAccount.Next() = 0;

        exit(false);
    end;

    local procedure ShouldCollectBasicAuth(): Boolean
    begin
        if not IsCraneEnvironment() then
            exit(false);

        if _BasicAuthCollected then
            exit(false);

        exit(true);
    end;

    [NonDebuggable]
    local procedure EnsureWebhooksOnMerchant(EventCodes: List of [Text[2048]]; MerchantName: Text[80])
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary;
        AdyenManagement: Codeunit "NPR Adyen Management";
        EventCode: Text[2048];
        MissingFilter: Text;
        WebhooksRead: Boolean;
    begin
        foreach EventCode in EventCodes do
            if FindWebhookForEventOnMerchant(EventCode, MerchantName, WebhookSetup) then
                if not WebhookSetup.Active then begin
                    WebhookSetup.Active := true;
                    WebhookSetup.Modify(false);
                    AdyenManagement.ModifyWebhook(WebhookSetup);
                end;

        MissingFilter := GetMissingEventsFilter(MerchantName, EventCodes);
        if MissingFilter = '' then
            exit;

        if IsCraneEnvironment() then begin
            GetBasicAuthCredentials();
            WebhooksRead := AdyenManagement.GetCurrentEnvironmentWebhooks(MerchantName, CopyStr(_WebUser, 1, 100), CopyStr(_WebPassword, 1, 100), _BCBaseURL, TempWebhookSetup);
        end else
            WebhooksRead := AdyenManagement.GetCurrentEnvironmentWebhooks(MerchantName, TempWebhookSetup);

        if WebhooksRead then
            if AdoptCoveringWebhooks(MerchantName, EventCodes, TempWebhookSetup) then
                MissingFilter := GetMissingEventsFilter(MerchantName, EventCodes);

        if MissingFilter <> '' then
            CreateWebhookOnMerchant(MissingFilter, MerchantName);
    end;

    /// <summary>
    /// Returns the events that no webhook on the merchant covers, joined with | in list order.
    /// </summary>
    internal procedure GetMissingEventsFilter(MerchantName: Text[80]; EventCodes: List of [Text[2048]]) MissingFilter: Text
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        EventCode: Text[2048];
    begin
        foreach EventCode in EventCodes do
            if not FindWebhookForEventOnMerchant(EventCode, MerchantName, WebhookSetup) then begin
                if MissingFilter <> '' then
                    MissingFilter += '|';
                MissingFilter += EventCode;
            end;
    end;

    /// <summary>
    /// Inserts webhooks from the buffer that already exist at Adyen and cover an event still missing on the merchant,
    /// so a repeated enable does not create them again. The buffer must hold only this environment's webhooks.
    /// Adopted rows get a blank password and are not sent back to Adyen. Returns true if any row was adopted.
    /// </summary>
    [NonDebuggable]
    internal procedure AdoptCoveringWebhooks(MerchantName: Text[80]; EventCodes: List of [Text[2048]]; var TempWebhookSetup: Record "NPR Adyen Webhook Setup" temporary) Adopted: Boolean
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        NewWebhookSetup: Record "NPR Adyen Webhook Setup";
        EventCode: Text[2048];
        CoversMissingEvent: Boolean;
    begin
        if GetMissingEventsFilter(MerchantName, EventCodes) = '' then
            exit(false);

        TempWebhookSetup.Reset();
        TempWebhookSetup.SetRange(Type, TempWebhookSetup.Type::standard);
        TempWebhookSetup.SetRange(Active, true);
        TempWebhookSetup.SetFilter(ID, '<>%1', '');
        if not TempWebhookSetup.FindSet() then
            exit(false);

        repeat
            WebhookSetup.Reset();
            WebhookSetup.SetRange(ID, TempWebhookSetup.ID);
            if WebhookSetup.IsEmpty() then begin
                CoversMissingEvent := false;
                foreach EventCode in EventCodes do
                    if not CoversMissingEvent then
                        if EventFilterIncludesEvent(TempWebhookSetup."Include Events Filter", EventCode) then
                            CoversMissingEvent := not FindWebhookForEventOnMerchant(EventCode, MerchantName, WebhookSetup);

                if CoversMissingEvent then begin
                    NewWebhookSetup.Init();
                    NewWebhookSetup.TransferFields(TempWebhookSetup);
                    NewWebhookSetup."Primary Key" := 0;
                    NewWebhookSetup."Merchant Account" := MerchantName;
                    NewWebhookSetup."Web Service Password" := '';
                    NewWebhookSetup.Insert();
                    Adopted := true;
                    if GetMissingEventsFilter(MerchantName, EventCodes) = '' then
                        exit(true);
                end;
            end;
        until TempWebhookSetup.Next() = 0;
    end;

    [NonDebuggable]
    local procedure CreateWebhookOnMerchant(MissingFilter: Text; MerchantName: Text[80])
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        AdyenManagement: Codeunit "NPR Adyen Management";
        WebhookCreateFailedErr: Label 'Failed to create the Adyen webhook for events %1 on merchant %2.', Comment = '%1 = event codes separated by |, %2 = merchant account name';
    begin
        WebhookSetup.Init();
        WebhookSetup."Primary Key" := 0;
        WebhookSetup."Merchant Account" := MerchantName;
        WebhookSetup.Type := Enum::"NPR Adyen Webhook Type"::standard;
        WebhookSetup."Include Events Filter" := CopyStr(MissingFilter, 1, MaxStrLen(WebhookSetup."Include Events Filter"));
        WebhookSetup.Active := true;
        if IsCraneEnvironment() then begin
            GetBasicAuthCredentials();
            WebhookSetup."Web Service Security" := WebhookSetup."Web Service Security"::"Basic authentication";
            WebhookSetup."Web Service User" := CopyStr(_WebUser, 1, MaxStrLen(WebhookSetup."Web Service User"));
            WebhookSetup."Web Service Password" := CopyStr(_WebPassword, 1, MaxStrLen(WebhookSetup."Web Service Password"));
        end;
        WebhookSetup.Insert();
        if IsCraneEnvironment() then
            AdyenManagement.SuggestAFWebServiceURL(WebhookSetup, CopyStr(_WebUser, 1, 100), CopyStr(_WebPassword, 1, 100), _BCBaseURL)
        else
            AdyenManagement.SuggestAFWebServiceURL(WebhookSetup);
        if not AdyenManagement.CreateWebhook(WebhookSetup) then
            Error(WebhookCreateFailedErr, MissingFilter, MerchantName);
    end;

    /// <summary>
    /// Finds an active webhook on the merchant that already delivers the event. Otherwise finds an inactive webhook
    /// created for exactly that event or for CAPTURE and CAPTURE_FAILED together, which the caller reactivates.
    /// Inactive webhooks with other events or an empty filter are never returned, so reactivating one cannot re-enable
    /// events an administrator switched off. An inactive webhook without a stored password is skipped on Crane or when
    /// it uses basic authentication, because reactivating it would send a blank password to Adyen.
    /// </summary>
    local procedure FindWebhookForEventOnMerchant(EventCode: Text[2048]; MerchantName: Text[80]; var WebhookSetup: Record "NPR Adyen Webhook Setup"): Boolean
    var
        CaptureEventsTxt: Label 'CAPTURE|CAPTURE_FAILED', Locked = true;
        CaptureEventsReversedTxt: Label 'CAPTURE_FAILED|CAPTURE', Locked = true;
    begin
        WebhookSetup.Reset();
        WebhookSetup.SetRange(Type, WebhookSetup.Type::standard);
        WebhookSetup.SetRange("Merchant Account", MerchantName);
        WebhookSetup.SetFilter(ID, '<>%1', '');
        WebhookSetup.SetRange(Active, true);
        if WebhookSetup.FindSet() then
            repeat
                if EventFilterIncludesEvent(WebhookSetup."Include Events Filter", EventCode) then
                    exit(true);
            until WebhookSetup.Next() = 0;

        WebhookSetup.SetRange(Active, false);
        WebhookSetup.SetFilter("Include Events Filter", '%1|%2|%3', EventCode, CaptureEventsTxt, CaptureEventsReversedTxt);
        if WebhookSetup.FindSet() then
            repeat
                if CanReactivateWebhook(WebhookSetup, IsCraneEnvironment()) then
                    exit(true);
            until WebhookSetup.Next() = 0;
        exit(false);
    end;

    /// <summary>
    /// True when reactivating the inactive webhook will not send a blank password to Adyen: it has a stored password,
    /// or it is neither on Crane nor using basic authentication.
    /// </summary>
    [NonDebuggable]
    internal procedure CanReactivateWebhook(WebhookSetup: Record "NPR Adyen Webhook Setup"; IsCrane: Boolean): Boolean
    begin
        if WebhookSetup."Web Service Password" <> '' then
            exit(true);
        exit(not (IsCrane or (WebhookSetup."Web Service Security" = WebhookSetup."Web Service Security"::"Basic authentication")));
    end;

    /// <summary>
    /// An empty filter means the standard webhook delivers its default events, which include CAPTURE and CAPTURE_FAILED.
    /// Otherwise the filter is evaluated the same way ModifyWebhook applies it, so lists, the ranges the setup card writes,
    /// and wildcards all count. A filter that cannot be applied does not cover the event.
    /// </summary>
    local procedure EventFilterIncludesEvent(IncludeEventsFilter: Text; EventCode: Text): Boolean
    var
        Included: Boolean;
    begin
        if IncludeEventsFilter.Trim() = '' then
            exit(true);
        if not TryFilterIncludesEvent(IncludeEventsFilter, EventCode, Included) then
            exit(false);
        exit(Included);
    end;

    [TryFunction]
    local procedure TryFilterIncludesEvent(IncludeEventsFilter: Text; EventCode: Text; var Included: Boolean)
    var
        TempWebhookEventCode: Record "NPR Adyen Webhook Event Code" temporary;
    begin
        TempWebhookEventCode.Init();
        TempWebhookEventCode."Event Code" := CopyStr(EventCode, 1, MaxStrLen(TempWebhookEventCode."Event Code"));
        TempWebhookEventCode.Insert();
        TempWebhookEventCode.SetFilter("Event Code", IncludeEventsFilter);
        Included := not TempWebhookEventCode.IsEmpty();
    end;

    [NonDebuggable]
    local procedure GetBasicAuthCredentials()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        OnPremWebhookInput: Report "NPR Adyen OnPrem Webhook Input";
        CredentialsRequiredErr: Label '%1 and %2 are required to create the webhook on this environment.', Comment = '%1 = Web Service User field caption, %2 = Web Service Password field caption';
    begin
        if not _BasicAuthCollected then begin
            if OnPremWebhookInput.RunRequestPage() = '' then
                Error(CredentialsRequiredErr, WebhookSetup.FieldCaption("Web Service User"), WebhookSetup.FieldCaption("Web Service Password"));
            _WebUser := OnPremWebhookInput.GetUserName();
            _WebPassword := OnPremWebhookInput.GetPassword();
            _BCBaseURL := OnPremWebhookInput.GetBCBaseURL();
            if (_WebUser = '') or (_WebPassword = '') then
                Error(CredentialsRequiredErr, WebhookSetup.FieldCaption("Web Service User"), WebhookSetup.FieldCaption("Web Service Password"));
            _BasicAuthCollected := true;
        end;
    end;

    /// <summary>
    /// Supplies the web service credentials and BC base URL so the on-prem prompt is not shown. Used by tests.
    /// </summary>
    [NonDebuggable]
    internal procedure SetBasicAuthCredentials(WebUserParam: Text[100]; WebPasswordParam: Text[100]; BCBaseURLParam: Text[2048])
    begin
        _WebUser := WebUserParam;
        _WebPassword := WebPasswordParam;
        _BCBaseURL := BCBaseURLParam;
        _BasicAuthCollected := (WebUserParam <> '') and (WebPasswordParam <> '');
    end;

    internal procedure IsCraneEnvironment(): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
    begin
        exit(not EnvironmentInformation.IsSaaSInfrastructure());
    end;
}
