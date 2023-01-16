codeunit 61000 "NPRPTE Integration Test Reset"
{
    procedure ResetState()
    var
        POSEntry: Record "NPR POS Entry";
        POSEntrySalesLine: Record "NPR POS Entry Sales Line";
        POSEntryPaymentLine: Record "NPR POS Entry Payment Line";
        POSEntryTaxLine: Record "NPR POS Entry Tax Line";
        POSWorkshiftCheckpoint: Record "NPR POS Workshift Checkpoint";
        POSSavedSaleEntry: Record "NPR POS Saved Sale Entry";
        POSSavedSaleLine: Record "NPR POS Saved Sale Line";
        POSSale: Record "NPR POS Sale";
        POSSaleLine: Record "NPR POS Sale Line";
        POSUnit: Record "NPR POS Unit";
        POSEntryOutputLog: Record "NPR POS Entry Output Log";
        POSAuditLog: Record "NPR POS Audit Log";
        EnvironmentInfo: Codeunit "Environment Information";
    begin
        if not EnvironmentInfo.IsSandbox() then
            exit;
        if not (CurrentClientType in [ClientType::Api, ClientType::OData, ClientType::ODataV4, ClientType::SOAP]) then
            exit;

        POSEntry.DeleteAll();
        POSEntrySalesLine.DeleteAll();
        POSEntryPaymentLine.DeleteAll();
        POSEntryTaxLine.DeleteAll();
        POSWorkshiftCheckpoint.DeleteAll();
        POSSavedSaleEntry.DeleteAll();
        POSSavedSaleLine.DeleteAll();
        POSSale.DeleteAll();
        POSSaleLine.DeleteAll();
        POSEntryOutputLog.DeleteAll();
        POSAuditLog.DeleteAll();

        POSUnit.ModifyAll(Status, POSUnit.Status::OPEN);
    end;


}