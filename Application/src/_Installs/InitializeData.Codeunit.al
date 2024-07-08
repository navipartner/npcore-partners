codeunit 6014448 "NPR Initialize Data"
{
    Access = Internal;
    Subtype = Install;

    trigger OnInstallAppPerCompany()
    begin
        InitPOSSalesWorkflowSteps();
        InitSetupTables();
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

    local procedure InitSetupTables()
    var
        JobQueueManagement: Codeunit "NPR Job Queue Management";
    begin
        InitExchangeLabelSetup();
        JobQueueManagement.InitJobQueueRefreshSetup();
        InitPOSPostingProfile();
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

    local procedure InitPOSPostingProfile()
    var
        POSPostingProfile: Record "NPR POS Posting Profile";
    begin
        if not POSPostingProfile.FindSet() then
            CreatePosPostingProfile(POSPostingProfile);
    end;

    local procedure CreatePosPostingProfile(var NPRPOSPostingProfile: Record "NPR POS Posting Profile")
    begin
        NPRPOSPostingProfile.Init();
        NPRPOSPostingProfile.Code := 'DEFAULT';
        NPRPOSPostingProfile.Description := 'Default POS Posting Profile';
        NPRPOSPostingProfile."Post POS Sale Doc. With JQ" := true;
        NPRPOSPostingProfile.Insert();
    end;
}
