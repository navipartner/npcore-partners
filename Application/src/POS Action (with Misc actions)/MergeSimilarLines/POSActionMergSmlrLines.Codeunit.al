codeunit 6151176 "NPR POSAction: Merg.Smlr.Lines" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This action is used to merge similar item lines of the sale to a single one';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSActionMergSmlrLinesB: Codeunit "NPR POSAction: Merg.Sml.LinesB";
        POSSession: Codeunit "NPR POS Session";
        SalePOS: Record "NPR POS Sale";
    begin
        Sale.GetCurrentSale(SalePOS);
        POSActionMergSmlrLinesB.ColapseSaleLines(POSSession, SalePOS);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionMergSmlrLines.js###
'let main=async({})=>await workflow.respond();'
        )
    end;
}

