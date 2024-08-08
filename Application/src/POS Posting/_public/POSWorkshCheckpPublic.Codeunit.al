codeunit 6184986 "NPR POS Worksh. Checkp. Public"
{
    Access = Public;

    [IntegrationEvent(false, false)]
    internal procedure OnAfterCalculateWorkshiftSummaryOnBeforeFinalizeCheckpoint(var POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint"; POSStoreCode: Code[10]; POSUnitNo: Code[10]; FromPosEntryNo: Integer)
    begin
    end;
}
