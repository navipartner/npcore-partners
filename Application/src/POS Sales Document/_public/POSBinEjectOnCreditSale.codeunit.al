codeunit 6184665 "NPR POS Bin Eject OnCreditSale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        POSPaymentBinEjectMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        POSPaymentBinEjectMgt.EjectPaymeBinOnCreditSale(Rec);
    end;
}