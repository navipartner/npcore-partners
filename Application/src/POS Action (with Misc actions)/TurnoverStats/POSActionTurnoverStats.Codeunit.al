codeunit 6059966 "NPR POS Action Turnover Stats" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Open the Turnover Statistics page';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSTurnoverCalcBuffer: Record "NPR POS Turnover Calc. Buffer";
        POSStore: Record "NPR POS Store";
        POSStatisticsMgt: Codeunit "NPR POS Statistics Mgt.";
    begin
        Setup.GetPOSStore(POSStore);

        POSStatisticsMgt.FillTurnoverData(POSTurnoverCalcBuffer, WorkDate(), POSStore.Code, Setup.GetPOSUnitNo());
        Page.RunModal(Page::"NPR POS Turnover", POSTurnoverCalcBuffer);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionTurnoverStats.js###
        'let main=async({})=>await workflow.respond();'
        );
    end;
}