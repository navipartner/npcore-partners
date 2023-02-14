codeunit 6150818 "NPR POSAction: Set TaxAreaCode" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Set Tax Area Code';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        SalePOS: Record "NPR POS Sale";
        SetTaxAreaCodeB: Codeunit "NPR POSAction: SetTaxAreaCodeB";
    begin
        Context.SetScopeRoot();
        Sale.GetCurrentSale(SalePOS);
        SetTaxAreaCodeB.SetTaxAreaCode(SalePOS);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSetTaxAreaCode.js###
'let main=async({})=>await workflow.respond();'
        );
    end;
}

