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
        Metadata: JsonObject;
        Quantity: Decimal;
        BusinessDateKeyTok: Label 'business_date', Locked = true;
    begin
        if MetricSync.Get(_Metric, _BusinessDate) then
            exit;

        MetricSync.Init();
        MetricSync.Metric := _Metric;
        MetricSync."Business Date" := _BusinessDate;
        Quantity := _MetricImplementation.Calculate(MetricSync, Metadata);
        Metadata.Add(BusinessDateKeyTok, Format(_BusinessDate, 0, 9));

        if not MetricSync.Insert() then
            exit;
        _Sender.RegisterEvent(MetricSync.SystemId, _MetricImplementation.GetEventType(), Quantity, Metadata);
    end;

    internal procedure Initialize(Metric: Enum "NPR Customer Metric"; MetricImplementation: Interface "NPR ICustomer Metric"; Sender: Interface "NPR ICustomer Metric Sender"; BusinessDate: Date)
    begin
        _Metric := Metric;
        _MetricImplementation := MetricImplementation;
        _Sender := Sender;
        _BusinessDate := BusinessDate;
    end;
}
