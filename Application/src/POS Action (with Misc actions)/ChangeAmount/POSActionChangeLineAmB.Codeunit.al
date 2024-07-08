codeunit 6151332 "NPR POS Action:Change LineAm B"
{
    Access = Internal;
    procedure ChangeAmount(LineAmount: Decimal; POSSaleLine: codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        NoSaleLineErr: Label 'A sale line must exist in order to change the amount';
    begin
        POSSaleLine.GetCurrentSaleLine(SaleLinePOS);

        if SaleLinePOS.IsEmpty then
            Error(NoSaleLineErr);

        SaleLinePOS.Validate("Amount Including VAT", LineAmount);
        SaleLinePOS.Modify();

        POSSaleLine.ResendAllOnAfterInsertPOSSaleLine();
    end;
}