codeunit 6150617 "NPR POS Action: Change Bin" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'Change bin for current POS sales line';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    var
        POSActionChangeBinB: Codeunit "NPR POS Action: Change Bin-B";
    begin
        case Step of
            'ChangeBin':
                POSActionChangeBinB.ChangeBin(SaleLine);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionChangeBin.js###
'let main=async({})=>await workflow.respond("ChangeBin");'
        )
    end;
}
