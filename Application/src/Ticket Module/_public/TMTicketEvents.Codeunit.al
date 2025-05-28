codeunit 6248462 "NPR TMTicketEvents"
{
    Access = Public;

    // This event is triggered when the auto-schedule selection fails.
    [IntegrationEvent(false, false)]
    procedure OnAssignSameScheduleFailure(ReservationRequestEntryNo: Integer; PosReceiptNo: Code[20]; ItemNo: Code[20]; VariantCode: Code[10]; AdmissionCode: Code[20]; var SelectedExternalScheduleEntryNumber: Integer);
    begin

    end;
}