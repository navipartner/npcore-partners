codeunit 6060087 "NPR Item Upgrade"
{
    Access = Internal;
    Subtype = Upgrade;

    var
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeStep: Text;
#ENDIF

    trigger OnUpgradePerCompany()
    begin
#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
        PopulateItemVariantNewField();
#ENDIF
    end;

#IF NOT (BC17 or BC18 or BC19 or BC20 or BC21 or BC22)
    local procedure PopulateItemVariantNewField()
    var
        ItemVariant: Record "Item Variant";
    begin
        UpgradeStep := 'PopulateItemVariantNewField';
        if UpgradeTag.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Item Upgrade", UpgradeStep)) then
            exit;
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR Item Upgrade', UpgradeStep);

        if ItemVariant.FindSet(true) then
            repeat
                if ItemVariant.Blocked <> ItemVariant."NPR Blocked" then begin
                    ItemVariant.Blocked := ItemVariant."NPR Blocked";
                    ItemVariant.Modify();
                end;
            until ItemVariant.Next() = 0;

        UpgradeTag.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR Item Upgrade", UpgradeStep));
        LogMessageStopwatch.LogFinish();
    end;
#ENDIF
}
