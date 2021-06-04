codeunit 6150920 "NPR UPG Item Reference"
{
    Subtype = Upgrade;


    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgItemRefTagDef: Codeunit "NPR UPG ItemRef Tag Def.";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Item Reference', 'OnUpgradePerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgItemRefTagDef.GetItemRefUpgradeTag()) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade code
        UpgradeItemCrossReference2ItemReference();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgItemRefTagDef.GetItemRefUpgradeTag());

        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeItemCrossReference2ItemReference()
    begin
        UpgradeItemReference();
    end;

    local procedure UpgradeItemReference()
    var
        ItemCrossReference: Record "Item Cross Reference";
        ItemReference: Record "Item Reference";
    begin
        if not ItemCrossReference.FindSet() then
            exit;

        repeat
            ItemReference.Init();
            ItemReference.TransferFields(ItemCrossReference);
            ItemReference.SystemId := ItemCrossReference.SystemId;
            if ItemCrossReference."NPR Is Retail Serial No." then
                ItemReference."Reference Type" := ItemReference."Reference Type"::"Retail Serial No.";
            if not ItemReference.Insert(false, true) then
                ;
        until ItemCrossReference.Next() = 0;
    end;
}