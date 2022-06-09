codeunit 6014448 "NPR Initialize Data"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitPOSSalesWorkflowSteps();
        InitExchangeLabelSetup();
    end;

    local procedure InitPOSSalesWorkflowSteps()
    var
        POSSalesWorkflow: Record "NPR POS Sales Workflow";
    begin
        POSSalesWorkflow.OnDiscoverPOSSalesWorkflows();
        if POSSalesWorkflow.FindSet() then
            repeat
                POSSalesWorkflow.InitPOSSalesWorkflowSteps();
            until POSSalesWorkflow.Next() = 0;
    end;

    local procedure InitExchangeLabelSetup()
    var
        ExchangeLabelSetup: Record "NPR Exchange Label Setup";
    begin
        if not ExchangeLabelSetup.Get() then begin
            ExchangeLabelSetup.Init();
            ExchangeLabelSetup.Insert();
        end;
    end;
}
