codeunit 6059858 "NPR UPG DE Audit Setup"
{
    Access = Internal;
    Subtype = Upgrade;

    trigger OnUpgradePerCompany()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
        UpgradeTagMgt: Codeunit "Upgrade Tag";
        UpgTagDef: Codeunit "NPR Upgrade Tag Definitions";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG DE Audit Setup', 'OnUpgradePerCompany');

        if not UpgradeTagMgt.HasUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG DE Audit Setup")) then begin
            RemovePOSWorkflowStep();
            UpgradeTagMgt.SetUpgradeTag(UpgTagDef.GetUpgradeTag(Codeunit::"NPR UPG DE Audit Setup"));
        end;
        LogMessageStopwatch.LogFinish();
    end;

    local procedure RemovePOSWorkflowStep()
    var
        PosWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        PosWorkflowStep.SetRange("Subscriber Codeunit ID", Codeunit::"NPR DE Audit Mgt.");
        PosWorkflowStep.SetRange("Subscriber Function", 'CreateDeFiskalyOnSale');
        if not PosWorkflowStep.IsEmpty() then
            PosWorkflowStep.DeleteAll();
    end;
}