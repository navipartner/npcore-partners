codeunit 6151374 "NPR POSAct. SS Qty Decrease B"
{
    Access = Internal;
    internal procedure DecreaseSalelineQuantity(DecreaseBy: Decimal; SaleLine: codeunit "NPR POS Sale Line")
    var
        SaleLinePOS: Record "NPR POS Sale Line";
        QuantityErr: Label 'This is a programming error. Please contact system vendor.';
    begin
        // This function should be "not local", so test framework can invoke it
        If DecreaseBy < 0 then
            Error(QuantityErr);
        SaleLine.GetCurrentSaleLine(SaleLinePOS);

        if (SaleLinePOS.Quantity - DecreaseBy < 0) then
            SaleLine.SetQuantity(0)
        else
            SaleLine.SetQuantity(SaleLinePOS.Quantity - DecreaseBy);
    end;
}