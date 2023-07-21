codeunit 6151281 "NPR SS Action - Qty Decrease" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a build in function to change quantity.';
        DecreaseByDescLbl: Label 'Specifies how much the Quantity will decrease.';
        DecreaseByCaptionLbl: Label 'Decrease By';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddDecimalParameter('decreaseBy', 1.0, DecreaseByCaptionLbl, DecreaseByDescLbl);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'DecreaseQty':
                DecreaseQuantity(Context, SaleLine);
        end;
    end;

    internal procedure DecreaseQuantity(Context: codeunit "NPR POS JSON Helper"; SaleLine: codeunit "NPR POS Sale Line")
    var
        Qty: Decimal;
        SSActionQtyDecreaseB: Codeunit "NPR SS Action - Qty Decrease B";
    begin
        Qty := Context.GetDecimalParameter('decreaseBy');
        SSActionQtyDecreaseB.DecreaseSalelineQuantity(Qty, SaleLine);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:SSActionQtyDecreaseSS.js###
'let main=async({})=>await workflow.respond("DecreaseQty");'
        )
    end;
}

