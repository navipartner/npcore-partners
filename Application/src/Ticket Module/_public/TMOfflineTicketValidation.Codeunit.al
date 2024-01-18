codeunit 6184471 "NPR TM OfflineTicketValidation"
{
    Access = Public;

    var
        OfflineValidation: Codeunit "NPR TM OfflineTicketValidBL";

    procedure ProcessImportBatch(ImportBatchNo: Integer)
    begin
        OfflineValidation.ProcessImportBatch(ImportBatchNo);
    end;

    procedure AdmitTicketWithoutValidation(ExternalTicketNumber: Text[30]; AdmissionCode: Code[20]): Integer
    begin
        exit(AdmitTicketWithoutValidation(ExternalTicketNumber, AdmissionCode, Today(), Time()));
    end;

    procedure AdmitTicketWithoutValidation(ExternalTicketNumber: Text[30]; AdmissionCode: Code[20]; ArrivalDate: Date; ArrivalTime: Time): Integer
    begin
        exit(OfflineValidation.AdmitTicketWithoutValidation(ExternalTicketNumber, AdmissionCode, ArrivalDate, ArrivalTime));
    end;

    procedure GetReservation(TicketNo: Code[20]; AdmissionCode: Code[20]; var AdmissionScheduleEntryNo: Integer; var ReservationDate: Date; var ReservationTime: Time): Boolean
    var
        Ticket: Record "NPR TM Ticket";
        DetailedAccessEntry: Record "NPR TM Det. Ticket AccessEntry";
        AdmissionEntry: Record "NPR TM Admis. Schedule Entry";
    begin
        if (not Ticket.Get(TicketNo)) then
            exit(false);

        if (Ticket.Blocked) then
            exit(false);

        DetailedAccessEntry.SetCurrentKey("Ticket No.", Type);
        DetailedAccessEntry.SetFilter("Ticket No.", '=%1', Ticket."No.");
        DetailedAccessEntry.SetFilter(Type, '=%1', DetailedAccessEntry.Type::RESERVATION);
        if (not DetailedAccessEntry.FindLast()) then
            exit(false);

        AdmissionEntry.SetCurrentKey("External Schedule Entry No.");
        AdmissionEntry.SetFilter("External Schedule Entry No.", '=%1', DetailedAccessEntry."External Adm. Sch. Entry No.");
        AdmissionEntry.SetFilter(Cancelled, '=%1', false);
        if (not AdmissionEntry.FindLast()) then
            exit(false);

        AdmissionScheduleEntryNo := AdmissionEntry."Entry No.";
        ReservationDate := AdmissionEntry."Admission Start Date";
        ReservationTime := AdmissionEntry."Admission Start Time";
        exit(true);
    end;

    procedure AddRequestToOfflineValidation(SessionTokenId: Text[100]): Integer
    var
        TicketReservationRequest: Record "NPR TM Ticket Reservation Req.";
    begin
        TicketReservationRequest.SetCurrentKey("Session Token ID");
        TicketReservationRequest.SetFilter("Session Token ID", '=%1', SessionTokenId);
        exit(OfflineValidation.AddRequestToOfflineValidation(TicketReservationRequest));
    end;

    procedure CreateAdmitEvents(BatchName: Text; JRootObject: JsonObject) ImportId: Integer
    begin
        // {"Admit":[{"ExternalTicketNumber":"","AdmissionCode":"","EventDate":"","EventTime":""}]}
        OfflineValidation.CreateAdmitEvents(BatchName, JRootObject, ImportId);
    end;

    procedure CreateDepartEvents(BatchName: Text; JRootObject: JsonObject) ImportId: Integer
    begin
        // {"Depart":[{"ExternalTicketNumber":"","AdmissionCode":"","EventDate":"","EventTime":""}]}
        OfflineValidation.CreateDepartEvents(BatchName, JRootObject, ImportId);
    end;

}