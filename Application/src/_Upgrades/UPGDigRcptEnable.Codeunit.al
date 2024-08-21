codeunit 6060126 "NPR UPG Dig. Rcpt. Enable"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeGlobalDigitalReceiptSetupEnable();
        TransferDigitalReceiptSetupData();
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

    local procedure TransferDigitalReceiptSetupData()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Dig. Rcpt. Enable', 'UpdateDigitalReceiptSetupTable');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateDigitalReceiptSetupTable')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpdateDigitalReceiptSetupTable();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'UpdateDigitalReceiptSetupTable'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeDigitalReceiptSetupEnable()
    var
        POSReceiptProfile: Record "NPR POS Receipt Profile";
        DigitalReceiptSetup: Record "NPR Digital Rcpt. Setup";
    begin
        POSReceiptProfile.SetRange("Enable Digital Receipt", true);
        if POSReceiptProfile.IsEmpty() then
            exit;
        if not DigitalReceiptSetup.Get() then
            exit;
        DigitalReceiptSetup.Enable := true;
        DigitalReceiptSetup.Modify();
    end;

    local procedure UpdateDigitalReceiptSetupTable()
    var
        DigitalRcptSetup: Record "NPR Digital Rcpt. Setup";
        DigitalReceiptSetup: Record "NPR Digital Receipt Setup";
    begin
        if DigitalReceiptSetup.Get() then
            if not DigitalRcptSetup.Get(DigitalReceiptSetup.Code) then begin
                DigitalRcptSetup.Init();
                DigitalRcptSetup."Api Key" := DigitalReceiptSetup."Api Key";
                DigitalRcptSetup."Api Secret" := DigitalReceiptSetup."Api Secret";
                DigitalRcptSetup."Bearer Token Expires At" := DigitalReceiptSetup."Bearer Token Expires At";
                DigitalRcptSetup."Bearer Token Value" := DigitalReceiptSetup."Bearer Token Value";
                DigitalRcptSetup.Enable := DigitalReceiptSetup.Enable;
                DigitalRcptSetup."Credentials Test Success" := DigitalReceiptSetup."Credentials Test Success";
                DigitalRcptSetup."Last Credentials Test DateTime" := DigitalReceiptSetup."Last Credentials Test DateTime";
                DigitalRcptSetup.Insert();
            end;
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG Dig. Rcpt. Enable");
    end;
}
