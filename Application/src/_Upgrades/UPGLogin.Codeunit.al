codeunit 6060017 "NPR UPG Login"
{
    Access = Internal;
    Subtype = Upgrade;


    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG Login Menu Buttons', 'OnUpgradePerCompany');

        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Login")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradePOSMenuLoginButtons();
        UpgradeNamedActionProfiles();

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG Login"));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradePOSMenuLoginButtons()
    var
        POSMenuButton: Record "NPR POS Menu Button";
    begin
        POSMenuButton.SetRange("Action Type", POSMenuButton."Action Type"::Action);
        POSMenuButton.SetRange("Action Code", 'LOGIN-BUTTON');
        if not POSMenuButton.FindSet(true) then
            exit;

        repeat
            POSMenuButton."Action Code" := 'LOGIN';
            POSMenuButton.Modify(true);
            POSMenuButton.RefreshParameters();
        until POSMenuButton.Next() = 0;
    end;

    local procedure UpgradeNamedActionProfiles()
    var
        POSNamedActionProfile: Record "NPR POS Setup";
        ParamMgt: Codeunit "NPR POS Action Param. Mgt.";
    begin
        POSNamedActionProfile.SetRange("Login Action Code", 'LOGIN-BUTTON');
        if not POSNamedActionProfile.FindSet(true) then
            exit;

        repeat
            POSNamedActionProfile."Login Action Code" := 'LOGIN';
            POSNamedActionProfile.Modify(true);
            ParamMgt.RefreshParameters(POSNamedActionProfile.RecordId, '', POSNamedActionProfile.FieldNo("Login Action Code"), POSNamedActionProfile."Login Action Code");
        until POSNamedActionProfile.Next() = 0;
    end;
}