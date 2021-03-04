codeunit 6014448 "NPR Initialize Data"
{
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitPOSSalesWorkflowSteps();
    end;

    local procedure InitPOSSalesWorkflowSteps()
    var
        POSSalesWorkflow: Record "NPR POS Sales Workflow";
    begin
        POSSalesWorkflow.OnDiscoverPOSSalesWorkflows();
        if POSSalesWorkflow.FindSet then
            repeat
                POSSalesWorkflow.InitPOSSalesWorkflowSteps();
            until POSSalesWorkflow.Next = 0;
    end;
}
