codeunit 6151337 "NPR NPRE RVA: Set R-View-B"
{
    Access = Internal;

    procedure SaveToWaiterPad(var SalePOS: Record "NPR POS Sale"; var ResultMessageText: Text) SaleCleanupSuccessful: Boolean
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        NPREWaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then
            exit(true);

        WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
        SaleCleanupSuccessful := NPREWaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);
        if not SaleCleanupSuccessful then
            ResultMessageText := NPREWaiterPadPOSMgt.UnableToCleanupSaleMsgText(false);
    end;
}