codeunit 6014657 "NPR Enum Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    begin
        UpgradeEnums();
    end;

    local procedure UpgradeEnums()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Enum Upgrade.', 'UpgradeItemReferenceEnums');

        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Enum Upgrade")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        DoUpgradeItemReferenceEnums();

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Enum Upgrade"));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure DoUpgradeItemReferenceEnums()
    var
        ItemReference: Record "Item Reference";
    begin
        ItemReference.SetRange("Reference Type", 4);
        if ItemReference.FindSet(true, true) then
            repeat
                ItemReference.Rename(ItemReference."Item No.", ItemReference."Variant Code", ItemReference."Unit of Measure", ItemReference."Reference Type"::"NPR Retail Serial No.", ItemReference."Reference Type No.", ItemReference."Reference No.");
            until ItemReference.Next() = 0;
    end;
}
