codeunit 85555 "NPR Mock Cust. Entry Metric" implements "NPR ICustomer Entry Metric"
{
    Access = Internal;

    var
        _EventId: Guid;
        _Quantity: Decimal;
        _LastEntryNo: Integer;
        _SimulateOverlappingRun: Boolean;

    procedure SetEvent(EventId: Guid; Quantity: Decimal)
    begin
        _EventId := EventId;
        _Quantity := Quantity;
    end;

    procedure SetLastEntryNo(LastEntryNo: Integer)
    begin
        _LastEntryNo := LastEntryNo;
    end;

    procedure SimulateOverlappingRun()
    begin
        _SimulateOverlappingRun := true;
    end;

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
        OverlappingMetricSync: Record "NPR Customer Metric Sync";
        Metadata: JsonObject;
    begin
        if _SimulateOverlappingRun then begin
            OverlappingMetricSync.Metric := MetricSync.Metric;
            OverlappingMetricSync."Business Date" := MetricSync."Business Date";
            OverlappingMetricSync.Insert();
            Commit();
        end;
        MetricSync."Last Entry No." := _LastEntryNo;
        Metadata.Add('business_date', Format(MetricSync."Business Date", 0, 9));
        Sender.RegisterEvent(_EventId, GetEventType(), _Quantity, Metadata);
    end;
}
