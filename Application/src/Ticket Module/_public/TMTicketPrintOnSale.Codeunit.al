codeunit 6184658 "NPR TM Ticket Print On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        TMTicketManagement.PrintTicketFromSalesTicketNo(Rec."Sales Ticket No.");
    end;

}