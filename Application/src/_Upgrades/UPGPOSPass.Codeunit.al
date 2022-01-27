codeunit 6014591 "NPR UPG POS Pass"
{
    Access = Internal;
    Subtype = Upgrade;


    trigger OnCheckPreconditionsPerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS Pass', 'OnCheckPreconditionsPerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Pass")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade preconditions
        UpgradePOSUnitPasswords();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG POS Pass"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSUnitPasswords()
    var
        POSUnit: Record "NPR POS Unit";
        POSViewProfile: Record "NPR POS View Profile";
        POSSecurityProfile: Record "NPR POS Security Profile";
    begin
        if not POSUnit.FindSet() then
            exit;
        repeat
            if POSUnit.GetProfile(POSViewProfile) and (POSViewProfile."Open Register Password" = '') then begin
                POSViewProfile."Open Register Password" := POSUnit."Open Register Password";
                POSViewProfile.Modify();
            end;
            if POSUnit.GetProfile(POSSecurityProfile) and (POSSecurityProfile."Password on Unblock Discount" = '') then begin
                POSSecurityProfile."Password on Unblock Discount" := POSUnit."Password on Unblock Discount";
                POSSecurityProfile.Modify();
            end;
        until POSUnit.next() = 0;
    end;
}
