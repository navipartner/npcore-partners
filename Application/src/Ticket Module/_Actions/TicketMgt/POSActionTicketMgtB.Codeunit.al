codeunit 6151431 "NPR POS Action - Ticket Mgt B."
{
    Access = Internal;

    procedure PickupPreConfirmedTicket(TicketReference: Code[30]; AllowPayment: Boolean)
    var
        PickUpReservedTickets: Page "NPR TM Pick-Up Reserv. Tickets";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        PageAction: Action;
        POSSaleLine: Codeunit "NPR POS Sale Line";
        SaleLinePos: Record "NPR POS Sale Line";
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReservationFound: Boolean;
        TICKET_REFERENCE: Label 'Ticket Reference';
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        MISSING_PAYMENT: Label 'Cannot pickup ticket. Reservation is missing payment';
        POSSession: Codeunit "NPR POS Session";
    begin
        if (TicketReference = '') then
            Error(ILLEGAL_VALUE, TicketReference, TICKET_REFERENCE);

        Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(Ticket."External Ticket No.")));
        if (Ticket.FindFirst()) then begin
            TicketReservationRequest.SetFilter("Entry No.", '=%1', Ticket."Ticket Reservation Entry No.");
            TicketReservationRequest.FindFirst();
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
            ReservationFound := TicketReservationRequest.FindFirst();
        end;

        if (not ReservationFound) then begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("External Order No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(TicketReservationRequest."External Order No.")));
            ReservationFound := TicketReservationRequest.FindFirst();
        end;

        if (not ReservationFound) then begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("External Member No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(TicketReservationRequest."External Member No.")));
            ReservationFound := TicketReservationRequest.FindFirst();
            if (not ReservationFound) then
                TicketReservationRequest.SetFilter("External Member No.", '<>%1', '');
        end;

        if (not GuiAllowed() and (not ReservationFound)) then
            Error(ILLEGAL_VALUE, TicketReference, TICKET_REFERENCE);

        if (GuiAllowed()) then begin
            // Confirm or select from list
            PickUpReservedTickets.SetTableView(TicketReservationRequest);

            PickUpReservedTickets.LookupMode(true);
            PageAction := PickUpReservedTickets.RunModal();
            if (PageAction <> Action::LookupOK) then
                exit;

            PickUpReservedTickets.GetRecord(TicketReservationRequest);
        end;

        // Create a pos sale line to finish the reservation
        if (TicketReservationRequest."Payment Option" = TicketReservationRequest."Payment Option"::UNPAID) then begin
            if not AllowPayment then begin
                Error(MISSING_PAYMENT);
            end;

            // Create a POS sales line which needs to be paid.
            POSSession.GetSaleLine(POSSaleLine);
            POSSaleLine.GetNewSaleLine(SaleLinePos);
            POSSaleLine.SetUsePresetLineNo(true);

            SaleLinePos."Line Type" := SaleLinePos."Line Type"::Item;
            SaleLinePos."No." := TicketReservationRequest."Item No.";
            SaleLinePos."Variant Code" := TicketReservationRequest."Variant Code";
            SaleLinePos.Quantity := TicketReservationRequest.Quantity;

            TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
            TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
            TicketReservationRequest2.ModifyAll("Receipt No.", SaleLinePos."Sales Ticket No.");
            TicketReservationRequest2.ModifyAll("Line No.", SaleLinePos."Line No.");
            TicketReservationRequest2.ModifyAll("Request Status", TicketReservationRequest2."Request Status"::RESERVED);

            POSSaleLine.InsertLine(SaleLinePos);
            exit;
        end;

        // Print this reservation
        TicketReservationRequest.Reset();
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
        TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);
        TicketReservationRequest.FindFirst();

        TicketReservationRequest.TestField("Admission Created", true);

        Ticket.Reset();
        Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
        TicketManagement.PrintTicketBatch(Ticket);

    end;

}