codeunit 6151251 "NPR Customer Metrics JQ"
{
    Access = Internal;
    TableNo = "Job Queue Entry";

    trigger OnRun()
    begin
        SendMetrics(Today() - 1);
    end;

    local procedure SendMetrics(Yesterday: Date)
    var
        Sender: Codeunit "NPR Customer Metric Sender";
        Metric: Enum "NPR Customer Metric";
        Ordinal: Integer;
        FailedMetrics: Text;
        MetricsFailedErr: Label 'The following customer metrics could not be sent:%1', Comment = '%1 = list of the failed metrics with their business dates and errors';
    begin
        foreach Ordinal in Enum::"NPR Customer Metric".Ordinals() do begin
            Metric := Enum::"NPR Customer Metric".FromInteger(Ordinal);
            SendMetric(Metric, Metric, Sender, Yesterday, FailedMetrics);
        end;

        if FailedMetrics <> '' then
            Error(MetricsFailedErr, FailedMetrics);
    end;

    internal procedure SendMetric(Metric: Enum "NPR Customer Metric"; MetricImplementation: Interface "NPR ICustomer Metric"; Sender: Interface "NPR ICustomer Metric Sender"; Yesterday: Date; var FailedMetrics: Text)
    var
        BusinessDate: Date;
        ErrorText: Text;
        FailedMetricLbl: Label '\%1, %2: %3', Comment = '%1 = metric, %2 = business date, %3 = error text';
    begin
        for BusinessDate := FirstBusinessDateToSend(Metric, Yesterday) to Yesterday do begin
            // TrySendMetric can isolate a failure only when no write transaction is open
            Commit();
            if not TrySendMetric(Metric, MetricImplementation, Sender, BusinessDate, ErrorText) then
                FailedMetrics += StrSubstNo(FailedMetricLbl, Format(Metric), BusinessDate, ErrorText);
        end;
        // The error raised for the failed dates must not roll back the sent ones
        Commit();
    end;

    local procedure FirstBusinessDateToSend(Metric: Enum "NPR Customer Metric"; Yesterday: Date): Date
    var
        MetricSync: Record "NPR Customer Metric Sync";
    begin
        // Catches up on the dates missed in the last 7 days, but not before the metric was first sent, so a new install or a new metric does not backfill history
        MetricSync.SetRange(Metric, Metric);
        if not MetricSync.FindFirst() then
            exit(Yesterday);
        if MetricSync."Business Date" > Yesterday - 6 then
            exit(MetricSync."Business Date");
        exit(Yesterday - 6);
    end;

    internal procedure TrySendMetric(Metric: Enum "NPR Customer Metric"; MetricImplementation: Interface "NPR ICustomer Metric"; Sender: Interface "NPR ICustomer Metric Sender"; BusinessDate: Date; var ErrorText: Text): Boolean
    var
        MetricRunner: Codeunit "NPR Customer Metric Runner";
    begin
        ErrorText := '';
        MetricRunner.Initialize(Metric, MetricImplementation, Sender, BusinessDate);
        if MetricRunner.Run() then
            exit(true);

        ErrorText := GetLastErrorText();
        LogFailure(Metric, BusinessDate);
        exit(false);
    end;

    local procedure LogFailure(Metric: Enum "NPR Customer Metric"; BusinessDate: Date)
    var
        Sentry: Codeunit "NPR Sentry";
        SentryErrorHandling: Codeunit "NPR Sentry Error Handling";
        TransactionNameLbl: Label 'Customer Metrics', Locked = true;
        OperationLbl: Label 'bc.customer-metrics.send', Locked = true;
        MetricTagLbl: Label 'customer_metric', Locked = true;
        BusinessDateDataLbl: Label 'business_date', Locked = true;
    begin
        if not SentryErrorHandling.IsLastErrorAProgrammingBug() then
            exit;
        Sentry.InitScopeAndTransaction(TransactionNameLbl, OperationLbl);
        Sentry.AddTransactionTag(MetricTagLbl, Metric.Names().Get(Metric.Ordinals().IndexOf(Metric.AsInteger())));
        Sentry.AddTransactionData(BusinessDateDataLbl, Format(BusinessDate, 0, 9));
        Sentry.AddLastErrorInEnglish();
        Sentry.FinalizeScope();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"NPR Job Queue Management", 'OnRefreshNPRJobQueueList', '', false, false)]
    local procedure AddCustomerMetricsJobOnRefresh()
    begin
        AddCustomerMetricsJob();
    end;

    internal procedure AddCustomerMetricsJob()
    var
        JobQueueEntry: Record "Job Queue Entry";
        JobQueueCategory: Record "Job Queue Category";
        JobQueueMgt: Codeunit "NPR Job Queue Management";
        NotBeforeDateTime: DateTime;
        NextRunDateFormula: DateFormula;
        JobCategoryDescrLbl: Label 'Customer Metrics', MaxLength = 30;
        JobQueueDescrLbl: Label 'Sends customer metrics to NaviPartner', MaxLength = 250;
    begin
        NotBeforeDateTime := CreateDateTime(Today(), 030000T);
        // A first run outside the run window makes the dispatcher reschedule the job continuously until the window opens
        if NotBeforeDateTime < CurrentDateTime() then
            NotBeforeDateTime := CreateDateTime(Today() + 1, 030000T);
        Evaluate(NextRunDateFormula, '<1D>');
        JobQueueMgt.SetJobTimeout(1, 0);
        JobQueueCategory.InsertRec(JQCategoryCode(), JobCategoryDescrLbl);
        JobQueueMgt.SetProtected(true);

        if JobQueueMgt.InitRecurringJobQueueEntry(
            JobQueueEntry."Object Type to Run"::Codeunit,
            Codeunit::"NPR Customer Metrics JQ",
            '',
            JobQueueDescrLbl,
            NotBeforeDateTime,
            DT2Time(NotBeforeDateTime),
            050000T,
            NextRunDateFormula,
            JQCategoryCode(),
            JobQueueEntry)
        then
            JobQueueMgt.StartJobQueueEntry(JobQueueEntry);
    end;

    internal procedure JQCategoryCode(): Code[10]
    begin
        exit('NPR-METRIC');
    end;
}
