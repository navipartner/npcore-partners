codeunit 6184654 "NPR Tax Free Voucher On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        TaxFreeHandlerMgt: Codeunit "NPR Tax Free Handler Mgt.";
    begin
        TaxFreeHandlerMgt.IssueTaxFreeVoucher(Rec);
    end;

}