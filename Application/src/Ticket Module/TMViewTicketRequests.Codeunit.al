codeunit 6060125 "NPR TM View Ticket Requests" implements "NPR Nc Import List ILookup"
{
    Access = Internal;
    // #280133/BHR/20170609 CASE 280133 View Ticket from Import list (document function)

    TableNo = "NPR Nc Import Entry";

    trigger OnRun()
    begin
    end;

    internal procedure RunLookupImportEntry(ImportEntry: Record "NPR Nc Import Entry")
    begin
        GetTicketReservation(ImportEntry);
    end;

    local procedure GetTicketReservation(NcImportEntry: Record "NPR Nc Import Entry")
    var
        TMTicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TMTicketReservationRequest.SetRange("Session Token ID", NcImportEntry."Document ID");
        if TMTicketReservationRequest.FindSet() then
            PAGE.RunModal(PAGE::"NPR TM Ticket Request", TMTicketReservationRequest);
    end;
}

