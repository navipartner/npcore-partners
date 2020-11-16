page 6014563 "NPR TouchScreen: TicketReserv."
{
    Caption = 'Touch Screen - Ticket Reserv.';
    SourceTable = "NPR Ticket Access Cap. Slots";
    SourceTableTemporary = true;

    layout
    {
    }

    actions
    {
    }

    var
        TicketAccessCapacity: Record "NPR Ticket Access Cap. Slots";
        SalePOS: Record "NPR Sale POS";
        TicketAccessReservationMgt: Codeunit "NPR Ticket AccessReserv.Mgt";
        ShowDate: Date;
        ShowType: Code[20];
        OKPressed: Boolean;
        CancelPressed: Boolean;
        BtnTextForwad: Text[30];
        BtnTextBackward: Text[30];
        AvailableSlots: Decimal;
        CharForward: Char;
        CharBackward: Char;

    procedure Init(SalePOSIn: Record "NPR Sale POS"; TicketTypeIn: Code[10])
    begin
        SalePOS := SalePOSIn;
        ShowType := TicketTypeIn;
    end;

    procedure UpdateAvailable()
    begin
        if "Slot ID" = 0 then exit;
        TicketAccessCapacity.Get("Slot ID");
        TicketAccessCapacity.CalcFields("Quantity Reserved");
        AvailableSlots := TicketAccessCapacity.Quantity - TicketAccessCapacity."Quantity Reserved" - Quantity;
    end;

    procedure UpdateList()
    var
        AccessCapacity: Record "NPR Ticket Access Cap. Slots";
    begin
        DeleteAll;
        AccessCapacity.SetRange("Ticket Type Code", ShowType);
        AccessCapacity.SetRange("Access Date", ShowDate);
        if AccessCapacity.FindSet then
            repeat
                TransferFields(AccessCapacity);
                Quantity := 0;
                Insert;
            until AccessCapacity.Next = 0;

        BtnTextBackward := Format(CharBackward) + ' ' + Format(CalcDate('-1D', ShowDate));
        BtnTextForwad := Format(CalcDate('+1D', ShowDate)) + ' ' + Format(CharForward);

        //CurrForm.btnBack.ENABLED(CALCDATE('-1D',ShowDate) >= TODAY);
        if not (CalcDate('-1D', ShowDate) >= Today) then BtnTextBackward := '';
    end;

    procedure CreateReservations()
    begin
        SetFilter(Quantity, '>%1', 0);
        if FindSet then
            repeat
                TicketAccessReservationMgt
                  .CreateReservationsAsSingles("Ticket Type Code", "Slot ID",
                                               SalePOS."Customer No.", Quantity, SalePOS."Sales Ticket No.");
            until Next = 0;
    end;

    procedure GetReservations(var TempCapacitySlots: Record "NPR Ticket Access Cap. Slots" temporary)
    begin
        TempCapacitySlots.DeleteAll;
        if FindSet then
            repeat
                if "Slot ID" > 0 then begin
                    Clear(TempCapacitySlots);
                    TempCapacitySlots.TransferFields(Rec);
                    TempCapacitySlots.Insert;
                end;
            until Next = 0;
    end;

    procedure SetSalePOS(var SalePOSIn: Record "NPR Sale POS")
    begin
        SalePOS := SalePOSIn;
    end;

    procedure IsOkPressed(): Boolean
    begin
        exit(OKPressed);
    end;
}

