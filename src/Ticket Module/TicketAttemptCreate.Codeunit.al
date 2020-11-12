codeunit 6014491 "NPR Ticket Attempt Create"
{
    SingleInstance = true;

    trigger OnRun()
    begin
        case _AttemptFunction of
            _AttemptFunction::TICKET_REUSE:
                DoRevalidateRequestForTicketReuse(_TmpTicketReservationRequest, _ReusedTokenId, _ResponseMessage);
        end;
    end;

    var
        _TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary;
        _ReusedTokenId: Text;
        _ResponseMessage: Text;
        _AttemptFunction: Option NA,TICKET_REUSE;

    procedure RevalidateRequestForTicketReuse(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary; var ReusedTokenId: Text; var ResponseMessage: Text): Boolean
    var
        TicketAttemptCreate: Codeunit "NPR Ticket Attempt Create";
    begin

        _TmpTicketReservationRequest.Copy(TmpTicketReservationRequest, true);
        _AttemptFunction := _AttemptFunction::TICKET_REUSE;

        exit(TicketAttemptCreate.Run());

    end;

    local procedure DoRevalidateRequestForTicketReuse(var TmpTicketReservationRequest: Record "NPR TM Ticket Reservation Req." temporary; var ReusedTokenId: Text; var ResponseMessage: Text)
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        IsRepeatedEntry: Boolean;
        AbortTicketRevalidate: Boolean;
    begin

        // Precheck if member has tickets for today with same item numbers and qty. If so try to reuse those tickets.
        IsRepeatedEntry := true;

        TmpTicketReservationRequest.Reset;
        TmpTicketReservationRequest.FindSet();

        repeat

            TicketReservationRequest.SetFilter("Item No.", '=%1', TmpTicketReservationRequest."Item No.");
            TicketReservationRequest.SetFilter("Variant Code", '=%1', TmpTicketReservationRequest."Variant Code");

            TicketReservationRequest.SetFilter("External Member No.", '=%1', TmpTicketReservationRequest."External Member No.");
            TicketReservationRequest.SetFilter("Created Date Time", '%1..%2', CreateDateTime(Today, 0T), CreateDateTime(Today, 235959T));
            TicketReservationRequest.SetFilter(Quantity, '=%1', TmpTicketReservationRequest.Quantity);

            IsRepeatedEntry := (IsRepeatedEntry and (TmpTicketReservationRequest."External Member No." <> ''));
            IsRepeatedEntry := (IsRepeatedEntry and TicketReservationRequest.FindLast());
            if (IsRepeatedEntry) then
                TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");

        until (TmpTicketReservationRequest.Next() = 0);

        if (IsRepeatedEntry) then begin

            TicketReservationRequest.Reset();
            TicketReservationRequest.SetCurrentKey("Session Token ID");
            TicketReservationRequest.SetFilter("Session Token ID", '=%1', TicketReservationRequest."Session Token ID");
            if (TicketReservationRequest.FindSet()) then begin
                AbortTicketRevalidate := false;

                repeat
                    Ticket.SetCurrentKey("Ticket Reservation Entry No.");
                    Ticket.SetFilter("Ticket Reservation Entry No.", '=%1', TicketReservationRequest."Entry No.");
                    if (Ticket.FindSet()) then begin
                        repeat
                            AbortTicketRevalidate := (0 <> TicketManagement.ValidateTicketForArrival(0, Ticket."No.", '', 0, true, ResponseMessage));
                        until ((Ticket.Next() = 0) or (AbortTicketRevalidate));
                    end;
                until ((TicketReservationRequest.Next() = 0) or (AbortTicketRevalidate));

                if (not AbortTicketRevalidate) then begin
                    ReusedTokenId := TicketReservationRequest."Session Token ID";
                    exit; // Arrival was successfully registered on tickets previously created - we are done
                end;

            end;
        end;

        Error('Member does not have a previous ticket request that matches the current request. Ticket reuse is not possible.');

    end;


}