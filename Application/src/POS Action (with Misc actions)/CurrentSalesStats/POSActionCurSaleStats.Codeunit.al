codeunit 6059870 "NPR POS Action: Cur Sale Stats" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'This built-in action opens page with current sale statistics.';
        ParamUseUnitCost_CaptionLbl: Label 'AlwaysUseUnitCost';
        ParamUseUnitCost_DescLbl: Label 'Always use Unit Cost';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddBooleanParameter('AlwaysUseUnitCost', false, ParamUseUnitCost_CaptionLbl, ParamUseUnitCost_DescLbl);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionCurSaleStats.js###
        'let main=async({})=>await workflow.respond();'
        );
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        BusinessLogicRun: Codeunit "NPR POS Action: CurSaleStats-B";
        AlwaysUseUnitCost: Boolean;
    begin
        AlwaysUseUnitCost := Context.GetBooleanParameter('AlwaysUseUnitCost');
        BusinessLogicRun.RunSalesStatsPage(AlwaysUseUnitCost);
    end;
}