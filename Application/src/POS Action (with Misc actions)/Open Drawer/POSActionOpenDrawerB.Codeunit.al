codeunit 6150613 "NPR POS Action: Open Drawer B"
{
    Access = Internal;
    procedure OnActionOpenCashDrawer(Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup"; CashDrawerNo: Code[10])
    var
        SalePOS: Record "NPR POS Sale";
        POSUnit: Record "NPR POS Unit";
        RecID: RecordId;
    begin
        Sale.GetCurrentSale(SalePOS);
        RecID := SalePOS.RecordId;

        if (CashDrawerNo = '') then begin
            if POSUnit.Get(Setup.GetPOSUnitNo()) then begin
                CashDrawerNo := POSUnit."Default POS Payment Bin";
            end;
        end;

        OpenDrawer(CashDrawerNo, SalePOS);
    end;

    local procedure OpenDrawer(CashDrawerNo: Code[10]; SalePOS: Record "NPR POS Sale")
    var
        POSPaymentBin: Record "NPR POS Payment Bin";
        POSPaymentBinInvokeMgt: Codeunit "NPR POS Payment Bin Eject Mgt.";
    begin
        POSPaymentBin.Get(CashDrawerNo);
        POSPaymentBinInvokeMgt.EjectDrawer(POSPaymentBin, SalePOS, true);
    end;
}