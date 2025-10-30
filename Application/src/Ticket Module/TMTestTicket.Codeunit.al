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
        TicketNotValid: Label 'Ticket is not valid for the specified date %1.';
        AdmissionScheduleEntryNo: Integer;
    begin
        if (not TicketManagement.GetTicket("NPR TM TicketIdentifierType"::EXTERNAL_TICKET_NO, Rec."Ticket Reference No.", Ticket)) then
            Error(NotFound, Rec."Ticket Reference No.");

        AdmissionScheduleEntryNo := FindSchedule(Rec."Admission Code", Rec."Event Date", Rec."Event Time");
        TicketManagement.ValidateTicketForArrival(Ticket, Rec."Admission Code", AdmissionScheduleEntryNo, CreateDateTime(Rec."Event Date", Rec."Event Time"), '');

        if (Rec."Event Date" < Ticket."Valid From Date") or (Rec."Event Date" > Ticket."Valid To Date") then
            Error(TicketNotValid, Rec."Event Date");

        Error(ValidLbl);
    end;


    local procedure FindSchedule(AdmissionCode: Code[20]; EventDate: Date; EventTime: Time): Integer
    var
        AdmissionSchedule: Record "NPR TM Admis. Schedule Entry";
    begin
        AdmissionSchedule.SetCurrentKey("Admission Code", "Schedule Code", "Admission Start Date");
        AdmissionSchedule.SetFilter("Admission Code", '=%1', AdmissionCode);
        AdmissionSchedule.SetFilter("Admission Start Date", '=%1', EventDate);
        AdmissionSchedule.SetFilter("Admission Start Time", '<=%1', EventTime);
        AdmissionSchedule.SetFilter("Admission End Time", '>=%1', EventTime);
        AdmissionSchedule.SetFilter(Cancelled, '=%1', false);
        AdmissionSchedule.FindFirst();

        exit(AdmissionSchedule."Entry No.");
    end;
}
