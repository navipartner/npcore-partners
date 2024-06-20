codeunit 6184908 "NPR Recon. EFT Magento Upgrade"
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
    end;

    local procedure UpdatePSPReferenceForEFTTrans()
    var
        EFTTransactionRequest: Record "NPR EFT Transaction Request";
        AdyenCloudIntegration: Codeunit "NPR EFT Adyen Cloud Integrat.";
        AdyenLocalIntegration: Codeunit "NPR EFT Adyen Local Integrat.";
    begin
        UpgradeStep := 'UpdatePSPReferenceForEFTTrans';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Recon. EFT Magento Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Recon. EFT Magento Upgrade', UpgradeStep);

        EFTTransactionRequest.Reset();
        EFTTransactionRequest.SetFilter("Integration Type", '%1|%2', AdyenCloudIntegration.IntegrationType(), AdyenLocalIntegration.IntegrationType());
        if EFTTransactionRequest.FindSet(true) then
            repeat
                if EFTTransactionRequest."External Transaction ID".Split('.').Count = 2 then begin
                    EFTTransactionRequest."PSP Reference" := CopyStr(EFTTransactionRequest."External Transaction ID".Split('.').Get(2), 1, MaxStrLen(EFTTransactionRequest."PSP Reference"));
                    EFTTransactionRequest.Modify();
                end;
            until EFTTransactionRequest.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Recon. EFT Magento Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpdateAdyenSetupCompanyID()
    var
        AdyenSetup: Record "NPR Adyen Setup";
        AdyenSetupCompanyID: Record "NPR Adyen Setup";
    begin
        UpgradeStep := 'UpdateAdyenSetupCompanyID';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Recon. EFT Magento Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Recon. EFT Magento Upgrade', UpgradeStep);

        if not AdyenSetup.Get() then
            exit;

        AdyenSetupCompanyID.Init();
        if AdyenSetup."Company ID" = AdyenSetupCompanyID."Company ID" then
            exit;

        AdyenSetup."Company ID" := AdyenSetupCompanyID."Company ID";
        AdyenSetup.Modify(false);

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Recon. EFT Magento Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;


}
