codeunit 6248637 "NPR JQ Cleanup Dead POS Sales"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    var
        Sentry: Codeunit "NPR Sentry";
    begin
        Sentry.InitScopeAndTransaction('JQ Cleanup Dead POS Sales', 'jq.cleanup');
        DeleteDeadSalesFromUnattendedUnits();
        Sentry.FinalizeScope();
    end;

    local procedure DeleteDeadSalesFromUnattendedUnits()
    var
        POSUnit: Record "NPR POS Unit";
        POSSale: Record "NPR POS Sale";
        CutoffDateTime: DateTime;
        Sentry: Codeunit "NPR Sentry";
        SentrySpan: Codeunit "NPR Sentry Span";
    begin
        CutoffDateTime := CreateDateTime(CalcDate('<-1D>', WorkDate()), 0T);

        Sentry.StartSpan(SentrySpan, 'jq.cleanup.delete_dead_sales');

        POSUnit.SetRange("POS Type", POSUnit."POS Type"::UNATTENDED);
        if POSUnit.FindSet() then
            repeat
                POSSale.SetRange("Register No.", POSUnit."No.");
                POSSale.SetFilter(SystemCreatedAt, '<%1', CutoffDateTime);
                if POSSale.FindSet() then
                    repeat
                        if SaleHasEFTApprovedLines(POSSale) then begin
                            if not Codeunit.Run(Codeunit::"NPR JQ Cleanup Park Sale", POSSale) then begin
                                Sentry.AddLastErrorIfProgrammingBug();
                                Error('JQ Cleanup: Failed to park sale %1 on POS Unit %2: %3. This is a programming bug.', POSSale."Sales Ticket No.", POSSale."Register No.", GetLastErrorText());
                            end;
                        end else begin
                            if not Codeunit.Run(Codeunit::"NPR JQ Cleanup Delete Sale", POSSale) then begin
                                Sentry.AddLastErrorIfProgrammingBug();
                                Error('JQ Cleanup: Failed to delete sale %1 on POS Unit %2: %3. This is a programming bug.', POSSale."Sales Ticket No.", POSSale."Register No.", GetLastErrorText());
                            end;
                        end;
                    until POSSale.Next() = 0;
            until POSUnit.Next() = 0;

        SentrySpan.Finish();
    end;

    local procedure SaleHasEFTApprovedLines(POSSale: Record "NPR POS Sale"): Boolean
    var
        POSSaleLine: Record "NPR POS Sale Line";
    begin
        POSSaleLine.SetRange("Register No.", POSSale."Register No.");
        POSSaleLine.SetRange("Sales Ticket No.", POSSale."Sales Ticket No.");
        POSSaleLine.SetRange("EFT Approved", true);
        exit(not POSSaleLine.IsEmpty());
    end;
}
