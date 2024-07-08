codeunit 6150803 "NPR POS Action: Zoom" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config")
    var
        ActionDescriptionLbl: Label 'Zoom a sales line.';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescriptionLbl);
        WorkflowConfig.SetDataBinding();
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSActionZoomB: Codeunit "NPR POS Action: Zoom-B";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSActionZoomB.ZoomLine(POSSession);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionZoom.js###
'let main=async({})=>{await workflow.respond()};'
        )
    end;
}
