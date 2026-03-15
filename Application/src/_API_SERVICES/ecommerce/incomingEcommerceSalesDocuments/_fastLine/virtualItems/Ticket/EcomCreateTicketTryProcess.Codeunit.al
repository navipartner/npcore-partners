#if not BC17 and not BC18 and not BC19 and not BC20 and not BC21 and not BC22
codeunit 6248549 "NPR EcomCreateTicketTryProcess"
{
    Access = Internal;
    TableNo = "NPR Ecom Sales Header";
    trigger OnRun()
    var
        EcomCreateTicketImpl: Codeunit "NPR EcomCreateTicketImpl";
    begin
        if Rec."Ticket Reservation Token" = '' then
            EcomCreateTicketImpl.CreateRequestsForTicketLines(Rec);

        EcomCreateTicketImpl.ConfirmTickets(Rec);
    end;
}
#endif
