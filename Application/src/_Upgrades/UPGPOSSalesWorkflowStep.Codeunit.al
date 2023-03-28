codeunit 6150945 "NPR UPG POS SalesWorkflowStep"
{
    Access = Internal;
    Subtype = Upgrade;

    var
        UpgradeTag: Codeunit "Upgrade Tag";
        UpgradeTagsDef: Codeunit "NPR Upgrade Tag Definitions";

    trigger OnUpgradePerCompany()
    begin
        ShowReturnAmountDialog();
    end;

    local procedure ShowReturnAmountDialog()
    var
        LogMessageStopwatch: Codeunit "NPR LogMessage Stopwatch";
    begin
        LogMessageStopwatch.LogStart(CompanyName(), 'NPR UPG POS SalesWorkflowStep', 'ShowReturnAmountDialog');

        if UpgradeTag.HasUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ShowReturnAmountDialog')) then begin
            LogMessageStopwatch.LogFinish();
            exit;
        end;

        UpgradeShowReturnAmountDialog();

        UpgradeTag.SetUpgradeTag(UpgradeTagsDef.GetUpgradeTag(CurrCodeunitId(), 'ShowReturnAmountDialog'));
        LogMessageStopwatch.LogFinish();
    end;

    local procedure UpgradeShowReturnAmountDialog()
    var
        POSSalesWorkflowStep: Record "NPR POS Sales Workflow Step";
    begin
        POSSalesWorkflowStep.SetRange("Subscriber Function", 'ShowReturnAmountDialog');
        POSSalesWorkflowStep.SetRange("Subscriber Codeunit ID", 6150855);
        POSSalesWorkflowStep.Setrange("Workflow Code", 'FINISH_SALE');
        if POSSalesWorkflowStep.FindSet() then
            POSSalesWorkflowStep.DeleteAll();
    end;

    local procedure CurrCodeunitId(): Integer
    begin
        exit(Codeunit::"NPR UPG POS SalesWorkflowStep");
    end;
}