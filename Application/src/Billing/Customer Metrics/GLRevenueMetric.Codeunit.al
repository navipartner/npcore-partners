codeunit 6151256 "NPR GL Revenue Metric" implements "NPR ICustomer Metric"
{
    Access = Internal;
    Permissions =
        TableData "NPR Customer Metric Sync" = R;

    procedure GetEventType(): Enum "NPR Billing Event Type"
    begin
        exit(Enum::"NPR Billing Event Type"::GL_REVENUE_AMOUNT_LCY);
    end;

    procedure IsDelta(): Boolean
    begin
        exit(true);
    end;

    procedure Calculate(var MetricSync: Record "NPR Customer Metric Sync"; var Metadata: JsonObject): Decimal
    var
        GLRevenue: Query "NPR GL Revenue";
        FromEntryNo: Integer;
        Revenue: Decimal;
        FirstPostingDate: Date;
        LastPostingDate: Date;
        CurrencyTok: Label 'currency', Locked = true;
        PostingDateFromTok: Label 'posting_date_from', Locked = true;
        PostingDateToTok: Label 'posting_date_to', Locked = true;
    begin
        Metadata.Add(CurrencyTok, LCYCode());
        FromEntryNo := LastSentEntryNo(MetricSync);
        MetricSync."Last Entry No." := LastCommittedEntryNo();
        if MetricSync."Last Entry No." <= FromEntryNo then begin
            MetricSync."Last Entry No." := FromEntryNo;
            exit(0);
        end;

        GLRevenue.SetRange(EntryNo, FromEntryNo + 1, MetricSync."Last Entry No.");
        ExcludeYearEndClosingAndCompression(GLRevenue);
        GLRevenue.Open();
        while GLRevenue.Read() do begin
            if FirstPostingDate = 0D then
                FirstPostingDate := GLRevenue.PostingDate;
            LastPostingDate := GLRevenue.PostingDate;
            Revenue -= GLRevenue.Amount;
        end;
        GLRevenue.Close();

        if FirstPostingDate <> 0D then begin
            Metadata.Add(PostingDateFromTok, Format(FirstPostingDate, 0, 9));
            Metadata.Add(PostingDateToTok, Format(LastPostingDate, 0, 9));
        end;
        exit(Revenue);
    end;

    local procedure LastSentEntryNo(MetricSync: Record "NPR Customer Metric Sync"): Integer
    var
        SentMetricSync: Record "NPR Customer Metric Sync";
    begin
        SentMetricSync.ReadIsolation := IsolationLevel::UpdLock;
        SentMetricSync.SetCurrentKey(Metric, "Last Entry No.");
        SentMetricSync.SetRange(Metric, MetricSync.Metric);
        SentMetricSync.SetLoadFields("Last Entry No.");
        if SentMetricSync.FindLast() then begin
            // The locked read waits for an overlapping run to commit, but then returns the row it waited on, so it is repeated to see the position that run stored
            SentMetricSync.FindLast();
            exit(SentMetricSync."Last Entry No.");
        end;
        // The first event starts at the business date instead of covering the whole history
        exit(LastEntryNoRegisteredBefore(CreateDateTime(MetricSync."Business Date", 0T)));
    end;

    local procedure LastEntryNoRegisteredBefore(RegisteredBefore: DateTime): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetFilter(SystemCreatedAt, '<%1', RegisteredBefore);
        GLEntry.SetLoadFields("Entry No.");
        if GLEntry.FindLast() then
            exit(GLEntry."Entry No.");
    end;

    local procedure LastCommittedEntryNo(): Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        // G/L entries are numbered under a table lock, so everything up to the last committed entry is final, while an open or previewed posting can still roll back and its numbers be reused
        GLEntry.ReadIsolation := IsolationLevel::ReadCommitted;
        GLEntry.SetLoadFields("Entry No.");
        if GLEntry.FindLast() then
            exit(GLEntry."Entry No.");
    end;

    local procedure ExcludeYearEndClosingAndCompression(var GLRevenue: Query "NPR GL Revenue")
    var
        SourceCodeSetup: Record "Source Code Setup";
        CloseIncomeStatement: Code[10];
        CompressGL: Code[10];
    begin
        // Year-end closing posts the year's revenue back as a negative amount, and date compression inserts entries that were already sent again under new entry numbers
        SourceCodeSetup.SetLoadFields("Close Income Statement", "Compress G/L");
        if not SourceCodeSetup.Get() then
            exit;
        CloseIncomeStatement := SourceCodeSetup."Close Income Statement";
        CompressGL := SourceCodeSetup."Compress G/L";
        case true of
            (CloseIncomeStatement <> '') and (CompressGL <> ''):
                GLRevenue.SetFilter(SourceCode, '<>%1&<>%2', CloseIncomeStatement, CompressGL);
            CloseIncomeStatement <> '':
                GLRevenue.SetFilter(SourceCode, '<>%1', CloseIncomeStatement);
            CompressGL <> '':
                GLRevenue.SetFilter(SourceCode, '<>%1', CompressGL);
        end;
    end;

    local procedure LCYCode(): Code[10]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.SetLoadFields("LCY Code");
        if GeneralLedgerSetup.Get() then
            exit(GeneralLedgerSetup."LCY Code");
    end;
}
