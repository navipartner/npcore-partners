codeunit 6151364 "NPR POS Action: PrintExchLbl-B"
{
    Access = Internal;

    var
        CannotbeNegErr: Label 'cannot be negative';

    internal procedure CheckPreventNegativeQty(POSSession: Codeunit "NPR POS Session")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        POSSaleLine: Codeunit "NPR POS Sale Line";
    begin
        POSSession.GetSaleLine(POSSaleLine);
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);
        if SaleLinePOS.Quantity < 0 then
            SaleLinePOS.FieldError(Quantity, CannotbeNegErr);
    end;

    internal procedure PrintLabelsFromPOS(PrintType: Option Single,LineQuantity,All,Selection,Package; var SaleLinePOS: Record "NPR POS Sale Line"; ValidFromDate: Date)
    var
        ExchangeLabelMgt: Codeunit "NPR Exchange Label Mgt.";
    begin
        ExchangeLabelMgt.PrintLabelsFromPOSWithoutPrompts(PrintType, SaleLinePOS, ValidFromDate);
    end;

    internal procedure CheckPreventNegativeQty(SaleLinePOS: Record "NPR POS Sale Line")
    begin
        if (SaleLinePOS.Quantity < 0) then
            SaleLinePOS.FieldError(Quantity, CannotbeNegErr);
    end;
}
