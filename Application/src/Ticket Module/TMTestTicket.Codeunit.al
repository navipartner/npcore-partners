codeunit 6059874 "NPR TM Test Ticket"
{
    Access = Internal;

    TableNo = "NPR TM Offline Ticket Valid.";


    trigger OnRun()
    var
        TicketManagement: Codeunit "NPR TM Ticket Management";
        ValidLbl: Label 'Ticket Valid';
    begin
        TicketManagement.ValidateTicketForArrival(1, Rec."Ticket Reference No.", Rec."Admission Code", -1, Rec."Event Date", Rec."Event Time");

        Error(ValidLbl);
    end;
}
