codeunit 6150944 "NPR UPG NaviConnect"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG NaviConnect', 'OnUpgradePerCompany');

        SetActionableFalseOnNPRLogging();

        LogMessageStopwatch.LogFinish();
    end;

    local procedure SetActionableFalseOnNPRLogging()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        ImportType: Record "NPR Nc Import Type";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG NaviConnect', 'SetActionableFalseOnNPRLogging');

        if (UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NaviConnect", 'ImportTypeActionable'))) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // set actionable for all import types to mimic InitValue property
        // besides our own logging types.
        ImportType.SetFilter(Code, '<>@member-*&<>@ticket-*&<>@m2-account-*&<>@loyalty-*&<>@points-*');
        if (not ImportType.IsEmpty()) then
            ImportType.ModifyAll(Actionable, true);

        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG NaviConnect", 'ImportTypeActionable'));
        LogMessageStopwatch.LogFinish();
    end;
}