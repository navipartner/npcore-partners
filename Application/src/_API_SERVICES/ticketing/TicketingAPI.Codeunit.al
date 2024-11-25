#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6185040 "NPR TicketingApi" implements "NPR API Request Handler"
{
    Access = Internal;

    var
        _ApiFunction: Enum "NPR TicketingApiFunctions";
        _ErrorCode: Enum "NPR API Error Code";
        _ErrorStatusCode: Enum "NPR API HTTP Status Code";

    procedure Handle(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        if (Request.Paths().Count() < 2) then
            exit(InvalidPath());

        case (Request.Paths().Get(2)) of
            'catalog':
                exit(CatalogService(Request));
            'capacity':
                exit(CapacityService(Request));
            'ticket':
                exit(TicketService(Request));
            'reservation':
                exit(ReservationService(Request));
            else
                exit(InvalidServiceName());
        end;
    end;

    local procedure CatalogService(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        case Request.HttpMethod() of
            "Http Method"::GET:
                exit(Handle(_ApiFunction::CATALOG, Request));
            else
                exit(Response.RespondBadRequestUnsupportedHttpMethod(Request.HttpMethod()));
        end;
    end;

    local procedure CapacityService(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        case Request.HttpMethod() of

            "Http Method"::GET:
                begin
                    // /ticketing/capacity/search
                    if (Request.Paths().Count() <> 3) then
                        exit(InvalidPath());

                    if (Request.Paths().Get(3) = 'search') then
                        exit(Handle(_ApiFunction::CAPACITY_SEARCH, Request));

                    exit(InvalidServiceName());
                end;
            else begin
                exit(Response.RespondBadRequestUnsupportedHttpMethod(Request.HttpMethod()));
            end;
        end;
    end;

    local procedure TicketService(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        case Request.HttpMethod() of
            "Http Method"::GET:
                begin
                    // /ticketing/ticket/:ticketId
                    if (Request.Paths().Count() = 3) then
                        exit(Handle(_ApiFunction::GET_TICKET, Request));

                    exit(InvalidPath());
                end;
            "Http Method"::POST:
                begin
                    // /ticketing/ticket/:ticketId/<function_name>
                    if (Request.Paths().Count() <> 4) then
                        exit(InvalidPath());

                    case Request.Paths().Get(4) of
                        'requestRevoke':
                            exit(Handle(_ApiFunction::REQUEST_REVOKE_TICKET, Request));
                        'confirmRevoke':
                            exit(Handle(_ApiFunction::CONFIRM_REVOKE_TICKET, Request));
                        'validateArrival':
                            exit(Handle(_ApiFunction::VALIDATE_ARRIVAL, Request));
                        'validateDeparture':
                            exit(Handle(_ApiFunction::VALIDATE_DEPARTURE, Request));
                        'validateMemberArrival':
                            exit(Handle(_ApiFunction::VALIDATE_MEMBER_ARRIVAL, Request));
                        'sendToWallet':
                            exit(Handle(_ApiFunction::SEND_TO_WALLET, Request));
                        'exchangeForCoupon':
                            exit(Handle(_ApiFunction::EXCHANGE_TICKET_FOR_COUPON, Request));
                        else
                            exit(InvalidServiceName());
                    end;
                end;
            else begin
                exit(Response.RespondBadRequestUnsupportedHttpMethod(Request.HttpMethod()));
            end;
        end;
    end;

    local procedure ReservationService(var Request: Codeunit "NPR API Request") Response: Codeunit "NPR API Response"
    begin
        case Request.HttpMethod() of
            "Http Method"::GET:
                begin
                    // /ticketing/reservation/:token
                    if (Request.Paths().Count() = 3) then
                        exit(Handle(_ApiFunction::GET_RESERVATION, Request));

                    // /ticketing/reservation/:token/tickets
                    if (Request.Paths().Count() = 4) then
                        if (Request.Paths().Get(4) = 'tickets') then
                            exit(Handle(_ApiFunction::GET_RESERVATION_TICKETS, Request));

                    exit(InvalidPath());
                end;
            "Http Method"::POST:
                begin
                    // /ticketing/reservation
                    if (Request.Paths().Count() = 2) then
                        exit(Handle(_ApiFunction::CREATE_RESERVATION, Request));

                    // /ticketing/reservation/:token/<function_name>
                    if (Request.Paths().Count() <> 4) then
                        exit(InvalidPath());

                    case Request.Paths().Get(4) of
                        'cancel':
                            exit(Handle(_ApiFunction::CANCEL_RESERVATION, Request));
                        'pre-confirm':
                            exit(Handle(_ApiFunction::PRE_CONFIRM_RESERVATION, Request));
                        'confirm':
                            exit(Handle(_ApiFunction::CONFIRM_RESERVATION, Request));
                        else
                            exit(InvalidServiceName());
                    end;

                    exit(InvalidServiceName());
                end;

            "Http Method"::PUT:
                begin
                    // /ticketing/reservation/:token
                    if (Request.Paths().Count() = 3) then
                        exit(Handle(_ApiFunction::UPDATE_RESERVATION, Request));

                    exit(InvalidPath());
                end;
            else begin
                exit(Response.RespondBadRequestUnsupportedHttpMethod(Request.HttpMethod()));
            end;
        end;
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

    local procedure InvalidPath() Response: Codeunit "NPR API Response"
    begin
        Response.CreateErrorResponse(_ErrorCode::resource_not_found, 'Missing service name or too many segments', _ErrorStatusCode::"Bad Request");
    end;

    local procedure InvalidServiceName() Response: Codeunit "NPR API Response"
    begin
        Response.CreateErrorResponse(_ErrorCode::resource_not_found, 'Invalid service name', _ErrorStatusCode::"Bad Request");
    end;
}
#endif