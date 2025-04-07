codeunit 6248388 "NPR UPG Adyen Api Key"
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
        UpgradeEFTAdyenPaymentTypeApiKey();
        UpgradeAdyenManagmentApiKey();
        UpgradeAdyenDownloadReportApiKey();
    end;

    local procedure UpgradeEFTAdyenPaymentTypeApiKey()
    var
        EFTAdyenPaymTypeSetup: Record "NPR EFT Adyen Paym. Type Setup";
    begin
        UpgradeStep := 'UpgradeEFTAdyenPaymentTypeApiKey';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if not EFTAdyenPaymTypeSetup.FindSet() then
            exit;

        repeat
            if EFTAdyenPaymTypeSetup."API Key" <> '' then begin
                EFTAdyenPaymTypeSetup.SetAPIKey(EFTAdyenPaymTypeSetup."API Key");
                EFTAdyenPaymTypeSetup."API Key" := '';
                EFTAdyenPaymTypeSetup.Modify();

            end;
        until EFTAdyenPaymTypeSetup.Next() = 0;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure UpgradeAdyenManagmentApiKey()
    var
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        UpgradeStep := 'UpgradeAdyenManagmentApiKey';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if not AdyenSetup.Get() then
            exit;

        if AdyenSetup."Management API Key" <> '' then begin
            AdyenSetup.SetManagementAPIKey(AdyenSetup."Management API Key");
            AdyenSetup."Management API Key" := '';
            AdyenSetup.Modify();
        end;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure UpgradeAdyenDownloadReportApiKey()
    var
        AdyenSetup: Record "NPR Adyen Setup";
    begin
        UpgradeStep := 'UpgradeAdyenDownloadReportApiKey';
        if HasUpgradeTag() then
            exit;
        LogStart();

        if not AdyenSetup.Get() then
            exit;

        if AdyenSetup."Download Report API Key" <> '' then begin
            AdyenSetup.SetDownloadReportAPIKey(AdyenSetup."Download Report API Key");
            AdyenSetup."Download Report API Key" := '';
            AdyenSetup.Modify();
        end;

        SetUpgradeTag();
        LogFinish();
    end;

    local procedure HasUpgradeTag(): Boolean
    begin
        exit(UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Adyen Api Key", UpgradeStep)));
    end;

    local procedure SetUpgradeTag()
    begin
        if HasUpgradeTag() then
            exit;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Adyen Api Key", UpgradeStep));
    end;

    local procedure LogStart()
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Adyen Api Key', UpgradeStep);
    end;

    local procedure LogFinish()
    begin
        LogMessageStopwatch.LogFinish();
    end;
}