#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185040 "NPR TicketingApi" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR TicketingApiFunctions";

    procedure Handle(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin

        if (Request.Paths().Get(1) = 'ticketing') then // Obsolete
            exit(Response.RespondBadRequest('Segment path changed from ticketing to ticket, check the API documentation for the correct path.'));


        if (Request.Match('GET', '/ticket/catalog/:storCode')) then
            exit(Handle(_ApiFunction::CATALOG, Request));


        if (Request.Match('GET', '/ticket/capacity/search')) then
            exit(Handle(_ApiFunction::CAPACITY_SEARCH, Request));


        if (Request.Match('GET', '/ticket/:ticketId')) then
            exit(Handle(_ApiFunction::GET_TICKET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/requestRevoke')) then
            exit(Handle(_ApiFunction::REQUEST_REVOKE_TICKET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/confirmRevoke')) then
            exit(Handle(_ApiFunction::CONFIRM_REVOKE_TICKET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/validateArrival')) then
            exit(Handle(_ApiFunction::VALIDATE_ARRIVAL, Request));

        if (Request.Match('POST', '/ticket/:ticketId/validateDeparture')) then
            exit(Handle(_ApiFunction::VALIDATE_DEPARTURE, Request));

        if (Request.Match('POST', '/ticket/:ticketId/validateMemberArrival')) then
            exit(Handle(_ApiFunction::VALIDATE_MEMBER_ARRIVAL, Request));

        if (Request.Match('POST', '/ticket/:ticketId/sendToWallet')) then
            exit(Handle(_ApiFunction::SEND_TO_WALLET, Request));

        if (Request.Match('POST', '/ticket/:ticketId/exchangeForCoupon')) then
            exit(Handle(_ApiFunction::EXCHANGE_TICKET_FOR_COUPON, Request));


        if (Request.Match('GET', '/ticket/reservation/:token')) then
            exit(Handle(_ApiFunction::GET_RESERVATION, Request));

        if (Request.Match('GET', '/ticket/reservation/:token/tickets')) then
            exit(Handle(_ApiFunction::GET_RESERVATION_TICKETS, Request));

        if (Request.Match('POST', '/ticket/reservation')) then
            exit(Handle(_ApiFunction::CREATE_RESERVATION, Request));

        if (Request.Match('POST', '/ticket/reservation/:token/cancel')) then
            exit(Handle(_ApiFunction::CANCEL_RESERVATION, Request));

        if (Request.Match('POST', '/ticket/reservation/:token/pre-confirm')) then
            exit(Handle(_ApiFunction::PRE_CONFIRM_RESERVATION, Request));

        if (Request.Match('POST', '/ticket/reservation/:token/confirm')) then
            exit(Handle(_ApiFunction::CONFIRM_RESERVATION, Request));

        if (Request.Match('PUT', '/ticket/reservation/:token')) then
            exit(Handle(_ApiFunction::UPDATE_RESERVATION, Request));

    end;

    local procedure Handle(ApiFunction: Enum "NPR TicketingApiFunctions"; var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    var
        TicketingApiHandler: Codeunit "NPR TicketingApiHandler";
    begin
        Commit();
        TicketingApiHandler.SetRequest(ApiFunction, Request);
        if (TicketingApiHandler.Run()) then
            exit(TicketingApiHandler.GetResponse());

        Response.CreateErrorResponse(Enum::"NPR API Error Code"::generic_error, StrSubstNo('An error occurred while processing the request: %1', GetLastErrorText()));
        Commit();
    end;
}
#endif