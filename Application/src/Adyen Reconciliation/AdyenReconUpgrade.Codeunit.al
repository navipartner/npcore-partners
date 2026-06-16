codeunit 6184908 "NPR Adyen Recon. Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;

    trigger OnUpgradePerCompany()
    begin
        UpdatePSPReferenceForEFTTrans();
        UpdateAdyenSetupCompanyID();
        UpdateAdyenReconLinePostingAllowed();
        UpdateAdyenReconciliationStatus();
        UpdateAdyenReconciliationDocumentProcessingStatus();
        UpdateAdyenReconciliationRelation();
        UpdateManuallyMatchedLines();
        FixMagentoPaymentLines();
        UpgradeMerchantAccountSetups();
        FixUnreconciledMagentoRefundPaymentLines();
        RecreateForeignCurrencyDocuments();
        FixDeprecatedWebhookURL();
    end;

    local procedure UpdatePSPReferenceForEFTTrans()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        UpgradeStep := 'UpdatePSPReferenceForEFTTrans';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        EFTTransactionRequest.Reset();
        AdyenManagement.SetEFTAdyenIntegrationFilter(EFTTransactionRequest);
        if EFTTransactionRequest.FindSet(true) then
            repeat
                if EFTTransactionRequest."External Transaction ID".Split('.').Count = 2 then begin
                    EFTTransactionRequest."PSP Reference" := CopyStr(EFTTransactionRequest."External Transaction ID".Split('.').Get(2), 1, MaxStrLen(EFTTransactionRequest."PSP Reference"));
                    EFTTransactionRequest.Modify();
                end;
            until EFTTransactionRequest.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateAdyenSetupCompanyID()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        AdyenSetupCompanyID: Record "NPR Adyen Setup";
    begin
        UpgradeStep := 'UpdateAdyenSetupCompanyID';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if not AdyenSetup.Get() then
            exit;

        AdyenSetupCompanyID.Init();
        if AdyenSetup."Company ID" = AdyenSetupCompanyID."Company ID" then
            exit;

        AdyenSetup."Company ID" := AdyenSetupCompanyID."Company ID";
        AdyenSetup.Modify(false);

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateAdyenReconLinePostingAllowed()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        AdyenReconLine: Record "NPR Adyen Recon. Line";
    begin
        UpgradeStep := 'UpdateAdyenReconLinePostingAllowed';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if not AdyenSetup.Get() then
            exit;

        AdyenReconLine.Reset();
        AdyenReconLine.SetRange("Posting allowed", false);
        if not AdyenSetup."Post Chargebacks Automatically" then
            AdyenReconLine.SetFilter("Transaction Type", '<>%1&<>%2&<>%3', AdyenReconLine."Transaction Type"::Chargeback, AdyenReconLine."Transaction Type"::ChargebackExternallyWithInfo, AdyenReconLine."Transaction Type"::SecondChargeback);
        AdyenReconLine.ModifyAll("Posting allowed", true);

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateAdyenReconciliationStatus()
    var
        ReconHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconHeader2: Record "NPR Adyen Reconciliation Hdr";
        ReconLine: Record "NPR Adyen Recon. Line";
    begin
        UpgradeStep := 'UpdateAdyenReconciliationStatus';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if ReconHeader.FindSet() then
            repeat
                ReconHeader2 := ReconHeader;
                ReconLine.Reset();
                ReconLine.SetRange("Document No.", ReconHeader2."Document No.");
                ReconLine.SetFilter(Status, '<>%1&<>%2&<>%3', ReconLine.Status::Matched, ReconLine.Status::"Matched Manually", ReconLine.Status::"Not to be Matched");
                if ReconLine.IsEmpty() then begin
                    ReconHeader2.Status := ReconHeader2.Status::Matched;
                    ReconHeader2.Modify();
                end else begin
                    ReconLine.SetFilter(Status, '<>%1&<>%2&<>%3', ReconLine.Status::Posted, ReconLine.Status::"Not to be Posted", ReconLine.Status::"Posted Failed to Match");
                    if ReconLine.IsEmpty() then begin
                        ReconHeader2.Status := ReconHeader2.Status::Posted;
                        ReconHeader2.Modify();
                    end;
                end;
            until ReconHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateAdyenReconciliationDocumentProcessingStatus()
    var
        ReconHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconHeader2: Record "NPR Adyen Reconciliation Hdr";
        ReconLine: Record "NPR Adyen Recon. Line";
    begin
        UpgradeStep := 'UpdateAdyenReconciliationDocumentProcessingStatus';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if ReconHeader.FindSet() then
            repeat
                ReconLine.SetRange("Document No.", ReconHeader2."Document No.");
                ReconLine.SetFilter(Status, '%1|%2', ReconLine.Status::"Failed to Match", ReconLine.Status::"Failed to Post");
                if not ReconLine.IsEmpty() then begin
                    ReconHeader2 := ReconHeader;
                    ReconHeader2."Failed Lines Exist" := true;
                    ReconHeader2.Modify();
                end;
            until ReconHeader.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateAdyenReconciliationRelation()
    var
        OldReconRelation: Record "NPR Adyen Recon. Line Relation";
        NewReconRelation: Record "NPR Adyen Recons.Line Relation";
    begin
        UpgradeStep := 'UpdateAdyenReconciliationRelation';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if OldReconRelation.FindSet() then begin
            repeat
                NewReconRelation.Init();
                NewReconRelation."Entry No." := 0;
                NewReconRelation."GL Entry No." := OldReconRelation."GL Entry No.";
                NewReconRelation."Document No." := OldReconRelation."Document No.";
                NewReconRelation."Document Line No." := OldReconRelation."Document Line No.";
                NewReconRelation."Amount Type" := OldReconRelation."Amount Type";
                NewReconRelation.Amount := OldReconRelation.Amount;
                NewReconRelation."Posting Date" := OldReconRelation."Posting Date";
                NewReconRelation."Posting Document No." := OldReconRelation."Posting Document No.";
                NewReconRelation.Insert();
            until OldReconRelation.Next() = 0;
            OldReconRelation.DeleteAll();
        end;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateManuallyMatchedLines()
    var
        RecLine: Record "NPR Adyen Recon. Line";
    begin
        UpgradeStep := 'UpdateManuallyMatchedLines';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if RecLine.FindSet(true) then
            repeat
                if RecLine.Status = RecLine.Status::"Matched Manually" then begin
                    RecLine.Status := RecLine.Status::Matched;
                    RecLine."Matched Manually" := true;
                    RecLine.Modify();
                end;
            until RecLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure FixMagentoPaymentLines()
    var
        ReconLine: Record "NPR Adyen Recon. Line";
        ReconHeader: Record "NPR Adyen Reconciliation Hdr";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
    begin
        UpgradeStep := 'FixMagentoPaymentLines';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        // Mark all Magento Payments included in the already imported Reconciliaiton documents as not reconciled 
        ReconLine.Reset();
        ReconLine.SetFilter(Status, '<>%1&<>%2&<>%3', ReconLine.Status::"Not to be Posted", ReconLine.Status::Posted, ReconLine.Status::"Posted Failed to Match");
        ReconLine.SetFilter("Merchant Account", '%1', '*Ecom*');
        if ReconLine.FindSet(true) then
            repeat
                MagentoPaymentLine.Reset();
                MagentoPaymentLine.SetRange("Transaction ID", ReconLine."PSP Reference");
                MagentoPaymentLine.SetRange(Amount, Abs(ReconLine."Amount (LCY)"));
                MagentoPaymentLine.SetRange(Reconciled, true);
                if ReconLine."Transaction Type" = ReconLine."Transaction Type"::Refunded then
                    MagentoPaymentLine.SetFilter("Date Refunded", '<>%1', 0D)
                else
                    MagentoPaymentLine.SetRange("Date Refunded", 0D);

                if MagentoPaymentLine.FindFirst() then begin
                    MagentoPaymentLine.Reconciled := false;
                    MagentoPaymentLine."Reconciliation Date" := 0D;
                    MagentoPaymentLine.Modify();
                    ReconLine.Status := ReconLine.Status::"Failed to Match";
                    ReconLine.Modify();
                    if ReconHeader.Get(ReconLine."Document No.") then
                        if ReconHeader.Status <> ReconHeader.Status::Unmatched then begin
                            ReconHeader.Status := ReconHeader.Status::Unmatched;
                            ReconHeader.Modify();
                        end;
                end;
            until ReconLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeMerchantAccountSetups()
    var
        MerchantSetup: Record "NPR Adyen Merchant Setup";
        AdyenManagement: Codeunit "NPR Adyen Management";
    begin
        UpgradeStep := 'UpgradeMerchantAccountSetups';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if MerchantSetup.FindSet() then
            repeat
                AdyenManagement.InitSourceCodeAndDimPriorities(MerchantSetup);
                MerchantSetup.Modify();
            until MerchantSetup.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure FixUnreconciledMagentoRefundPaymentLines()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        MagentoPaymentLine: Record "NPR Magento Payment Line";
        MagentoPaymentLine2: Record "NPR Magento Payment Line";
        ReconHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconLine: Record "NPR Adyen Recon. Line";
        AdyenTrMatching: Codeunit "NPR Adyen Trans. Matching";
    begin
        UpgradeStep := 'FixUnreconciledMagentoRefundPaymentLines';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if not AdyenSetup.Get() then
            AdyenSetup.Init();
        MagentoPaymentLine.SetRange(Reconciled, true);
        if AdyenSetup."Recon. Integr. Starting Date" <> 0DT then
            MagentoPaymentLine.SetFilter("Date Captured", '>=%1', DT2Date(AdyenSetup."Recon. Integr. Starting Date"));
        if MagentoPaymentLine.FindSet() then
            repeat
                ReconLine.SetRange("Matching Entry System ID", MagentoPaymentLine.SystemId);
                if ReconLine.IsEmpty() then begin
                    MagentoPaymentLine2 := MagentoPaymentLine;
                    MagentoPaymentLine2.Reconciled := false;
                    MagentoPaymentLine2."Reconciliation Date" := 0D;
                    MagentoPaymentLine2.Modify();
                end;
            until MagentoPaymentLine.Next() = 0;

        ReconLine.Reset();
        MagentoPaymentLine.Reset();
        ReconLine.SetRange(Status, ReconLine.Status::"Failed to Match");
        ReconLine.SetFilter("Merchant Account", '%1', '*Ecom*');
        ReconLine.SetFilter("PSP Reference", '<>%1', '');
        ReconLine.SetFilter("Transaction Type", '%1|%2|%3',
            ReconLine."Transaction Type"::Refunded,
            ReconLine."Transaction Type"::RefundedExternallyWithInfo,
            ReconLine."Transaction Type"::RefundedReversed);
        if ReconLine.FindSet() then
            repeat
                MagentoPaymentLine.SetRange("Transaction ID", ReconLine."PSP Reference");
                MagentoPaymentLine.SetFilter("Date Refunded", '<>%1', 0D);
                MagentoPaymentLine.SetRange(Reconciled, true);
                if MagentoPaymentLine.FindFirst() then begin
                    MagentoPaymentLine.Reconciled := false;
                    MagentoPaymentLine."Reconciliation Date" := 0D;
                    MagentoPaymentLine.Modify();

                    ReconHeader.Get(ReconLine."Document No.");
                    AdyenTrMatching.MatchEntries(ReconHeader);
                end;
            until ReconLine.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure RecreateForeignCurrencyDocuments()
    var
        ReconHeader: Record "NPR Adyen Reconciliation Hdr";
        ReconHeader2: Record "NPR Adyen Reconciliation Hdr";
        ReconLine: Record "NPR Adyen Recon. Line";
        MerchantAccount: Record "NPR Adyen Merchant Account";
        AdyenTransMatching: Codeunit "NPR Adyen Trans. Matching";
        MerchantLocalCurrency: Code[10];
    begin
        UpgradeStep := 'RecreateForeignCurrencyDocuments';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if MerchantAccount.FindSet() then
            repeat
                ReconHeader.SetRange("Merchant Account", MerchantAccount.Name);
                if ReconHeader.FindFirst() then begin
                    MerchantLocalCurrency := ReconHeader."Adyen Acc. Currency Code";
                    ReconLine.SetRange("Merchant Account", ReconHeader."Merchant Account");
                    ReconLine.SetFilter("Transaction Currency Code", '<>%1&<>%2', MerchantLocalCurrency, '');
                    ReconLine.SetFilter(Status, '<>%1&<>%2', ReconLine.Status::Posted, ReconLine.Status::"Posted Failed to Match");
                    if ReconLine.FindSet() then
                        repeat
                            if ReconHeader2."Document No." <> ReconLine."Document No." then
                                if ReconHeader2.Get(ReconLine."Document No.") then begin
                                    if AdyenTransMatching.RecreateDocumentEntries(ReconHeader2) > 0 then
                                        if AdyenTransMatching.MatchEntries(ReconHeader2) > 0 then
                                            AdyenTransMatching.ReconcileEntries(ReconHeader2);
                                end;
                        until ReconLine.Next() = 0;
                end;
            until MerchantAccount.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure FixDeprecatedWebhookURL()
    var
        WebhookSetup: Record "NPR Adyen Webhook Setup";
        WebhookSetup2: Record "NPR Adyen Webhook Setup";
        EnvironmentInformation: Codeunit "Environment Information";
        AdyenManagement: Codeunit "NPR Adyen Management";
        NewWebServiceURL: Text;
        FailedWebhooks: Text;
    begin
        UpgradeStep := 'FixDeprecatedWebhookURL';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Adyen Recon. Upgrade', UpgradeStep);

        if EnvironmentInformation.IsOnPrem() then begin
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        WebhookSetup.SetFilter(ID, '<>%1', '');
        WebhookSetup.SetFilter("Web Service URL", StrSubstNo('@*%1*', 'nppaywebhook.azurewebsites.net'));
        if WebhookSetup.FindSet() then begin
            AdyenManagement.RefreshWebhookEventCodes();
            repeat
                if IsDeprecatedWebhookForCurrentEnvironment(WebhookSetup."Web Service URL") then begin
                    WebhookSetup2.Get(WebhookSetup."Primary Key");
                    NewWebServiceURL := AdyenManagement.BuildAFWebServiceURL(WebhookSetup2);
                    WebhookSetup2."Web Service URL" := CopyStr(NewWebServiceURL, 1, MaxStrLen(WebhookSetup2."Web Service URL"));
                    if TryPushWebhookToAdyen(WebhookSetup2) then begin
                        WebhookSetup2.Modify(false);
                        Commit();
                    end else begin
                        FailedWebhooks += StrSubstNo('%1 (%2); ', WebhookSetup2.ID, GetLastErrorText());
                        ClearLastError();
                    end;
                end;
            until WebhookSetup.Next() = 0;
        end;

        if FailedWebhooks <> '' then
            LogMessageStopwatch.SetError(StrSubstNo('Could not resolve the Web Service URL in NP Pay for the following webhooks: %1', FailedWebhooks))
        else
            UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Adyen Recon. Upgrade", UpgradeStep));

        LogMessageStopwatch.LogFinish();
    end;

    [TryFunction]
    local procedure TryPushWebhookToAdyen(var WebhookSetup: Record "NPR Adyen Webhook Setup")
    var
        AdyenManagement: Codeunit "NPR Adyen Management";
        PartialCredentialsErr: Label 'Webhook %1 has only one of Web Service User/Password set — Adyen URL cannot be updated automatically.', Comment = '%1 = Adyen webhook ID';
    begin
        if (WebhookSetup."Web Service User" <> '') <> (WebhookSetup."Web Service Password" <> '') then
            Error(PartialCredentialsErr, WebhookSetup.ID);
        AdyenManagement.ModifyWebhook(WebhookSetup);
    end;

    local procedure IsDeprecatedWebhookForCurrentEnvironment(WebServiceURL: Text): Boolean
    var
        EnvironmentInformation: Codeunit "Environment Information";
        AzureADTenant: Codeunit "Azure AD Tenant";
        TypeHelper: Codeunit "Type Helper";
        PathSegments: List of [Text];
        QueryParams: List of [Text];
        ParamParts: List of [Text];
        QueryParam: Text;
        PathAndQuery: Text;
        PathPart: Text;
        QueryPart: Text;
        UrlTenant: Text;
        UrlEnvironment: Text;
        UrlCompanyName: Text;
        URLEncodedCompanyName: Text;
        Marker: Label '/api/NPPayCloud/', Locked = true;
        MarkerPos: Integer;
        QuestionMarkPos: Integer;
    begin
        // Deprecated URL shape: <base>/api/NPPayCloud/{tenant}/{environment}/{webhookRef}?code=...&CompanyName=...
        // tenant/environment live in the path; CompanyName in the query (url-encoded the same way as SuggestAFWebServiceURL).
        MarkerPos := WebServiceURL.IndexOf(Marker);
        if (MarkerPos = 0) or (MarkerPos + StrLen(Marker) > StrLen(WebServiceURL)) then
            exit(false);

        PathAndQuery := WebServiceURL.Substring(MarkerPos + StrLen(Marker));
        QuestionMarkPos := PathAndQuery.IndexOf('?');
        if QuestionMarkPos = 0 then
            PathPart := PathAndQuery
        else begin
            PathPart := PathAndQuery.Substring(1, QuestionMarkPos - 1);
            if QuestionMarkPos < StrLen(PathAndQuery) then
                QueryPart := PathAndQuery.Substring(QuestionMarkPos + 1);
        end;

        PathSegments := PathPart.Split('/');
        if PathSegments.Count() < 2 then
            exit(false);
        UrlTenant := PathSegments.Get(1);
        UrlEnvironment := PathSegments.Get(2);

        QueryParams := QueryPart.Split('&');
        foreach QueryParam in QueryParams do begin
            ParamParts := QueryParam.Split('=');
            if ParamParts.Count() = 2 then
                if ParamParts.Get(1) = 'CompanyName' then
                    UrlCompanyName := ParamParts.Get(2);
        end;

        URLEncodedCompanyName := CompanyName();
        TypeHelper.UrlEncode(URLEncodedCompanyName);

        exit(
            (UrlTenant = AzureADTenant.GetAadTenantId()) and
            (UrlEnvironment = EnvironmentInformation.GetEnvironmentName()) and
            (UrlCompanyName = URLEncodedCompanyName));
    end;
}