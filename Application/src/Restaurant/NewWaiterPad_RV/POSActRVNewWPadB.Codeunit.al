codeunit 6151345 "NPR POSAct. RV New WPad-B"
{
    Access = Internal;

    procedure NewWaiterPad(Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup"; SeatingCode: Code[20]; CustomerDetails: Dictionary of [Text, Text]; NumberOfGuests: Integer; SwitchToSaleView: Boolean; var WaiterPad: Record "NPR NPRE Waiter Pad"; var RestaurantCode: Code[20])
    var
        Seating: Record "NPR NPRE Seating";
        SeatingLocation: Record "NPR NPRE Seating Location";
        SalePOS: Record "NPR POS Sale";
        WaiterPadMgt: Codeunit "NPR NPRE Waiter Pad Mgt.";
        NotValidSettingErr: Label 'The provided seating code "%1" is invalid. A new waiterpad was not created.';
    begin
        if not Seating.Get(SeatingCode) then begin
            Message(NotValidSettingErr, SeatingCode);
            exit;
        end;
        if NumberOfGuests < 0 then
            NumberOfGuests := 0;

        WaiterPadMgt.CreateNewWaiterPad(Seating.Code, NumberOfGuests, Setup.Salesperson(), CustomerDetails, WaiterPad);
        WaiterPad.SetRecFilter();

        SeatingLocation.Get(Seating."Seating Location");
        RestaurantCode := SeatingLocation."Restaurant Code";

        if SwitchToSaleView then begin
            Sale.GetCurrentSale(SalePOS);
            SalePOS.Find();
            SalePOS."NPRE Number of Guests" := NumberOfGuests;
            SalePOS."NPRE Pre-Set Waiter Pad No." := WaiterPad."No.";
            SalePOS.Validate("NPRE Pre-Set Seating Code", SeatingCode);
            Sale.Refresh(SalePOS);
            Sale.Modify(true, false);
        end;
    end;

    procedure CheckSeating(SeatingCode: Code[20])
    var
        Seating: Record "NPR NPRE Seating";
    begin
        Seating.Get(SeatingCode);
        Seating.TestField(Blocked, false);
    end;
}