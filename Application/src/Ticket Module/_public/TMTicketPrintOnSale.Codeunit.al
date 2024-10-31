codeunit 6184658 "NPR TM Ticket Print On Sale"
{
    TableNo = "NPR POS Sale";

    trigger OnRun()
    var
        POSUnit: Record "NPR POS Unit";
        POSTicketProfile: Record "NPR TM POS Ticket Profile";
        TMTicketManagement: Codeunit "NPR TM Ticket Management";
    begin
        if not POSUnit.Get(Rec."Register No.") then
            exit;

        if not POSUnit.GetProfile(POSTicketProfile) then
            exit;

        if not POSTicketProfile."Print Ticket On Sale" then
            exit;

        TMTicketManagement.PrintTicketFromEndOfSale(Rec."Sales Ticket No.");
    end;

}