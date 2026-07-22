codeunit 6248730 "NPR Cust. Activity Refresh"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    var
        GDPRSetupMissingErr: Label 'Customer GDPR Setup is missing.';

    trigger OnRun()
    var
        CustomerGDPRV2: Codeunit "NPR Customer GDPR V2";
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        Customer: Record Customer;
        Sentry: Codeunit "NPR Sentry";
        SentrySpan: Codeunit "NPR Sentry Span";
        BufferDays: Integer;
        ThresholdDate: Date;
        RefreshRunner: Codeunit "NPR Cust. Act. Refresh Runner";
        RefreshCustomerNos: List of [Code[20]];
        RefreshCustomerNo: Code[20];
    begin
        if not CustomerGDPRV2.IsFeatureEnabled() then
            exit;

        if not GDPRSetup.Get() then
            error(GDPRSetupMissingErr);

        if Format(GDPRSetup."Anonymize After") = '' then
            exit;

        BufferDays := (CalcDate(GDPRSetup."Anonymize After", Today()) - Today()) DIV 12;
        if BufferDays < 0 then
            BufferDays := 0;
        ThresholdDate := Today() + BufferDays;

        Sentry.StartSpan(SentrySpan, 'customer-gdpr-activity-refresh');

        Customer.SetRange("NPR Anonymized", false);
        Customer.SetFilter("NPR Estimated Cleanup Date", '%1|%2..%3', 0D, Today(), ThresholdDate);
        // The Job Queue runs this OnRun via a guarded Codeunit.Run, where a nested [TryFunction] may not write
        // and a nested guarded Run must see no uncommitted writes. Snapshot the candidates, then refresh each
        // through the runner's guarded Run and Commit after each so the next iteration starts on a clean
        // transaction.
        Customer.SetLoadFields("No.");
        if Customer.FindSet() then
            repeat
                RefreshCustomerNos.Add(Customer."No.");
            until Customer.Next() = 0;
        Commit();
        foreach RefreshCustomerNo in RefreshCustomerNos do begin
            RefreshRunner.SetCustomer(RefreshCustomerNo);
            if not RefreshRunner.Run() then
                Sentry.AddLastErrorIfProgrammingBug();
            Commit();
        end;

        SentrySpan.Finish();
    end;

    internal procedure RefreshSingleCustomer(var Customer: Record Customer) Updated: Boolean
    var
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        LatestSource: Enum "NPR Last Activity Source";
        LatestDate: Date;
    begin
        if Customer."NPR Anonymized" then
            exit(false);

        if not GDPRSetup.Get() then
            error(GDPRSetupMissingErr);

        DetermineLatestActivity(Customer."No.", LatestSource, LatestDate);

        if LatestDate = 0D then
            exit(false);

        // Never downgrade a more-recent activity - e.g. one pushed by an external system via the API -
        // with older internal activity. Equal dates need no update either.
        if Customer."NPR Last Activity" >= LatestDate then
            exit(false);

        Customer."NPR Last Activity Source" := LatestSource;
        Customer."NPR Last Activity" := LatestDate;
        Customer."NPR Estimated Cleanup Date" := CalcDate(GDPRSetup."Anonymize After", LatestDate);
        Customer.Modify(false);
        exit(true);
    end;

    internal procedure RecalculateForAnonymization(CustomerNo: Code[20])
    var
        Customer: Record Customer;
        GDPRSetup: Record "NPR Customer GDPR SetUp";
        LatestSource: Enum "NPR Last Activity Source";
        LatestDate: Date;
    begin
        if not Customer.Get(CustomerNo) then
            exit;
        if Customer."NPR Anonymized" then
            exit;
        // Only re-verify customers already scheduled for cleanup (a non-zero stamped date). A 0D customer
        // was never selected by the anonymization job (its candidate filters exclude 0D), so there is no
        // stale date to re-check; recomputing here would wrongly stamp a future date and defer a
        // direct/manual anonymization request.
        if Customer."NPR Estimated Cleanup Date" = 0D then
            exit;
        if not GDPRSetup.Get() then
            error(GDPRSetupMissingErr);
        if Format(GDPRSetup."Anonymize After") = '' then
            exit;

        DetermineLatestActivity(CustomerNo, LatestSource, LatestDate);

        // Never downgrade a more-recent (or equal) externally-pushed activity to older internal activity.
        if Customer."NPR Last Activity" >= LatestDate then begin
            LatestDate := Customer."NPR Last Activity";
            LatestSource := Customer."NPR Last Activity Source";
        end;

        if LatestDate = 0D then
            exit;

        // Recompute unconditionally so a changed "Anonymize After" is reflected at decision time.
        Customer."NPR Last Activity Source" := LatestSource;
        Customer."NPR Last Activity" := LatestDate;
        Customer."NPR Estimated Cleanup Date" := CalcDate(GDPRSetup."Anonymize After", LatestDate);
        Customer.Modify(false);
    end;

    local procedure DetermineLatestActivity(CustomerNo: Code[20]; var Source: Enum "NPR Last Activity Source"; var ActivityDate: Date)
    var
        Customer: Record Customer;
        POSEntry: Record "NPR POS Entry";
        CLE: Record "Cust. Ledger Entry";
        ILE: Record "Item Ledger Entry";
        BestDate: Date;
        BestSource: Enum "NPR Last Activity Source";
    begin
        BestDate := 0D;
        BestSource := Enum::"NPR Last Activity Source"::" ";

        POSEntry.SetRange("Customer No.", CustomerNo);
        POSEntry.SetLoadFields("Entry Date");
        if POSEntry.FindLast() then
            if POSEntry."Entry Date" > BestDate then begin
                BestDate := POSEntry."Entry Date";
                BestSource := Enum::"NPR Last Activity Source"::"POS Entry";
            end;

        CLE.SetCurrentKey("Customer No.", "Posting Date", "Currency Code");
        CLE.SetRange("Customer No.", CustomerNo);
        CLE.SetLoadFields("Posting Date");
        if CLE.FindLast() then
            if CLE."Posting Date" > BestDate then begin
                BestDate := CLE."Posting Date";
                BestSource := Enum::"NPR Last Activity Source"::"Customer Ledger Entry";
            end;

        ILE.SetRange("Source Type", ILE."Source Type"::Customer);
        ILE.SetRange("Source No.", CustomerNo);
        ILE.SetLoadFields("Posting Date");
        if ILE.FindLast() then
            if ILE."Posting Date" > BestDate then begin
                BestDate := ILE."Posting Date";
                BestSource := Enum::"NPR Last Activity Source"::"Item Ledger Entry";
            end;

        if BestDate = 0D then
            if Customer.Get(CustomerNo) then begin
                BestDate := DT2Date(Customer.SystemCreatedAt);
                BestSource := Enum::"NPR Last Activity Source"::"Creation Date";
            end;

        Source := BestSource;
        ActivityDate := BestDate;
    end;
}
