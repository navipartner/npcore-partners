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