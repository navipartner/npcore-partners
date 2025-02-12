#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185082 "NPR TicketingApiHandler"
{
    Access = Internal;

    var
        _Response: Codeunit "NPR API Response";
        _Request: Codeunit "NPR API Request";
        _ApiFunction: Enum "NPR TicketingApiFunctions";

    internal procedure SetRequest(ApiFunction: Enum "NPR TicketingApiFunctions"; var Request: Codeunit "NPR API Request");
    var
        ErrorCode: Enum "NPR API Error Code";
        ErrorStatusCode: Enum "NPR API HTTP Status Code";
    begin
        _ApiFunction := ApiFunction;
        _Request := Request;
        _Response.CreateErrorResponse(ErrorCode::resource_not_found, StrSubstNo('The API function %1 is not yet supported.', _ApiFunction), ErrorStatusCode::"Bad Request");
    end;

    internal procedure GetResponse() Response: Codeunit "NPR API Response"
    begin
        Response := _Response;
    end;

    trigger OnRun()
    begin
        HandleFunction();
    end;

    procedure HandleFunction()
    var
        Capacity: Codeunit "NPR TicketingCapacityAgent";
        Ticket: Codeunit "NPR TicketingTicketAgent";
        Catalog: Codeunit "NPR TicketingCatalogAgent";
        Reservation: Codeunit "NPR TicketingReservationAgent";
    begin
        case _ApiFunction of
            _ApiFunction::CAPACITY_SEARCH:
                _Response := Capacity.GetTimeSlots(_Request);
            _ApiFunction::SCHEDULE_SEARCH:
                _Response := Capacity.GetSchedules(_Request);

            _ApiFunction::CATALOG:
                _Response := Catalog.GetCatalog(_Request);

            // Ticketing
            _ApiFunction::GET_TICKET:
                _Response := Ticket.GetTicket(_Request);
            _ApiFunction::FIND_TICKETS:
                _Response := Ticket.FindTickets(_Request);
            _ApiFunction::REQUEST_REVOKE_TICKET:
                _Response := Ticket.RequestRevokeTicket(_Request);
            _ApiFunction::CONFIRM_REVOKE_TICKET:
                _Response := Ticket.ConfirmRevokeTicket(_Request);
            _ApiFunction::VALIDATE_ARRIVAL:
                _Response := Ticket.ValidateArrival(_Request);
            _ApiFunction::VALIDATE_DEPARTURE:
                _Response := Ticket.ValidateDeparture(_Request);
            _ApiFunction::VALIDATE_MEMBER_ARRIVAL:
                _Response := Ticket.ValidateMemberArrival(_Request);
            _ApiFunction::SEND_TO_WALLET:
                _Response := Ticket.SendToWallet(_Request);
            _ApiFunction::EXCHANGE_TICKET_FOR_COUPON:
                _Response := Ticket.ExchangeTicketForCoupon(_Request);
            _ApiFunction::CONFIRM_PRINT_TICKET:
                _Response := Ticket.ConfirmPrintTicket(_Request);
            _ApiFunction::CLEAR_CONFIRM_PRINT_TICKET:
                _Response := Ticket.ClearConfirmPrintTicket(_Request);

            // Reservation
            _ApiFunction::CREATE_RESERVATION:
                _Response := Reservation.CreateReservation(_Request);
            _ApiFunction::UPDATE_RESERVATION:
                _Response := Reservation.UpdateReservation(_Request);
            _ApiFunction::CANCEL_RESERVATION:
                _Response := Reservation.CancelReservation(_Request);
            _ApiFunction::GET_RESERVATION:
                _Response := Reservation.GetReservation(_Request);
            _ApiFunction::PRE_CONFIRM_RESERVATION:
                _Response := Reservation.PreConfirmReservation(_Request);
            _ApiFunction::CONFIRM_RESERVATION:
                _Response := Reservation.ConfirmReservation(_Request);
            _ApiFunction::GET_RESERVATION_TICKETS:
                _Response := Reservation.GetReservationTickets(_Request);

        end;
    end;
}
#endif