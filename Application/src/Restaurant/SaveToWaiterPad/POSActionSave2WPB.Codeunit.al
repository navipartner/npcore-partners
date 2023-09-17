codeunit 6151361 "NPR POSAction: Save2WP-B"
{
    Access = Internal;

    procedure GetPresetValues(Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup"; var RestaurantCode: Code[20]; var SeatingCode: Code[20]; var WaiterPadNo: Code[20])
    var
        SalePOS: Record "NPR POS Sale";
        Seating: Record "NPR NPRE Seating";
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
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
            WaiterPadNo := SalePOS."NPRE Pre-Set Waiter Pad No.";
        end;
    end;

    procedure GetSeatingConfirmString(Seating: Record "NPR NPRE Seating") ConfirmString: Text
    var
        SeatingWaiterPadLink: Record "NPR NPRE Seat.: WaiterPadLink";
        NoWaiterPadOnSeatingQst: Label 'There are no open waiter pads exist for seating %1. Do you want to create a new one?';
    begin
        SeatingWaiterPadLink.SetRange(Closed, false);
        SeatingWaiterPadLink.SetRange("Seating Code", Seating.Code);
        if not SeatingWaiterPadLink.IsEmpty() then
            exit('');

        ConfirmString := StrSubstNo(NoWaiterPadOnSeatingQst, Seating.Code);
        exit(ConfirmString);
    end;

    procedure SaveSale2WPad(Sale: Codeunit "NPR POS Sale"; WaiterPadNo: Code[20]; OpenWaiterPad: Boolean; var SaleCleanupSuccessful: Boolean)
    var
        SalePOS: Record "NPR POS Sale";
        WaiterPad: Record "NPR NPRE Waiter Pad";
        WaiterPadPOSMgt: Codeunit "NPR NPRE Waiter Pad POS Mgt.";
    begin
        WaiterPad.Get(WaiterPadNo);
        Sale.GetCurrentSale(SalePOS);
        SaleCleanupSuccessful := WaiterPadPOSMgt.MoveSaleFromPOSToWaiterPad(SalePOS, WaiterPad, true);
        Sale.Refresh(SalePOS);
        Sale.Modify(true, false);
        Commit();

        if OpenWaiterPad then
            WaiterPadPOSMgt.UIShowWaiterPad(WaiterPad);
    end;
}