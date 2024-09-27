codeunit 6060097 "NPR POSAct:Delete POS Line-B"
{
    Access = Internal;

    procedure DeletePaymentLine()
    var
        POSPaymentLine: Codeunit "NPR POS Payment Line";
        POSSession: Codeunit "NPR POS Session";
    begin
        POSSession.GetPaymentLine(POSPaymentLine);
        DeletePaymentLine(POSPaymentLine);
    end;

    internal procedure DeletePaymentLine(POSPaymentLine: Codeunit "NPR POS Payment Line")
    begin
        POSPaymentLine.RefreshCurrent();
        POSPaymentLine.DeleteLine();
    end;

    procedure DeleteSaleLine(var POSSaleLine: Codeunit "NPR POS Sale Line")
    begin
        HandleLinkedDocuments(POSSaleLine);
        DeleteAccessories(POSSaleLine);
        POSSaleLine.DeleteLine();
    end;

    local procedure HandleLinkedDocuments(POSSaleLine: Codeunit "NPR POS Sale Line")
    var
        LinePOS: Record "NPR POS Sale Line";
    begin
        POSSaleLine.GetCurrentSaleLine(LinePOS);
        RevertPrepaymentOnDocuments(LinePOS);
    end;

    local procedure RevertPrepaymentOnDocuments(SaleLinePOS: Record "NPR POS Sale Line")
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        if not SaleLinePOS."Sales Document Prepayment" then
            exit;

        if SalesHeader.Get(SaleLinePOS."Sales Document Type", SaleLinePOS."Sales Document No.") then begin
            SalesLine.SetHideValidationDialog(true);
            SalesLine.SuspendStatusCheck(true);
            SalesLine.SetRange("Document Type", SalesHeader."Document Type");
            SalesLine.SetRange("Document No.", SalesHeader."No.");
            if SalesLine.FindSet() then
                repeat
                    SalesLine.Validate("Prepmt. Line Amount", SalesLine."Prepmt. Amt. Inv.");
                    SalesLine.Modify();
                until SalesLine.Next() = 0;
        end;

    end;

    local procedure DeleteAccessories(POSSaleLine: Codeunit "NPR POS Sale Line")
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