codeunit 6059843 "NPR POS Payment Bin"
{
    Access = Public;

    procedure EjectDrawer(POSPaymentBin: Record "NPR POS Payment Bin"; SalePOS: Record "NPR POS Sale"; ManualOpen: Boolean): Boolean
    var
        POSPaymentBinEjectMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        exit(POSPaymentBinEjectMgt.EjectDrawer(POSPaymentBin, SalePOS, ManualOpen));
    end;
}