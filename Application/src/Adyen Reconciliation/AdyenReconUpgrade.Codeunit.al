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
                    ReconLine.SetFilter(Status, '<>%1&<>%2', ReconLine.Status::Posted, ReconLine.Status::"Not to be Posted");
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
        ReconLine.SetFilter(Status, '<>%1&<>%2', ReconLine.Status::"Not to be Posted", ReconLine.Status::Posted);
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
}