codeunit 6151282 "NPR SS Action: Delete POS Line" implements "NPR IPOS Workflow"
{
    Access = Internal;
    procedure Register(WorkflowConfig: Codeunit "NPR POS Workflow Config");
    var
        ActionDescription: Label 'This built in function deletes sales or payment line from the POS';
    begin
        WorkflowConfig.AddJavascript(GetActionScript());
        WorkflowConfig.AddActionDescription(ActionDescription);
        WorkflowConfig.SetWorkflowTypeUnattended();
    end;

    procedure RunWorkflow(Step: Text; Context: Codeunit "NPR POS JSON Helper"; FrontEnd: Codeunit "NPR POS Front End Management"; Sale: Codeunit "NPR POS Sale"; SaleLine: Codeunit "NPR POS Sale Line"; PaymentLine: Codeunit "NPR POS Payment Line"; Setup: Codeunit "NPR POS Setup");
    begin
        DeletePOSLine(SaleLine);
    end;

    local procedure GetActionScript(): Text
    begin
        exit(
        //###NPR_INJECT_FROM_FILE:POSActionSSDeleteLine.js###
        'let main=async({})=>await workflow.respond();'
        )
    end;

    [Obsolete('Use procedure DeletePOSLine instead', 'NPR23.0')]
    procedure DeletePosLine(POSSession: Codeunit "NPR POS Session")
    var
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSale: Codeunit "NPR POS Sale";
        POSActionDeletePOSLine: Codeunit "NPR POSAction: Delete POS Line";
    begin
    end;

    procedure DeletePOSLine(POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        POSActionDeletePOSLine: Codeunit "NPR POSAction: Delete POS Line";
    begin
        POSActionDeletePOSLine.OnBeforeDeleteSaleLinePOS(POSSaleLine);
        DeleteAccessories(POSSaleLine);
        POSSaleLine.DeleteLine();
    end;

    procedure DeleteAccessories(POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        SaleLinePOS2: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS."Line Type" <> SaleLinePOS."Line Type"::Item then
            exit;
        if SaleLinePOS."No." in ['', '*'] then
            exit;

        SaleLinePOS2.SetRange("Register No.", SaleLinePOS."Register No.");
        SaleLinePOS2.SetRange("Sales Ticket No.", SaleLinePOS."Sales Ticket No.");
        SaleLinePOS2.SetFilter("Line No.", '<>%1', SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange("Main Line No.", SaleLinePOS."Line No.");
        SaleLinePOS2.SetRange(Accessory, true);
        SaleLinePOS2.SetRange("Main Item No.", SaleLinePOS."No.");
        if SaleLinePOS2.IsEmpty then
            exit;

        SaleLinePOS2.SetSkipCalcDiscount(true);
        SaleLinePOS2.DeleteAll(false);
    end;
}
