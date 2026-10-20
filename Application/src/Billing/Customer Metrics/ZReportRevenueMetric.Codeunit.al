codeunit 6151568 "NPR Z-Report Revenue Metric" implements "NPR ICustomer Entry Metric"
{
    Access = Internal;

    procedure GetEventType(): Enum "NPR Billing Event Type"
    begin
        exit(Enum::"NPR Billing Event Type"::POS_ZREPORT_REVENUE_AMOUNT_LCY);
    end;

    procedure IsDelta(): Boolean
    begin
        exit(true);
    end;

    procedure RegisterEvents(var MetricSync: Record "NPR Customer Metric Sync"; Sender: Interface "NPR ICustomer Metric Sender")
    var
        ZReport: Record "NPR POS Workshift Checkpoint";
        BalancingEntry: Record "NPR POS Entry";
        FromEntryNo: Integer;
        LCYCode: Code[10];
    begin
        if not MetricSync.FindLastSentEntryNo(FromEntryNo) then
            // The first run starts at the business date instead of covering the whole history
            FromEntryNo := LastEntryNoCreatedBefore(CreateDateTime(MetricSync."Business Date", 0T));
        // A Z-report is inserted open and closed when its count is finished, so the next run only continues after the Z-reports inserted a week before the business date and checks the later ones again
        MetricSync."Last Entry No." := LastEntryNoCreatedBefore(CreateDateTime(MetricSync."Business Date" - 6, 0T));
        if MetricSync."Last Entry No." < FromEntryNo then
            MetricSync."Last Entry No." := FromEntryNo;

        // An end of day closes its Z-report in a transaction that can still roll back
        ZReport.ReadIsolation := IsolationLevel::ReadCommitted;
        ZReport.SetFilter("Entry No.", '>%1', FromEntryNo);
        ZReport.SetRange(Type, ZReport.Type::ZREPORT);
        ZReport.SetRange(Open, false);
        // A unit's first start and an initial float insert closed Z-reports without a balancing entry or revenue
        ZReport.SetFilter("POS Entry No.", '<>%1', 0);
        ZReport.SetLoadFields("POS Unit No.", "POS Entry No.", "Net Turnover (LCY)");
        if not ZReport.FindSet() then
            exit;

        LCYCode := GetLCYCode();
        BalancingEntry.SetLoadFields("Entry Date", "POS Store Code");
        repeat
            // A Z-report whose balancing entry is gone has no date or store to send, and failing on it would stop the position for good
            if BalancingEntry.Get(ZReport."POS Entry No.") then
                Sender.RegisterEvent(ZReport.SystemId, GetEventType(), ZReport."Net Turnover (LCY)", ZReportMetadata(ZReport, BalancingEntry, LCYCode));
        until ZReport.Next() = 0;
    end;

    local procedure ZReportMetadata(ZReport: Record "NPR POS Workshift Checkpoint"; BalancingEntry: Record "NPR POS Entry"; LCYCode: Code[10]) Metadata: JsonObject
    var
        BusinessDateKeyTok: Label 'business_date', Locked = true;
        POSUnitNoKeyTok: Label 'pos_unit_no', Locked = true;
        POSStoreCodeKeyTok: Label 'pos_store_code', Locked = true;
        CurrencyKeyTok: Label 'currency', Locked = true;
    begin
        // The balancing entry keeps the POS date the Z-report was closed on and the store the unit belonged to then
        Metadata.Add(BusinessDateKeyTok, Format(BalancingEntry."Entry Date", 0, 9));
        Metadata.Add(POSUnitNoKeyTok, ZReport."POS Unit No.");
        Metadata.Add(POSStoreCodeKeyTok, BalancingEntry."POS Store Code");
        Metadata.Add(CurrencyKeyTok, LCYCode);
    end;

    local procedure LastEntryNoCreatedBefore(CreatedBefore: DateTime): Integer
    var
        Checkpoint: Record "NPR POS Workshift Checkpoint";
    begin
        Checkpoint.SetFilter(SystemCreatedAt, '<%1', CreatedBefore);
        Checkpoint.SetLoadFields("Entry No.");
        if Checkpoint.FindLast() then
            exit(Checkpoint."Entry No.");
    end;

    local procedure GetLCYCode(): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.SetLoadFields("LCY Code");
        if GeneralLedgerSetup.Get() then
            exit(GeneralLedgerSetup."LCY Code");
    end;
}
