codeunit 6150937 "NPR UPG Tax Calc."
{
    Subtype = Upgrade;


    trigger OnCheckPreconditionsPerCompany()
    var
        UpgTagDef: Codeunit "NPR UPG Tax Calc. Tag Def";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag()) then
            exit;

        // Run upgrade preconditions
        ErrorIfPOSSaleIsOpen();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag());
    end;

    local procedure ErrorIfPOSSaleIsOpen()
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        if not POSSaleLine.IsEmpty() then
            Error('Can''t perform upgrade process when there is active POS sale. End all active POS sale (%1 is not empty)', POSSaleLine.TableName());
    end;
}