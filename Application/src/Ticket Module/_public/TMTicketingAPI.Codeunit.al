codeunit 6184475 "NPR TM TicketingAPI"
{
    Access = Public;

    procedure PickupPreConfirmedTicket(TicketReference: Code[30]; AllowPayment: Boolean; AllowUI: Boolean; AllowReprint: Boolean)
    var
        Ticketing: Codeunit "NPR POS Action - Ticket Mgt B.";
    begin
        Ticketing.PickupPreConfirmedTicket(TicketReference, AllowPayment, AllowUI, AllowReprint);
    end;

    procedure PickupPreConfirmedTicket(TicketReference: Code[30]; AllowPayment: Boolean; AllowUI: Boolean; AllowReprint: Boolean; var TempTicketsOut: Record "NPR TM Ticket" temporary)
    var
        Ticketing: Codeunit "NPR POS Action - Ticket Mgt B.";
    begin
        Ticketing.PickupPreConfirmedTicket(TicketReference, AllowPayment, AllowUI, AllowReprint, TempTicketsOut);
    end;

    procedure GetTicketsFromOrderReference(OrderReference: Code[20]; var TempTicketsOut: Record "NPR TM Ticket" temporary)
    var
        Ticketing: Codeunit "NPR POS Action - Ticket Mgt B.";
    begin
        Ticketing.GetTicketsFromOrderReference(OrderReference, TempTicketsOut);
    end;
}