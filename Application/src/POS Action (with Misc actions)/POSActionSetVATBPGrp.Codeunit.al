codeunit 6150824 "NPR POSAction: Set VAT B.P.Grp" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Set VAT Bus. Posting Group';
    begin
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddJavascript(GetActionScript());
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    var
        POSActSetVATB: Codeunit "NPR POSAction: Set VAT BPGrp B";
    begin
        case Step of
            'SetVATBusGrp':
                POSActSetVATB.SetVATBusPostingGroup(Sale);
        end;
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSetVATBPGrp.js###
'let main=async({workflow:a})=>{await a.respond("SetVATBusGrp")};'
        );
    end;
}
