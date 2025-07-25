#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
enum 6059815 "NPR TicketingApiFunctions"
{
    Extensible = false;
    Access = Internal;
    value(0; NOOP)
    {
        Caption = 'No operation';
    }

    #region Operational List Functions
    value(100; CAPACITY_SEARCH)
    {
        Caption = 'Get capacity';
    }
    value(120; SCHEDULE_SEARCH)
    {
        Caption = 'Get schedule';
    }

    value(200; CATALOG)
    {
        Caption = 'Search catalog';
    }
    #endregion

    #region Ticket
    value(300; GET_TICKET)
    {
        Caption = 'Get ticket';
    }
    value(301; FIND_TICKETS)
    {
        Caption = 'Get ticket by filter';
    }

    value(302; VALIDATE_ARRIVAL)
    {
        Caption = 'Validate arrival';
    }
    value(303; VALIDATE_DEPARTURE)
    {
        Caption = 'Validate departure';
    }
    value(304; VALIDATE_MEMBER_ARRIVAL)
    {
        Caption = 'Validate member arrival';
    }
    value(305; SEND_TO_WALLET)
    {
        Caption = 'Send to wallet';
    }
    value(306; REQUEST_REVOKE_TICKET)
    {
        Caption = 'Request revoke ticket';
    }
    value(307; CONFIRM_REVOKE_TICKET)
    {
        Caption = 'Confirm revoke ticket';
    }
    value(308; EXCHANGE_TICKET_FOR_COUPON)
    {
        Caption = 'Exchange ticket for coupon';
    }
    value(309; CONFIRM_PRINT_TICKET)
    {
        Caption = 'Confirm print ticket';
    }
    value(310; CLEAR_CONFIRM_PRINT_TICKET)
    {
        Caption = 'Clear confirm print ticket';
    }

    #endregion
    #region Reservation
    value(400; CREATE_RESERVATION)
    {
        Caption = 'Create reservation';
    }
    value(401; UPDATE_RESERVATION)
    {
        Caption = 'Update reservation';
    }
    value(402; CANCEL_RESERVATION)
    {
        Caption = 'Cancel reservation';
    }
    value(403; GET_RESERVATION)
    {
        Caption = 'Get reservation';
    }
    value(405; PRE_CONFIRM_RESERVATION)
    {
        Caption = 'Pre-confirm reservation';
    }
    value(406; CONFIRM_RESERVATION)
    {
        Caption = 'Confirm reservation';
    }
    value(407; GET_RESERVATION_TICKETS)
    {
        Caption = 'Get reservation tickets';
    }

    #endregion

    #region Import/Export
    value(800; IMPORT_TICKET)
    {
        Caption = 'Import ticket';
    }
    #endregion

    #region Reports
    value(900; DYNAMIC_PRICE_PROFILE_LIST)
    {
        Caption = 'Get dynamic price profile list';
    }
    #endregion



}
#endif