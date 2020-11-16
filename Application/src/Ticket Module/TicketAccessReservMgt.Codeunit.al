codeunit 6059788 "NPR Ticket AccessReserv.Mgt"
{
    TableNo = "NPR Sale POS";

    trigger OnRun()
    begin
        OpenTicketAccReservForm(Rec, Parameters);
    end;

    procedure ClearReservations(SalesTicketNo: Code[20]; TicketTypeCode: Code[20])
    var
        AccessReservation: Record "NPR Ticket Access Reserv.";
    begin
        AccessReservation.SetCurrentKey("Sales Ticket No.");
        AccessReservation.SetRange("Sales Ticket No.", SalesTicketNo);
        AccessReservation.SetRange("Ticket Type Code", TicketTypeCode);
        AccessReservation.DeleteAll;
    end;

    procedure ClearSalesLineReservations(SalePOS: Record "NPR Sale POS"; ItemNo: Code[20])
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        TicketType: Record "NPR TM Ticket Type";
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        SaleLinePOS.SetRange("Sale Type", SaleLinePOS."Sale Type"::Sale);
        SaleLinePOS.SetRange(Type, SaleLinePOS.Type::Item);
        SaleLinePOS.SetRange("No.", ItemNo);
        SaleLinePOS.DeleteAll;
    end;

    procedure CreateReservationEntry(TicketTypeCode: Code[20]; TicketAccessCapacitySlotID: Integer; CustomerNo: Code[20]; Quantity: Decimal; SalesTicketNo: Code[20])
    var
        AccessReservation: Record "NPR Ticket Access Reserv.";
    begin
        Clear(AccessReservation);
        AccessReservation.Init;
        AccessReservation.Validate("Ticket Type Code", TicketTypeCode);
        AccessReservation.Validate("Ticket Access Capacity Slot ID", TicketAccessCapacitySlotID);
        AccessReservation."Customer No." := CustomerNo;
        AccessReservation.Quantity := Quantity;
        AccessReservation."Sales Ticket No." := SalesTicketNo;
        AccessReservation.Insert(true);
    end;

    procedure CreateReservationEntryAsGroup(TicketTypeCode: Code[20]; TicketAccessCapacitySlotID: Integer; CustomerNo: Code[20]; Quantity: Decimal; SalesTicketNo: Code[20])
    begin
        CreateReservationEntry(TicketTypeCode, TicketAccessCapacitySlotID, CustomerNo, Quantity, SalesTicketNo);
    end;

    procedure CreateReservationsAsSingles(TicketTypeCode: Code[20]; TicketAccessCapacitySlotID: Integer; CustomerNo: Code[20]; Quantity: Decimal; SalesTicketNo: Code[20])
    var
        AccessReservation: Record "NPR Ticket Access Reserv.";
        SalePOS: Record "NPR Sale POS";
        ReserveNo: Integer;
    begin
        for ReserveNo := 1 to Quantity do begin
            CreateReservationEntry(TicketTypeCode, TicketAccessCapacitySlotID, CustomerNo, 1, SalesTicketNo);
        end;
    end;

    procedure CreateReservationSalesLine(Quantity: Decimal; SalePOS: Record "NPR Sale POS"; TicketItemNo: Code[20]; Description: Text[50])
    var
        SaleLinePOS: Record "NPR Sale Line POS";
        LineNo: Integer;
    begin
        SaleLinePOS.SetRange("Register No.", SalePOS."Register No.");
        SaleLinePOS.SetRange("Sales Ticket No.", SalePOS."Sales Ticket No.");
        if SaleLinePOS.FindLast then
            LineNo := SaleLinePOS."Line No." + 10000
        else
            LineNo := 10000;

        SaleLinePOS.Init;
        SaleLinePOS.Validate("Register No.", SalePOS."Register No.");
        SaleLinePOS."Sales Ticket No." := SalePOS."Sales Ticket No.";
        SaleLinePOS.Date := Today;
        SaleLinePOS."Sale Type" := SaleLinePOS."Sale Type"::Sale;
        SaleLinePOS."Line No." := LineNo;
        SaleLinePOS.Type := SaleLinePOS.Type::Item;
        SaleLinePOS.Validate("No.", TicketItemNo);
        SaleLinePOS.Validate(Quantity, Quantity);
        if Description <> '' then
            SaleLinePOS.Description += ' ' + Description;
        SaleLinePOS.Insert(true);
    end;

    procedure "-- Prints --"()
    begin
    end;

    procedure PrintRsvFromSalesTicketNo(SalesTicketNo: Code[20])
    var
        TicketAccessReservation: Record "NPR Ticket Access Reserv.";
    begin
        TicketAccessReservation.SetRange("Sales Ticket No.", SalesTicketNo);
        if TicketAccessReservation.FindSet then
            PrintReservation(TicketAccessReservation);
    end;

    procedure PrintReservation(var TicketAccessReservation: Record "NPR Ticket Access Reserv.")
    var
        TicketType: Record "NPR TM Ticket Type";
        StdCodeunitCode: Codeunit "NPR Std. Codeunit Code";
    begin
        TicketType.SetRange("Print Ticket", true);
        TicketType.SetRange("Is Reservation", true);
        if TicketType.FindSet then
            repeat
                TicketAccessReservation.SetRange("Ticket Type Code", TicketType.Code);
                if TicketType."Print Ticket" then begin
                    case TicketType."Print Object Type" of
                        TicketType."Print Object Type"::CODEUNIT:
                            CODEUNIT.Run(TicketType."Print Object ID", TicketAccessReservation);
                        TicketType."Print Object Type"::REPORT:
                            REPORT.Run(TicketType."Print Object ID", false, false, TicketAccessReservation);
                    end;
                end;
            until TicketAccessReservation.Next = 0;
    end;

    procedure "-- UI --"()
    begin
    end;

    procedure OpenTicketAccReservForm(SalePOS: Record "NPR Sale POS"; ItemNo: Code[20])
    var
        Item: Record Item;
        TicketAccessReservatation: Record "NPR Ticket Access Reserv.";
        TempCapacitySlots: Record "NPR Ticket Access Cap. Slots" temporary;
        TicketType: Record "NPR TM Ticket Type";
        TicketReservForm: Page "NPR TouchScreen: TicketReserv.";
    begin
        Item.Get(ItemNo);
        ClearReservations(SalePOS."Sales Ticket No.", Item."NPR Ticket Type");
        ClearSalesLineReservations(SalePOS, ItemNo);
        TicketReservForm.Init(SalePOS, Item."NPR Ticket Type");

        Commit;

        if (TicketReservForm.RunModal = ACTION::LookupOK) or
           (TicketReservForm.IsOkPressed) then begin
            TicketReservForm.GetReservations(TempCapacitySlots);
            TempCapacitySlots.SetFilter(Quantity, '>%1', 0);
            if TempCapacitySlots.FindSet then
                repeat
                    CreateReservationsAsSingles(Item."NPR Ticket Type", TempCapacitySlots."Slot ID", SalePOS."Customer No.",
                                                TempCapacitySlots.Quantity, SalePOS."Sales Ticket No.");
                    CreateReservationSalesLine(TempCapacitySlots.Quantity, SalePOS, ItemNo,
                                               TicketType.Description);
                until TempCapacitySlots.Next = 0;
        end;
    end;
}

