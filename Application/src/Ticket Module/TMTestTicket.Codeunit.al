codeunit 6059874 "NPR TM Test Ticket"
{
    Access = Internal;

    TableNo = "NPR TM Offline Ticket Valid.";


    trigger OnRun()
    var
        Ticket: Record "NPR TM Ticket";
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ValidLbl: Label 'Ticket Valid.';
        NotFound: Label 'Ticket %1 not found.';
    begin
        if (not TicketManagement.GetTicket("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, Rec."Ticket Reference No.", Ticket)) then
            Error(NotFound, Rec."Ticket Reference No.");

        TicketManagement.ValidateTicketForArrival(Ticket, Rec."Admission Code", -1, CreateDateTime(Rec."Event Date", Rec."Event Time"));
        Error(ValidLbl);
    end;
}
