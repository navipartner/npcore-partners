codeunit 6184649 "NPR Eject Payment Bin On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        POSPaymentBinEjectMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        POSPaymentBinEjectMgt.CarryOutPaymentBinEject(Rec, false);
    end;
}