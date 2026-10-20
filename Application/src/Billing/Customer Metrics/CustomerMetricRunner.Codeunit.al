codeunit 6151257 "NPR Customer Metric Runner"
{
    Access = Internal;
    Permissions =
        TableData "NPR Customer Metric Sync" = RI;

    var
        _Metric: Enum "NPR Customer Metric";
        _MetricImplementation: Interface "NPR ICustomer Metric";
        _Sender: Interface "NPR ICustomer Metric Sender";
        _BusinessDate: Date;

    trigger OnRun()
    var
        MetricSync: Record "NPR Customer Metric Sync";
        DateMetric: Interface "NPR ICustomer Date Metric";
        EntryMetric: Interface "NPR ICustomer Entry Metric";
        Metadata: JsonObject;
        Quantity: Decimal;
        BusinessDateKeyTok: Label 'business_date', Locked = true;
    begin
        if MetricSync.Get(_Metric, _BusinessDate) then
            exit;

        MetricSync.Init();
        MetricSync.Metric := _Metric;
        MetricSync."Business Date" := _BusinessDate;
        if _MetricImplementation is "NPR ICustomer Entry Metric" then begin
            EntryMetric := _MetricImplementation as "NPR ICustomer Entry Metric";
            EntryMetric.RegisterEvents(MetricSync, _Sender);
            InsertSyncRow(MetricSync);
            exit;
        end;

        DateMetric := _MetricImplementation as "NPR ICustomer Date Metric";
        Quantity := DateMetric.Calculate(MetricSync, Metadata);
        Metadata.Add(BusinessDateKeyTok, Format(_BusinessDate, 0, 9));
        InsertSyncRow(MetricSync);
        _Sender.RegisterEvent(MetricSync.SystemId, _MetricImplementation.GetEventType(), Quantity, Metadata);
    end;

    local procedure InsertSyncRow(var MetricSync: Record "NPR Customer Metric Sync")
    var
        SentByOverlappingRunErr: Label 'An overlapping run already sent %1 for business date %2.', Comment = '%1 = customer metric, %2 = business date';
    begin
        if not MetricSync.Insert() then
            // Rolls back what the metric changed or queued, such as a delta metric's remembered entries or an entry metric's events, since only the run that sent the date may keep its changes
            Error(SentByOverlappingRunErr, _Metric, _BusinessDate);
    end;

    internal procedure Initialize(Metric: Enum "NPR Customer Metric"; MetricImplementation: Interface "NPR ICustomer Metric"; Sender: Interface "NPR ICustomer Metric Sender"; BusinessDate: Date)
    begin
        _Metric := Metric;
        _MetricImplementation := MetricImplementation;
        _Sender := Sender;
        _BusinessDate := BusinessDate;
    end;
}
