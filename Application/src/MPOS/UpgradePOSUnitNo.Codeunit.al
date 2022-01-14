codeunit 6014692 "NPR Upgrade POS Unit No"
{
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnRun()
    begin
        UpgradeDataInMPOSQRCode();
    end;

    local procedure UpgradeDataInMPOSQRCode()
    var
        MPOSQRCode: Record "NPR MPOS QR Code";
    begin
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade POS Unit No")) then
            exit;
        if MPOSQRCode.FindSet() then
            repeat
                MPOSQRCode."POS Unit No." := MPOSQRCode."Cash Register Id";
                MPOSQRCode.Modify();
            until MPOSQRCode.Next() = 0;
        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Upgrade POS Unit No"));
    end;
}
