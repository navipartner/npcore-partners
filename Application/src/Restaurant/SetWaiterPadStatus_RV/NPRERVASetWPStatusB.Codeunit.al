codeunit 6151344 "NPR NPRE RVA: Set WP Status-B"
{
    Access = Internal;

    procedure SetWaiterPadStatus(Sale: Codeunit "NPR POS Sale"; WaiterPadNo: Code[20]; NewStatusCode: Code[10]; var ResultMessageText: Text)
    var
        FlowStatus: Record "NPR NPRE Flow Status";
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        RestaurantPrint: Codeunit "NPR NPRE Restaurant Print";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WPadNotSelectedErr: Label 'Please select a waiter pad first.';
    begin
        if WaiterPadNo = '' then begin
            Sale.GetCurrentSale(SalePOS);
            if SalePOS."NPRE Pre-Set Waiter Pad No." = '' then
                Error(WPadNotSelectedErr);
            WaiterPadNo := SalePOS."NPRE Pre-Set Waiter Pad No.";
        end;
        WaiterPad."No." := WaiterPadNo;
        WaiterPad.Find();

        FlowStatus.SetRange("Status Object", FlowStatus."Status Object"::WaiterPad, FlowStatus."Status Object"::WaiterPadLineMealFlow);
        FlowStatus.SetRange(Code, NewStatusCode);
        FlowStatus.FindFirst();
        if FlowStatus."Status Object" = FlowStatus."Status Object"::WaiterPadLineMealFlow then
            ResultMessageText := RestaurantPrint.RequestRunServingStepToKitchen(WaiterPad, false, NewStatusCode)
        else
            if WaiterPadMgt.SetWaiterPadStatus(WaiterPad, NewStatusCode) then
                WaiterPad.Modify();
    end;
}