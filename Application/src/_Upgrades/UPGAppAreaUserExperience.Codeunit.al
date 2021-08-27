codeunit 6060096 "NPR UPG App. Area User Exp."
{
    Subtype = Upgrade;


    trigger OnCheckPreconditionsPerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG App. Area User Exp.', 'OnCheckPreconditionsPerCompany');

        // Check whether the tag has been used before, and if so, don't run upgrade code
        if UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG App. Area User Exp.")) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        // Run upgrade preconditions
        ActivateApplicationArea();

        // Insert the upgrade tag in table 9999 "Upgrade Tags" for future reference
        UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG App. Area User Exp."));

        LogMessageStopwatch.LogFinish();
    end;

    local procedure ActivateApplicationArea()
    var
        ApplicationAreaSetup: Record "Application Area Setup";
        ApplicationAreaMgmtFacade: Codeunit "Application Area Mgmt. Facade";
        Experience: Text;
    begin
        if not ApplicationAreaMgmtFacade.GetExperienceTierCurrentCompany(Experience) then
            exit;
        ApplicationAreaSetup.SetRange("Company Name", CompanyName());
        if ApplicationAreaSetup.IsEmpty() then
            exit;
        ApplicationAreaSetup.ModifyAll("NPR Retail", true);
    end;
}