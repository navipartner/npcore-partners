codeunit 6150967 "NPR UPG BalanceV4"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG BalanceV4 Menu Buttons', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Balancev4")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePOSMenuButtons();
        UpgradeNamedActionProfiles();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Balancev4"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenuButtons()
    var
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'BALANCE_V3');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := Format(Enum::"NPR POS Workflow"::BALANCE_V4);
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;
    end;

    local procedure UpgradeNamedActionProfiles()
    var
        POSNamedActionProfile: Record "NPR POS Setup";
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        POSNamedActionProfile.SetRange("End of Day Action Code", 'BALANCE_V3');
        if not POSNamedActionProfile.FindSet(true) then
            exit;

        repeat
            POSNamedActionProfile."End of Day Action Code" := Format(Enum::"NPR POS Workflow"::BALANCE_V4);
            POSNamedActionProfile.Modify(true);
            ParamMgt.RefreshParameters(POSNamedActionProfile.RecordId, '', POSNamedActionProfile.FieldNo("End of Day Action Code"), POSNamedActionProfile."End of Day Action Code");
        until POSNamedActionProfile.Next() = 0;
    end;
}