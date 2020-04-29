codeunit 6060125 "TM View Ticket Requests"
{
    // #280133/BHR/20170609 CASE 280133 View Ticket from Import list (document function)

    TableNo = "Nc Import Entry";

    trigger OnRun()
    begin
         GetTicketReservation(Rec);
    end;

    local procedure GetTicketReservation(NcImportEntry: Record "Nc Import Entry")
    var
        TMTicketReservationRequest: Record "TM Ticket Reservation Request";
    begin
        TMTicketReservationRequest.SetRange("Session Token ID",NcImportEntry."Document ID");
        if TMTicketReservationRequest.FindSet then
          PAGE.RunModal(PAGE::"TM Ticket Request",TMTicketReservationRequest);
    end;
}

