codeunit 6151280 "NPR POSAction: SS Qty Increase" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This is a build in function to change quantity.';
        IncreaseByDescLbl: Label 'Specifies how much the Quantity will increase.';
        IncreaseByCaptionLbl: Label 'Increase By';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.AddDecimalParameter('increaseBy', 1.0, IncreaseByCaptionLbl, IncreaseByDescLbl);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: codeunit "NPR POS JSON Helper"; FrontEnd: codeunit "NPR POS Front End Management"; Sale: codeunit "NPR POS Sale"; SaleLine: codeunit "NPR POS Sale Line"; PaymentLine: codeunit "NPR POS Payment Line"; Setup: codeunit "NPR POS Setup");
    begin
        case Step of
            'IncreaseQty':
                Frontend.WorkflowResponse(IncreaseQuantity(Context, SaleLine));
        end;
    end;

    internal procedure IncreaseQuantity(Context: codeunit "NPR POS JSON Helper"; SaleLine: codeunit "NPR POS Sale Line"): JsonObject
    var
        POSSession: Codeunit "NPR POS Session";
        Qty: Decimal;
    begin
        Qty := Context.GetDecimalParameter('increaseBy');
        IncreaseSalelineQuantity(POSSession, Qty, SaleLine);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
//###NPR_INJECT_FROM_FILE:POSActionSSQtyIncrease.js###
'let main=async({})=>await workflow.respond("IncreaseQty");'
        )
    end;

    internal procedure IncreaseSalelineQuantity(POSSession: Codeunit "NPR POS Session"; IncreaseBy: Decimal; SaleLine: codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
    begin
        // This function should be "not local", so test framework can invoke it
        SaleLine.GetCurrentSaleLine(SaleLinePOS);
        SaleLine.SetQuantity(SaleLinePOS.Quantity + IncreaseBy);
    end;
}

