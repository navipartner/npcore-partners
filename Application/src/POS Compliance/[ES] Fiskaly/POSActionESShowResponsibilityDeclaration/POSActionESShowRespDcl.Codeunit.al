codeunit 6248383 "NPR POS Action: ES ShowRespDcl" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a built-in action for showing responsibility declaration.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSUnit: Record "NPR POS Unit";
    begin
        Setup.GetPOSUnit(POSUnit);
        ShowResponsibilityDeclaration(POSUnit);
    end;

    local procedure ShowResponsibilityDeclaration(POSUnit: Record "NPR POS Unit")
    var
        ESFiscalizationSetup: Record "NPR ES Fiscalization Setup";
        ESClient: Record "NPR ES Client";
        ESOrganization: Record "NPR ES Organization";
    begin
        ESFiscalizationSetup.Get();
        ESFiscalizationSetup.TestField("ES Fiscal Enabled");
        ESClient.GetWithCheck(POSUnit."No.");
        ESOrganization.GetWithCheck(ESClient."ES Organization Code");
        ESOrganization.TestField("Responsibility Declaration URL");
        Hyperlink(ESOrganization."Responsibility Declaration URL");
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionESShowRespDcl.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}
