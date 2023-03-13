codeunit 6150823 "NPR POSAction: Set Tax Liable" implements "NPR IPOS Workflow"
{
    Access = Internal;

    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config")
    var
        ActionDescription: Label 'Set Tax Liable';
        Title: Label 'Tax Liable property';
        Prompt: Label 'Set Tax Liable property?';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddLabel('title', Title);
        WorkflowConfig.AddLabel('prompt', Prompt);
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup")
    begin
        case Step of
            'SetTaxLiable':
                SetTaxLiable(Context);
        end;
    end;

    local procedure SetTaxLiable(Context: Codeunit "NPR POS JSON Helper")
    var
        TaxLiableValue: Boolean;
        POSActionSetTaxLiable: Codeunit "NPR POSAction: Set TaxLiable B";
    begin
        TaxLiableValue := Context.GetBoolean('value');

        POSActionSetTaxLiable.SetTaxLiable(TaxLiableValue);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSetTaxLiable.js###
'let main=async({workflow:t,popup:e,captions:a})=>{let i=await e.confirm({title:a.title,caption:a.prompt});await t.respond("SetTaxLiable",{value:i})};'
        );
    end;
}
