codeunit 85497 "NPR Mock Customer Metric" implements "NPR ICustomer Metric"
{
    Access = Internal;

    var
        _Quantity: Decimal;
        _MetadataKey: Text;
        _MetadataValue: Text;
        _FailWith: Text;
        _FailOnDate: Date;
        _SimulateOverlappingRun: Boolean;
        _IsDelta: Boolean;
        _LastEntryNo: Integer;
        _CalculateCount: Integer;

    procedure SetValue(Quantity: Decimal; MetadataKey: Text; MetadataValue: Text)
    begin
        _Quantity := Quantity;
        _MetadataKey := MetadataKey;
        _MetadataValue := MetadataValue;
        _FailWith := '';
    end;

    procedure SetFailure(ErrorText: Text)
    begin
        _FailWith := ErrorText;
        _FailOnDate := 0D;
    end;

    procedure SetFailureOn(BusinessDate: Date; ErrorText: Text)
    begin
        _FailWith := ErrorText;
        _FailOnDate := BusinessDate;
    end;

    procedure SimulateOverlappingRun()
    begin
        _SimulateOverlappingRun := true;
    end;

    procedure SetDelta()
    begin
        _IsDelta := true;
    end;

    procedure SetLastEntryNo(LastEntryNo: Integer)
    begin
        _LastEntryNo := LastEntryNo;
    end;

    procedure CalculateCount(): Integer
    begin
        exit(_CalculateCount);
    end;

    procedure GetEventType(): Enum "NPR Billing Event Type"
    begin
        exit(Enum::"NPR Billing Event Type"::POS_ACTIVE_UNITS_7D_COUNT);
    end;

    procedure IsDelta(): Boolean
    begin
        exit(_IsDelta);
    end;

    procedure Calculate(var MetricSync: Record "NPR Customer Metric Sync"; var Metadata: JsonObject): Decimal
    var
        OverlappingMetricSync: Record "NPR Customer Metric Sync";
    begin
        _CalculateCount += 1;
        if (_FailWith <> '') and ((_FailOnDate = 0D) or (_FailOnDate = MetricSync."Business Date")) then
            Error(_FailWith);
        if _SimulateOverlappingRun then begin
            OverlappingMetricSync.Metric := MetricSync.Metric;
            OverlappingMetricSync."Business Date" := MetricSync."Business Date";
            OverlappingMetricSync.Insert();
        end;
        MetricSync."Last Entry No." := _LastEntryNo;
        if _MetadataKey <> '' then
            Metadata.Add(_MetadataKey, _MetadataValue);
        exit(_Quantity);
    end;
}
