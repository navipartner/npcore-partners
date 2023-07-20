codeunit 6151371 "NPR SS Action: Delete POSLineB"
{
    Access = Internal;

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