codeunit 6151431 "NPR POS Action - Ticket Mgt B."
{
    Access = Internal;

    internal procedure PickupPreConfirmedTicket(TicketReference: Code[50]; AllowPayment: Boolean; AllowUI: Boolean; AllowReprint: Boolean)
    var
        TempTicketsOut: Record "NPR TM Ticket" temporary;
    begin
        PickupPreConfirmedTicket(TicketReference, AllowPayment, AllowUI, AllowReprint, TempTicketsOut);
    end;

    internal procedure PickupPreConfirmedTicket(TicketReference: Code[50]; AllowPayment: Boolean; AllowUI: Boolean; AllowReprint: Boolean; var TempTickets: Record "NPR TM Ticket" temporary)
    var
        PickUpReservedTickets: Page "NPR TM Pick-Up Reserv. Tickets";
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        PageAction: Action;
        Ticket: Record "NPR TM Ticket";
        ReservationFound: Boolean;
        TICKET_REFERENCE: Label 'Ticket Reference';
        ILLEGAL_VALUE: Label 'Value %1 is not a valid %2.';
        MISSING_PAYMENT: Label 'Cannot pickup ticket. Reservation is missing payment';
        ConfirmPrintAll: Label 'Print all %1 ticket?';
        ListOfTokens: List of [Text[100]];
    begin
        if (not AllowUI) and (TicketReference = '') then
            Error('');

        ReservationFound := false;
        if (TicketReference <> '') then begin
            Ticket.SetFilter("External Ticket No.", '=%1', CopyStr(TicketReference, 1, MaxStrLen(Ticket."External Ticket No.")));
            if (Ticket.FindFirst()) then begin
                TicketReservationRequest.SetFilter("Entry No.", '=%1', Ticket."Ticket Reservation Entry No.");
                TicketReservationRequest.FindFirst();
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                ReservationFound := TicketReservationRequest.FindFirst();
                if (ReservationFound) then
                    ListOfTokens.Add(TicketReservationRequest."Session Token ID");
            end;

            if (not ReservationFound) then begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetCurrentKey("External Order No.");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', CopyStr(TicketReference, 1, MaxStrLen(TicketReservationRequest."Session Token ID")));
                ReservationFound := TicketReservationRequest.FindFirst();
                if (ReservationFound) then
                    ListOfTokens.Add(TicketReservationRequest."Session Token ID");
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
                if (ReservationFound) then
                    ListOfTokens.Add(TicketReservationRequest."Session Token ID");
            end;
        end;

        if (not AllowUI) then begin
            if (not ReservationFound) then
                Error(ILLEGAL_VALUE, TicketReference, TICKET_REFERENCE);

            GetTickets(ListOfTokens, TempTickets);
            PrintTickets(TempTickets, AllowReprint);
            exit;
        end;

        if (AllowUI) then begin
            if (ListOfTokens.Count() = 0) then begin
                // Select token from list 
                TicketReservationRequest.Reset();
                PickUpReservedTickets.SetTableView(TicketReservationRequest);

                PickUpReservedTickets.LookupMode(true);
                PageAction := PickUpReservedTickets.RunModal();
                if (PageAction <> Action::LookupOK) then
                    exit;

                PickUpReservedTickets.GetRecord(TicketReservationRequest);
                if (not ListOfTokens.Contains(TicketReservationRequest."Session Token ID")) then
                    ListOfTokens.Add(TicketReservationRequest."Session Token ID");
            end;

            // if token is unpaid create pos sale lines to finish the reservation
            if (TicketReservationRequest."Payment Option" = TicketReservationRequest."Payment Option"::UNPAID) then begin
                if (not AllowPayment) then
                    Error(MISSING_PAYMENT);
                AddToPOS(ListOfTokens);
                exit; // Printing by end-of-sale routine
            end;

            // show list of tickets included on token
            GetTickets(ListOfTokens, TempTickets);
            if (TempTickets.Count() = 0) then
                exit;

            if (not Confirm(ConfirmPrintAll, true, TempTickets.Count())) then begin
                Page.Run(Page::"NPR TM Ticket List", TempTickets);
                exit;
            end;

            PrintTickets(TempTickets, AllowReprint);
        end;
    end;

    local procedure PrintTickets(var TempTickets: Record "NPR TM Ticket" temporary; AllowReprint: Boolean)
    var
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ReprintNotAllowed: Label 'Your order needs to be handled by customer services.';
    begin
        TempTickets.Reset();
        if (TempTickets.IsEmpty()) then
            exit;

        if (not AllowReprint) then
            TempTickets.SetFilter("Printed Date", '=%1', 0D);

        if (not TempTickets.FindSet()) then
            if (not AllowReprint) then
                Error(ReprintNotAllowed);

        repeat
            Ticket.Reset();
            Ticket.Get(TempTickets."No.");
            Ticket.SetRecFilter();
            TicketManagement.PrintTicketBatch(Ticket);
        until (TempTickets.Next() = 0);

    end;

    local procedure GetTickets(ListOfTokens: List of [Text[100]]; var TempTicketsOut: Record "NPR TM Ticket" temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        Token: Text[100];
    begin
        foreach Token in ListOfTokens do begin
            TicketReservationRequest.Reset();
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
            if (TicketReservationRequest.FindSet()) then
                repeat
                    Ticket.Reset();
                    Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                    if (Ticket.FindSet()) then
                        repeat
                            TempTicketsOut.TransferFields(Ticket, true);
                            if (not TempTicketsOut.Insert()) then;
                        until (Ticket.Next() = 0);
                until (TicketReservationRequest.Next() = 0);
        end;
    end;

    local procedure AddToPOS(ListOfTokens: List of [Text[100]])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        TicketReservationRequest2: Record "NPR TM Ticket Reservation Req.";
        POSSaleLine: Codeunit "NPR POS Sale Line";
        POSSession: Codeunit "NPR POS Session";
        SaleLinePos: Record "NPR POS Sale Line";
        ListOfTicketSets: List of [Integer];
        Token: Text[100];
        TicketSetId: Integer;
    begin
        foreach Token in ListOfTokens do begin
            Clear(ListOfTicketSets);
            GetTicketSets(Token, ListOfTicketSets);

            foreach TicketSetId in ListOfTicketSets do begin
                TicketReservationRequest.Reset();
                TicketReservationRequest.SetCurrentKey("Session Token ID");
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
                TicketReservationRequest.SetFilter("Ext. Line Reference No.", '=%1', TicketSetId);
                TicketReservationRequest.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::REQUIRED);
                TicketReservationRequest.FindFirst();

                // Create POS sales lines which needs to be paid.
                POSSession.GetSaleLine(POSSaleLine);
                POSSaleLine.GetNewSaleLine(SaleLinePos);
                POSSaleLine.SetUsePresetLineNo(true);

                SaleLinePos."Line Type" := SaleLinePos."Line Type"::Item;
                SaleLinePos."No." := TicketReservationRequest."Item No.";
                SaleLinePos."Variant Code" := TicketReservationRequest."Variant Code";
                SaleLinePos.Quantity := TicketReservationRequest.Quantity;
                POSSaleLine.InsertLine(SaleLinePos);

                TicketReservationRequest.SetFilter("Admission Inclusion", '=%1', TicketReservationRequest."Admission Inclusion"::SELECTED);
                if (TicketReservationRequest.FindSet()) then begin
                    repeat
                        // Create POS sales lines for additional admissions that needs to be paid.
                        POSSession.GetSaleLine(POSSaleLine);
                        POSSaleLine.GetNewSaleLine(SaleLinePos);
                        POSSaleLine.SetUsePresetLineNo(true);

                        SaleLinePos."Line Type" := SaleLinePos."Line Type"::Item;
                        SaleLinePos."No." := TicketReservationRequest."Item No.";
                        SaleLinePos."Variant Code" := TicketReservationRequest."Variant Code";
                        SaleLinePos.Quantity := TicketReservationRequest.Quantity;
                        POSSaleLine.InsertLine(SaleLinePos);
                    until (TicketReservationRequest.Next() = 0);
                end;

                TicketReservationRequest2.SetCurrentKey("Session Token ID");
                TicketReservationRequest2.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
                TicketReservationRequest2.SetFilter("Ext. Line Reference No.", '=%1', TicketReservationRequest."Ext. Line Reference No.");
                TicketReservationRequest2.ModifyAll("Receipt No.", SaleLinePos."Sales Ticket No.");
                TicketReservationRequest2.ModifyAll("Line No.", SaleLinePos."Line No.");
                TicketReservationRequest2.ModifyAll("Request Status", TicketReservationRequest2."Request Status"::RESERVED);
            end;
        end;
    end;

    local procedure GetTicketSets(Token: Text[100]; TicketSet: List of [Integer])
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', Token);
        if (TicketReservationRequest.FindSet()) then begin
            repeat
                if (not TicketSet.Contains(TicketReservationRequest."Ext. Line Reference No.")) then
                    TicketSet.Add(TicketReservationRequest."Ext. Line Reference No.");
            until (TicketReservationRequest.Next() = 0);
        end;
    end;

    internal procedure GetTicketsFromOrderReference(OrderReference: Code[50]; var TempTickets: Record "NPR TM Ticket" temporary)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
    begin
        if (not TempTickets.IsTemporary()) then
            Error('Parameter TempTickets is not declared temporary. This is a programming error.');

        TicketReservationRequest.Reset();
        TicketReservationRequest.SetCurrentKey("External Order No.");
        TicketReservationRequest.SetFilter("External Order No.", '=%1', CopyStr(OrderReference, 1, MaxStrLen(TicketReservationRequest."External Order No.")));
        if (TicketReservationRequest.FindSet()) then
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

        TicketReservationRequest.SetCurrentKey("External Order No.");
        TicketReservationRequest.SetFilter("External Order No.", '=%1', CopyStr(OrderReference, 1, MaxStrLen(TicketReservationRequest."External Order No.")));
        if (TicketReservationRequest.FindSet()) then
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

        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', CopyStr(OrderReference, 1, MaxStrLen(TicketReservationRequest."Session Token ID")));
        if (TicketReservationRequest.FindSet()) then
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