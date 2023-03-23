codeunit 6059885 "NPR POS Display Profile Upg."
{
    Access = Internal;
    Subtype = Upgrade;


    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure OnGetPerCompanyTags(var PerCompanyUpgradeTags: List of [Code[250]]);
    var
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        PerCompanyUpgradeTags.Add(UpgTagDef.GetUpgradeTag(Codeunit::"NPR POS Display Profile Upg."));
    end;

    trigger OnUpgradePerCompany()
    var
        DisplayProfile: Record "NPR Display Setup";
        UnitDisplay: Record "NPR POS Unit Display";
        POSUnit: Record "NPR POS Unit";
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR POS Display Profile Upg.', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR POS Display Profile Upg.")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;
        if (POSUnit.FindSet()) then begin
            repeat
                if (DisplayProfile.Get(POSUnit."No.") or
                ((POSUnit."POS Display Profile" <> '') and
                DisplayProfile.Get(POSUnit."POS Display Profile"))) then
                    if not UnitDisplay.Get(POSUnit."No.") then begin
                        UnitDisplay."Media Downloaded" := DisplayProfile."Media Downloaded";
                        UnitDisplay."Screen No." := DisplayProfile."Screen No.";
                        UnitDisplay.POSUnit := POSUnit."No.";
                        UnitDisplay.Insert();
                        if (POSUnit."POS Display Profile" = '') then begin
                            POSUnit."POS Display Profile" := DisplayProfile."Register No.";
                            POSUnit.Modify();
                        end;
                    end;
            until (POSUnit.Next() = 0);
        end;
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR POS Display Profile Upg."));
        LogMessageStopwatch.LogFinish();
    end;
}