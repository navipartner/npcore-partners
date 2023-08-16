codeunit 6151360 "NPR NPRE POSAction: Print WP-B"
{
    Access = Internal;

    procedure GetPresetValues(Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup"; var RestaurantCode: Code[20]; var SeatingCode: Code[20]; var WaiterPadNo: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        RestaurantCode := Setup.RestaurantCode();

        Sale.GetCurrentSale(SalePOS);
        if SalePOS."NPRE Pre-Set Seating Code" <> '' then begin
            Seating.Get(SalePOS."NPRE Pre-Set Seating Code");
            SeatingCode := SalePOS."NPRE Pre-Set Seating Code";
        end;

        if SalePOS."NPRE Pre-Set Waiter Pad No." <> '' then begin
            WaiterPad.Get(SalePOS."NPRE Pre-Set Waiter Pad No.");
            if SalePOS."NPRE Pre-Set Seating Code" <> '' then
                if not SeatingWaiterPadLink.Get(Seating.Code, WaiterPad."No.") then
                    WaiterPadMgt.AddNewWaiterPadForSeating(Seating.Code, WaiterPad, SeatingWaiterPadLink);
            WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, false);
            WaiterPadNo := SalePOS."NPRE Pre-Set Waiter Pad No.";
        end;
    end;

    procedure PrintWaiterPad(WaiterPadNo: Text)
    var
        WaiterPad: Record "NPR NPRE Waiter Pad";
        HospitalityPrint: Codeunit "NPR NPRE Restaurant Print";
    begin
        WaiterPad.Get(CopyStr(WaiterPadNo, 1, MaxStrLen(WaiterPad."No.")));
        HospitalityPrint.PrintWaiterPadPreReceiptPressed(WaiterPad);
    end;
}