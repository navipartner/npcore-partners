codeunit 6060126 "NPR UPG Dig. Rcpt. Enable"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeGlobalDigitalReceiptSetupEnable();
    end;

    local procedure UpgradeGlobalDigitalReceiptSetupEnable()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Dig. Rcpt. Enable', 'UpgradeDigitalReceiptSetupEnable');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeDigitalReceiptSetupEnable')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeDigitalReceiptSetupEnable();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpgradeDigitalReceiptSetupEnable'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeDigitalReceiptSetupEnable()
    var
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        DigitalReceiptSetup: Record "NPR Digital Receipt Setup";
    begin
        POSReceiptProfile.SetRange("Enable Digital Receipt", true);
        if POSReceiptProfile.IsEmpty() then
            exit;
        if not DigitalReceiptSetup.Get() then
            exit;
        DigitalReceiptSetup.Enable := true;
        DigitalReceiptSetup.Modify();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG Dig. Rcpt. Enable");
    end;
}
