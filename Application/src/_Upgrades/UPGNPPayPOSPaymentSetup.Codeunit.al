codeunit 6248424 "NPR UPG NP Pay POSPaymentSetup"
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
        UpgradeNPPayPOSPaymentSetupApiKey();
    end;

    local procedure UpgradeNPPayPOSPaymentSetupApiKey()
    var
        NpPayPosPaymentSetup: Record "NPR NP Pay POS Payment Setup";
    begin
        UpgradeStep := 'UpgradeNPPayPOSPaymentSetupApiKey';

        if HasUpgradeTag() then
            exit;

        LogStart();

        NpPayPosPaymentSetup.Reset();
        if (NpPayPosPaymentSetup.FindSet()) then begin
            repeat
                if NpPayPosPaymentSetup."Payment API Key" <> '' then begin
                    NpPayPosPaymentSetup.SetAPIKey(NpPayPosPaymentSetup."Payment API Key");
                    NpPayPosPaymentSetup."Payment API Key" := '';
                    NpPayPosPaymentSetup.Modify();
                end;
            until (NpPayPosPaymentSetup.Next() = 0);
        end;

        SetUpgradeTag();
        LogFinish();
    end;


    local procedure HasUpgradeTag(): Boolean
    begin
        exit(UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NP Pay POSPaymentSetup", UpgradeStep)));
    end;

    local procedure SetUpgradeTag()
    begin
        if HasUpgradeTag() then
            exit;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NP Pay POSPaymentSetup", UpgradeStep));
    end;

    local procedure LogStart()
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG NP Pay POSPaymentSetup', UpgradeStep);
    end;

    local procedure LogFinish()
    begin
        LogMessageStopwatch.LogFinish();
    end;
}