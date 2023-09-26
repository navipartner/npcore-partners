codeunit 6151431 "NPR POS Action - Ticket Mgt B."
{
    Access = Internal;

    internal procedure PickupPreConfirmedTicket(TicketReference: Code[30]; AllowPayment: Boolean; AllowUI: Boolean; AllowReprint: Boolean)
    var
        TempTicketsOut: Record "NPR TM Ticket" temporary;
    begin
        PickupPreConfirmedTicket(TicketReference, AllowPayment, AllowUI, AllowReprint, TempTicketsOut);
    end;

    internal procedure PickupPreConfirmedTicket(TicketReference: Code[30]; AllowPayment: Boolean; AllowUI: Boolean; AllowReprint: Boolean; var TempTicketsOut: Record "NPR TM Ticket" temporary)
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
        AlreadyPrinted: Label 'Tickets with reference %1 has already been picked-up.';
        POSSession: Codeunit "NPR POS Session";
        ListOfTokens: List of [Text[100]];
        Token: Text[100];
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
            TicketReservationRequest.SetCurrentKey("External Order No.");
            TicketReservationRequest.SetFilter("External Order No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(TicketReservationRequest."External Order No.")));
            ReservationFound := TicketReservationRequest.FindSet();
            if (ReservationFound) then
                repeat
                    if (not ListOfTokens.Contains(TicketReservationRequest."Session Token ID")) then
                        ListOfTokens.Add(TicketReservationRequest."Session Token ID");
                until (TicketReservationRequest.Next() = 0);
        end;

        if (not ReservationFound) then begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("External Member No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(TicketReservationRequest."External Member No.")));
            ReservationFound := TicketReservationRequest.FindLast();
            if (not ReservationFound) then
                TicketReservationRequest.SetFilter("External Member No.", '<>%1', '');
        end;

        if (not ReservationFound) then
            if (not AllowUI) then
                Error(ILLEGAL_VALUE, TicketReference, TICKET_REFERENCE);

        if (AllowUI) then begin
            Clear(ListOfTokens);
            // Confirm or select from list
            PickUpReservedTickets.SetTableView(TicketReservationRequest);

            PickUpReservedTickets.LookupMode(true);
            PageAction := PickUpReservedTickets.RunModal();
            if (PageAction <> Action::LookupOK) then
                exit;

            PickUpReservedTickets.GetRecord(TicketReservationRequest);
            if (not ListOfTokens.Contains(TicketReservationRequest."Session Token ID")) then
                ListOfTokens.Add(TicketReservationRequest."Session Token ID");

            // Create a pos sale line to finish the reservation
            if (TicketReservationRequest."Payment Option" = TicketReservationRequest."Payment Option"::UNPAID) then begin
                if (not AllowPayment) then begin
                    Error(MISSING_PAYMENT);
                end;

                foreach Token in ListOfTokens do begin
                    TicketReservationRequest.Reset();
                    TicketReservationRequest.SetCurrentKey("Session Token ID");
                    TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                    TicketReservationRequest.SetFilter("Primary Request Line", '=%1', true);

                    // Create POS sales lines which needs to be paid.
                    POSSession.GetSaleLine(POSSaleLine);
                    POSSaleLine.GetNewSaleLine(SaleLinePos);
                    POSSaleLine.SetUsePresetLineNo(true);

                    SaleLinePos."Line Type" := SaleLinePos."Line Type"::Item;
                    SaleLinePos."No." := TicketReservationRequest."Item No.";
                    SaleLinePos."Variant Code" := TicketReservationRequest."Variant Code";
                    SaleLinePos.Quantity := TicketReservationRequest.Quantity;
                    POSSaleLine.InsertLine(SaleLinePos);

                    TicketReservationRequest2.SetCurrentKey("Session Token ID");
                    TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                    TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
                    TicketReservationRequest2.ModifyAll("Receipt No.", SaleLinePos."Sales Ticket No.");
                    TicketReservationRequest2.ModifyAll("Line No.", SaleLinePos."Line No.");
                    TicketReservationRequest2.ModifyAll("Request Status", TicketReservationRequest2."Request Status"::RESERVED);
                end;
                exit; // Printing by end-of-sale routine
            end;
        end;

        // Print the ticket set for each token
        foreach Token in ListOfTokens do begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            TicketReservationRequest.FindSet();
            repeat
                Ticket.Reset();
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                if (not AllowReprint) then begin
                    Ticket.SetFilter("Printed Date", '=%1', 0D);
                    if (Ticket.IsEmpty()) then
                        Error(AlreadyPrinted, TicketReference);
                end;

                if (not Ticket.IsEmpty()) then
                    TicketManagement.PrintTicketBatch(Ticket);

                // Don't trust filter returned from PrintTicketBatch
                Ticket.Reset();
                Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                if (Ticket.FindSet()) then begin
                    repeat
                        TempTicketsOut.TransferFields(Ticket, true);
                        if (not TempTicketsOut.Insert()) then;
                    until (Ticket.Next() = 0);
                end;

            until (TicketReservationRequest.Next() = 0);
        end;

    end;

    internal procedure GetTicketsFromOrderReference(OrderReference: Code[20]; var TempTickets: Record "NPR TM Ticket" temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        if (not TempTickets.IsTemporary()) then
            Error('Parameter TempTickets is not declared temporary. This is a programming error.');

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("External Order No.");
        TicketReservationRequest.SetFilter("External Order No.", '=%1', OrderReference);
        if (not TicketReservationRequest.FindSet()) then
            exit;

        repeat
            Ticket.Reset();
            Ticket.SetCurrentKey("Ticket Reservation Entry No.");
            Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
            if (Ticket.FindSet()) then begin
                repeat
                    TempTickets.TransferFields(Ticket, true);
                    TempTickets.Insert();
                until (Ticket.Next() = 0);
            end;

        until (TicketReservationRequest.Next() = 0);
    end;

}