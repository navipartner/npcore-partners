codeunit 6151345 "NPR POSAct. RV New WPad-B"
{
    Access = Internal;

    procedure NewWaiterPad(Sale: Codeunit "NPR POS Sale"; Setup: Codeunit "NPR POS Setup"; SeatingCode: Code[20]; Description: Text; NumberOfGuests: Integer; SwitchToSaleView: Boolean; var WaiterPad: Record "NPR NPRE Waiter Pad"; var RestaurantCode: Code[20])
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

        WaiterPadMgt.CreateNewWaiterPad(Seating.Code, NumberOfGuests, Setup.Salesperson(), Description, WaiterPad);
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

    procedure GetDefaultNumberOfGuests(SeatingCode: Code[20]): Integer
    var
        Seating: Record "NPR NPRE Seating";
        SetupProxy: Codeunit "NPR NPRE Restaur. Setup Proxy";
    begin
        SetupProxy.SetSeating(SeatingCode);
        case SetupProxy.DefaultNumberOfGuests() of
            Enum::"NPR NPRE Default No. of Guests"::Zero:
                exit(0);
            Enum::"NPR NPRE Default No. of Guests"::"Min Party Size":
                begin
                    Seating.Get(SeatingCode);
                    exit(Seating."Min Party Size");
                end;
        end;
        exit(1);
    end;
}